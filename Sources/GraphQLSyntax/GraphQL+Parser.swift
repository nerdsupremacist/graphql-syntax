
import Foundation
import Syntax

extension GraphQL {

    public struct Parser: Syntax.Parser {

        private static let implementation = _Parser().eraseToAnyParser()

        public var body: AnyParser<GraphQL.Root> {
            return Parser.implementation
        }
    }

    private struct _Parser: Syntax.Parser {
        var body: AnyParser<GraphQL.Root> {
            return Parser.RootObjectParser()
                .star()
                .map { objects in
                    var fragments: [GraphQL.Fragment] = []
                    var operations: [GraphQL.Operation] = []
                    for object in objects {
                        switch object {
                        case .fragment(let fragment):
                            fragments.append(fragment)
                        case .operation(let operation):
                            operations.append(operation)
                        }
                    }

                    return GraphQL.Root(fragments: fragments, operations: operations)
                }
        }
    }

}

extension GraphQL.Parser {

    fileprivate enum RootObject {
        case fragment(GraphQL.Fragment)
        case operation(GraphQL.Operation)
    }

    fileprivate struct RootObjectParser: Parser {
        var body: AnyParser<RootObject> {
            Either {
                FragmentParser().map(RootObject.fragment)
                OperationParser().map(RootObject.operation)
            }
        }
    }

}

extension GraphQL.Parser {

    fileprivate struct IdentifierParser: Parser {
        var body: AnyParser<String> {
            return RegularExpression("[_A-Za-z][_0-9A-Za-z]*").map { String($0.text) }
        }
    }

    fileprivate struct VariableParser: Parser {
        var body: AnyParser<String> {
            return RegularExpression("\\$([_A-Za-z][_0-9A-Za-z]*)")
                .map { String($0.text) }
                .kind("graphql.variable")
        }
    }

    fileprivate struct ValueParser: Parser {
        var body: AnyParser<GraphQL.Value> {
            Recursive { parser in
                Either {
                    Group {
                        "{"

                        Group {
                            Either {
                                StringLiteral()

                                IdentifierParser()
                            }

                            ":"

                            parser
                        }
                        .separated(by: ",")

                        "}"
                    }
                    .map { Dictionary($0) { $1 } }
                    .map(GraphQL.Value.dictionary)


                    Group {
                        "["

                        parser
                            .separated(by: ",")

                        "]"
                    }
                    .map(GraphQL.Value.array)

                    VariableParser().map(GraphQL.Value.variable)
                    IdentifierParser().map(GraphQL.Value.identifier)
                    StringLiteral().map(GraphQL.Value.string)
                    IntLiteral().map(GraphQL.Value.int)
                    DoubleLiteral().map(GraphQL.Value.double)
                    BooleanLiteral().map(GraphQL.Value.bool)

                    Word("null").map(to: GraphQL.Value.null)
                }
            }
        }
    }

    fileprivate struct FieldArgumentParser: Parser {
        var body: AnyParser<GraphQL.Argument> {
            return Group {
                IdentifierParser()
                    .kind("graphql.argument")

                ":"

                ValueParser()
            }
            .map { GraphQL.Argument(name: $0, value: $1) }
        }
    }

    fileprivate struct FieldSelectionParser: Parser {
        let selectionSet: AnyParser<GraphQL.SelectionSet>

        var body: AnyParser<GraphQL.FieldSelection> {
            return Group {
                Maybe {
                    IdentifierParser()

                    ":"
                }

                IdentifierParser()
                    .kind("graphql.field.property")

                Maybe {
                    "("

                    FieldArgumentParser().separated(by: ",")

                    ")"
                }

                selectionSet.maybe()
            }
            .map { GraphQL.FieldSelection(alias: $0, name: $1, arguments: $2 ?? [], selection: $3) }
        }
    }

    fileprivate struct TypeConditionalParser: Parser {
        let selectionSet: AnyParser<GraphQL.SelectionSet>

        var body: AnyParser<GraphQL.TypeConditional> {
            return Group {
                "..."

                Word("on").kind("graphql.keyword").ignoreOutput()

                IdentifierParser().kind("graphql.type")

                selectionSet
            }
            .map { GraphQL.TypeConditional(typeName: $0, selections: $1) }
        }
    }

    fileprivate struct SelectionParser: Parser {
        let selectionSet: AnyParser<GraphQL.SelectionSet>

        var body: AnyParser<GraphQL.Selection> {
            Either {
                TypeConditionalParser(selectionSet: selectionSet).map(GraphQL.Selection.typeConditional)

                FieldSelectionParser(selectionSet: selectionSet).map(GraphQL.Selection.field)

                Group {
                    "..."

                    IdentifierParser()
                }
                .map(GraphQL.Selection.inlineFragment)
            }
        }
    }

    fileprivate struct SelectionSetParser: Parser {
        var body: AnyParser<GraphQL.SelectionSet> {
            Recursive { parser in
                "{"

                SelectionParser(selectionSet: parser)
                    .plus()
                    .map(GraphQL.SelectionSet.init)

                "}"
            }
        }
    }

    fileprivate struct FragmentParser: Parser {
        var body: AnyParser<GraphQL.Fragment> {
            return Group {
                "fragment".kind("graphql.keyword")

                IdentifierParser()

                Word("on").kind("graphql.keyword").ignoreOutput()

                IdentifierParser().kind("graphql.type")

                SelectionSetParser()
            }
            .map { GraphQL.Fragment(name: $0, type: $1, selections: $2) }
        }
    }

    fileprivate struct OperationKindParser: Parser {
        var body: AnyParser<GraphQL.Operation.Kind> {
            Either {
                Word("query").map(to: GraphQL.Operation.Kind.query)
                Word("mutation").map(to: GraphQL.Operation.Kind.mutation)
                Word("subscription").map(to: GraphQL.Operation.Kind.subscription)
            }
            .kind("graphql.keyword")
        }
    }

    fileprivate struct OperationParser: Parser {
        private struct OperationHeader {
            let kind: GraphQL.Operation.Kind
            let name: String?
        }

        private struct OperationHeaderParser: Parser {
            var body: AnyParser<OperationHeader> {
                Either {
                    Group {
                        OperationKindParser()

                        IdentifierParser()
                    }
                    .map { OperationHeader(kind: $0, name: $1) }


                    Maybe {
                        Word("query").kind("graphql.keyword")
                    }
                    .map(to: OperationHeader(kind: .query, name: nil))
                }
            }
        }

        var body: AnyParser<GraphQL.Operation> {
            return Group {
                OperationHeaderParser()

                SelectionSetParser()
            }
            .map { GraphQL.Operation(kind: $0.kind, name: $0.name, selections: $1) }
        }
    }

}
