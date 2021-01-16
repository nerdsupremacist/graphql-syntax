import XCTest

import graphql_syntaxTests

var tests = [XCTestCaseEntry]()
tests += graphql_syntaxTests.allTests()
XCTMain(tests)
