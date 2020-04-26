import PathKit
import SwiftCLI
import BeakCore

class FunctionCommand: BeakCommand {

    let name = "function"
    let shortDescription = "Info about a specific function"

    @Param
    var functionName: String

    func execute(path: Path, beakFile: BeakFile) throws {
        guard let function = beakFile.functions.first(where: { $0.name == functionName }) else {
            throw BeakError.invalidFunction(functionName)
        }
        stdout <<< "\(function.name):\(function.docsDescription != nil ? " \(function.docsDescription!)" : "")"
        function.params.forEach { param in
            stdout <<< "  \(param.name): \(param.optionalType)\(param.defaultValue != nil ? " = \(param.defaultValue!)" : "")\(param.description != nil ? "  - \(param.description!)" : "")"
        }
    }
}
