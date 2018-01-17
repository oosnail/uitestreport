//
//  Summary.swift
//  XCTestHTMLReport
//
//  Created by Titouan van Belle on 21.07.17.
//  Copyright © 2017 Tito. All rights reserved.
//

import Foundation

struct TestSummary: HTML
{
    var uuid: String
    var testName: String
    var tests: [Test]
    var count = 0
    var status: Status {
        var currentTests = tests
        var status: Status = .unknown

        while status == .unknown {
            status = currentTests.reduce(.unknown, { (accumulator: Status, test: Test) -> Status in
                if accumulator == .unknown {
                    return test.status
                }

                if test.status == .failure {
                    return .failure
                }

                if test.status == .success {
                    return accumulator == .failure ? .failure : .success
                }

                return .unknown
            })

            currentTests = currentTests.reduce([], { (accumulator: [Test], test: Test) -> [Test] in
                if let subTests = test.subTests {
                    return accumulator + subTests
                }

                return accumulator
            })
        }
        return status
    }

    init(root: String, dict: [String : Any])
    {
        Logger.substep("Parsing TestSummary")
        uuid = NSUUID().uuidString
        testName = dict["TestName"] as! String
        let rawTests = dict["Tests"] as! [[String: Any]]
        tests = rawTests.map { Test(root: root, dict: $0) }
    }

    // PRAGMA MARK: - HTML

    var htmlTemplate = HTMLTemplates.testSummary

    var htmlPlaceholderValues: [String: String] {
        return [
            "UUID": uuid,
            "TESTS": tests.reduce("", { (accumulator: String, test: Test) -> String in
                return accumulator + test.html
            })
        ]
    }
}
