import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(graphql_syntaxTests.allTests),
    ]
}
#endif
