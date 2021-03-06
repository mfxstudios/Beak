import PathKit
import SwiftCLI
import BeakCore

class RunCommand: BeakCommand {

    let name = "run"
    let shortDescription = "Run a function"

    @Param
    var function: String?
    
    @CollectedParam
    var functionArgs: [String]

    let options: BeakOptions

    init(options: BeakOptions) {
        self.options = options
    }

    func execute(path: Path, beakFile: BeakFile) throws {
        var functionCall: String?

        // parse function call
        if let functionName = function {
            guard let function = beakFile.functions.first(where: { $0.name == functionName }) else {
                throw BeakError.invalidFunction(functionName)
            }
            functionCall = try FunctionParser.getFunctionCall(function: function, arguments: functionArgs)
        }

        // create package
        let directory = path.absolute().parent()
        let packagePath = options.cachePath + directory.string.replacingOccurrences(of: "/", with: "_")
        let packageManager = PackageManager(path: packagePath, name: options.packageName, beakFile: beakFile)
        try packageManager.write(functionCall: functionCall)

        // build package
        do {
            _ = try Task.capture("swift", arguments: ["build", "--disable-sandbox"], directory: packagePath.string)
        } catch let error as CaptureError {
            stderr <<< error.captured.stdout
            stderr <<< error.captured.stderr
            throw error
        }

        // run package
        try Task.execvp("\(packagePath.string)/.build/debug/\(options.packageName)", arguments: [])
    }
}
