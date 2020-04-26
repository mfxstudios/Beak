import Foundation

public struct Function {

    public let name: String
    public let params: [Param]
    public let throwing: Bool
    public let docsDescription: String?

    public init(name: String, params: [Param] = [], throwing: Bool = false, docsDescription: String? = nil) {
        self.name = name
        self.params = params
        self.throwing = throwing
        self.docsDescription = docsDescription
    }
}

extension Function: Equatable  {}
extension Function: CustomStringConvertible {
    public var description: String {
        let paramString = params.map { param in
            "\(param.unnamed ? "_ " : "")\(param.name): \(param.optionalType)\(param.defaultValue != nil ? " = \(param.defaultValue!)" : "")"
        }.joined(separator: ", ")
        return "\(name)(\(paramString))\(throwing ? " throws" : "")"
    }
}
