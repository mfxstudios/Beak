import Foundation

public struct Dependency {
    public let name: String
    public let package: String
    public let requirement: String
    public let libraries: [String]
    
    private var usePackageName: Bool
    
    public init(string: String) {
        let versionSplit = string
            .split(separator: "@")
            .map { String($0)
                .trimmingCharacters(in: .whitespaces) }
        let packageAndLibraries = versionSplit[0]
            .split(separator: " ", omittingEmptySubsequences: true)
            .map(String.init)
        let package = packageAndLibraries[0]

        var libraries: [String]?
        if packageAndLibraries.count > 1 {
            libraries = Array(packageAndLibraries.dropFirst())
        }
        let version = versionSplit[1]
        self.init(package: package, version: version, libraries: libraries)
    }

    public init(package: String, version: String, libraries: [String]? = nil) {
        self.package = Dependency.getPackage(name: package)
        self.requirement = Dependency.getRequirement(version: version)
        
        let name = String(package.split(separator: "/").last!.split(separator: ".").first!)
        
        if name.contains("(") && name.contains(")") {
            let packageName = String(name.split(separator: "(").last!.dropLast())
            let libraryName = String(name.split(separator: "(").first!)
            
            self.name = packageName
            self.libraries = libraries ?? [libraryName]
            self.usePackageName = true
        } else {
            self.name = name
            self.libraries = libraries ?? [name]
            self.usePackageName = false
        }
    }

    public init(name: String, package: String, requirement: String, libraries: [String]) {
        self.package = package
        self.requirement = requirement
        self.libraries = libraries
        
        if name.contains("(") && name.contains(")") {
            self.name = String(name.split(separator: "(").last!.dropLast())
            self.usePackageName = true
        } else {
            self.name = name
            self.usePackageName = false
        }
    }

    public static func getPackage(name: String) -> String {
        if name.split(separator: "/").count == 2 {
            if name.contains("(") {
                let parsed = String(name.split(separator: "(").first!)
                return "https://github.com/\(parsed).git"
            }
            
            return "https://github.com/\(name).git"
        } else {
            return name
        }
    }

    public static func getRequirement(version: String) -> String {
        if version.hasPrefix(".") {
            return version
        }
        let parts = version.split(separator: ":").map(String.init)
        if parts.count == 1 {
            return ".exact(\(version.quoted))"
        }
        let type = parts[0]
        var version = parts[1]
        if !version.hasPrefix("\"") && !version.hasSuffix("\"") {
            version = version.quoted
        }
        return ".\(type)(\(version))"
    }
    
    public func dependencyOutput() -> String {
        if usePackageName {
            return ".package(name: \(name.quoted), url: \(package.quoted), \(requirement))"
        }
        
        return ".package(url: \(package.quoted), \(requirement))"
    }
    
    public func librariesOutput() -> [String] {
        if libraries.count == 1,
           let lib = libraries.first,
           lib == name {
            return libraries.map { $0.quoted }
        }
        return libraries.map { ".product(name: \($0.quoted), package: \(name.quoted))" }
    }

}

extension Dependency: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(package)
        hasher.combine(requirement)
        hasher.combine(libraries)
    }
}
