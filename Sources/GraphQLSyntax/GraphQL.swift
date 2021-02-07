
import Foundation

public enum GraphQL {
    public indirect enum Value: Hashable {
        case dictionary([String : Value])
        case array([Value])
        case identifier(String)
        case variable(String)
        case int(Int)
        case double(Double)
        case string(String)
        case bool(Bool)
        case null
    }

    public struct Argument {
        public let name: String
        public let value: Value
    }

    public struct FieldSelection {
        public let alias: String?
        public let name: String
        public let arguments: [Argument]
        public let selection: SelectionSet?
    }

    public struct TypeConditional {
        public let typeName: String
        public let selections: SelectionSet
    }

    public indirect enum Selection {
        case typeConditional(TypeConditional)
        case inlineFragment(String)
        case field(FieldSelection)
    }

    public struct SelectionSet {
        public let selections: [Selection]
    }

    public struct Fragment {
        public let name: String
        public let type: String
        public let selections: SelectionSet
    }

    public struct Operation {
        public enum Kind {
            case query
            case mutation
            case subscription
        }

        public indirect enum ArgumentType {
            case nonNull(ArgumentType)
            case list(ArgumentType)
            case name(String)
        }

        public struct Argument {
            public let name: String
            public let type: ArgumentType
        }

        public let kind: Kind
        public let name: String?
        public let selections: SelectionSet
    }

    public struct Root {
        public let fragments: [Fragment]
        public let operations: [Operation]
    }
}
