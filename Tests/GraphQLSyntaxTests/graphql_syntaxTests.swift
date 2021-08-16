import XCTest
@testable import GraphQLSyntax

final class graphql_syntaxTests: XCTestCase {
    func testExample() {

        let code = """
        fragment MyUser on User {
            firstname
            lastname
        }

        query MyQuery {
            post(id: 42) {
                text
                author {
                    firstname
                    lastname
                    ...MyUser
                }
                media
            }
        }
        """

        let parser = GraphQL.Parser()
        let syntaxTree = try! parser.syntaxTree(code)
        print(String(data: try! JSONEncoder().encode(syntaxTree), encoding: .utf8)!)
    }

    func testBooleanValue() {
        let value = "false"
        let parser = GraphQL.Value.Parser()
        let parsed = try! parser.parse(value)
        XCTAssertEqual(parsed, .bool(false))
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
