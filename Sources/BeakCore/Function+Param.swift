import Foundation

extension Function {
    public struct Param: Hashable {
        public let name: String
        public let type: Kind
        public let optional: Bool
        public let defaultValue: String?
        public let description: String?
        public let unnamed: Bool

        public var required: Bool {
            return defaultValue == nil
        }

        public init(name: String, type: Kind, optional: Bool = false, defaultValue: String? = nil, unnamed: Bool = false, description: String? = nil) {
            self.name = name
            self.type = type
            self.optional = optional
            self.defaultValue = defaultValue
            self.unnamed = unnamed
            self.description = description
        }

        public var optionalType: String {
            return type.string + (optional ? "?" : "")
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(name)
            hasher.combine(type)
            hasher.combine(optional)
            hasher.combine(defaultValue)
            hasher.combine(description)
            hasher.combine(unnamed)
        }
    }
}

extension Function.Param {
    public enum Kind: Hashable, CustomStringConvertible, ExpressibleByStringLiteral {
        case bool
        case int
        case string
        case other(String)

        public init(stringLiteral value: String) {
            self.init(string: value)
        }

        public init(string: String) {
            switch string.lowercased() {
            case "bool": self = .bool
            case "int": self = .int
            case "string": self = .string
            default: self = .other(string)
            }
        }

        public var description: String {
            return string
        }

        public var string: String {
            switch self {
            case .bool: return "Bool"
            case .int: return "Int"
            case .string: return "String"
            case let .other(type): return type
            }
        }
    }
}
