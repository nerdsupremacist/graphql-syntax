import XCTest
@testable import GraphQLSyntax

final class graphql_syntaxTests: XCTestCase {
    func testExample() {

        let code = """
        fragment MyUser on User {
            firstname
            lastname
        }

        query {
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

        let parser =  GraphQL.Parser()
        let syntaxTree = try! parser.syntaxTree(code)
        print(String(data: try! JSONEncoder().encode(syntaxTree), encoding: .utf8)!)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
