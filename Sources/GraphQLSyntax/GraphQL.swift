
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


//
//private struct GraphQLIdentifier: Parser {
//
//    var body: AnyParser<Void> {
//        RegularExpression("[a-zA-Z_-]+\\b")
//            .ignoreOutput()
//    }
//
//}
//
//private struct GraphQLVariable: Parser {
//
//    var body: AnyParser<Void> {
//        RegularExpression("\\$[a-zA-Z_-]+\\b")
//            .ignoreOutput()
//    }
//
//}
//
//private struct GraphQLValue: Parser {
//
//    var body: AnyParser<Void> {
//        Recursive { parser in
//            Group {
//                "{"
//
//                Group {
//                    Either {
//                        StringLiteral().ignoreOutput()
//
//                        GraphQLIdentifier()
//                    }
//
//                    ":"
//
//                    parser
//                }
//                .separated(by: ",")
//                .ignoreOutput()
//
//                "}"
//            }
//
//            Group {
//                "["
//
//                parser.separated(by: ", ").ignoreOutput()
//
//                "]"
//            }
//
//            BooleanLiteral().ignoreOutput()
//
//            StringLiteral().ignoreOutput()
//
//            IntLiteral().ignoreOutput()
//
//            GraphQLVariable()
//
//            GraphQLIdentifier().kind("enum.case")
//        }
//    }
//
//}
//
//private struct GraphQLArgumentAssignment: Parser {
//
//    var body: AnyParser<Void> {
//        RegularExpression("[a-zA-Z]+\\b")
//            .ignoreOutput()
//
//        ":"
//
//        GraphQLValue()
//    }
//
//}
//
//private struct GraphQLSelection: Parser {
//    let selectionSet: AnyParser<Void>
//
//    var body: AnyParser<Void> {
//        Group {
//            GraphQLIdentifier().kind("graphql.property")
//
//            Maybe {
//                "("
//
//                GraphQLArgumentAssignment()
//                    .separated(by: ",").ignoreOutput()
//
//                ")"
//            }
//
//            Maybe {
//                "{"
//
//                selectionSet
//
//                "}"
//            }
//        }
//
//    }
//
//}
//
//private struct GraphQLSelectionSet: Parser {
//
//    var body: AnyParser<Void> {
//        Recursive { parser in
//            GraphQLSelection()
//                .separated(by: "\n")
//                .ignoreOutput()
//        }
//    }
//
//}
//
//private struct GraphQLRootParser: Parser {
//
//    var body: AnyParser<Void> {
//        Either {
//            Group {
//                Word("fragment")
//
//                GraphQLIdentifier()
//
//                Word("on")
//
//                GraphQLIdentifier().kind("graphql.type")
//
//                "{"
//
//                GraphQLSelectionSet()
//
//                "}"
//            }
//        }
//    }
//
//}
