import Foundation
import PathKit
import SourceKittenFramework

public struct BeakFile {
    
    public let includedFiles: [BeakFile]
    
    private let ownContents: String
    private let ownDependencies: [Dependency]
    private let ownFunctions: [Function]
    private var path: Path?
    
    public var contents: String {
        let includedContents: [String] = includedFiles.reduce([]) { $0 + [$1.contents] }
        return Array(Set(includedContents + [ownContents])).joined(separator: "\n\n/// --\n\n")
    }
    
    public var dependencies: [Dependency] {
        let includedFilesDependencies: [Dependency] = includedFiles.reduce([]) { $0 + $1.dependencies }
        return includedFilesDependencies + ownDependencies
    }

    public var functions: [Function] {
        let includedFilesFunctions: [Function] = includedFiles.reduce([]) { $0 + $1.functions }
        return includedFilesFunctions + ownFunctions
    }

    public init(path: Path) throws {
        guard path.exists else {
            throw BeakError.fileNotFound(path.string)
        }
        let contents: String = try path.read()
        try self.init(contents: contents, path: path)
    }

    public var libraries: [String] {
        return dependencies.reduce([]) { $0 + $1.librariesOutput() }
    }

    public init(contents: String, path: Path? = nil) throws {
        self.ownContents = contents
        self.ownFunctions = try SwiftParser.parseFunctions(file: contents)
        self.ownDependencies = contents
            .split(separator: "\n")
            .map(String.init)
            .filter { $0.hasPrefix("// beak:") }
            .map { $0.replacingOccurrences(of: "// beak:", with: "") }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map(Dependency.init)
        self.includedFiles = contents
            .split(separator: "\n")
            .map(String.init)
            .filter { $0.hasPrefix("// include:") }
            .map { $0.replacingOccurrences(of: "// include:", with: "") }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.hasSuffix(".swift") }
            .compactMap { file in
                path.flatMap { p in try? BeakFile(path: p.parent() + Path(file)) }
            }
    }

    public init(contents: String, dependencies: [Dependency], functions: [Function], includedFiles: [BeakFile]) {
        self.ownContents = contents
        self.ownDependencies = dependencies
        self.ownFunctions = functions
        self.includedFiles = includedFiles
    }
}

extension BeakFile: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(contents)
        hasher.combine(includedFiles)
    }
}
