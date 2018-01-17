//
//  Summary.swift
//  XCTestHTMLReport
//
//  Created by Titouan van Belle on 21.07.17.
//  Copyright © 2017 Tito. All rights reserved.
//

import Foundation

struct Summary: HTML
{
    private let filename = "action_TestSummaries.plist"

    var runs = [Run]()

    init(root: String)
    {
        Logger.step("Parsing Test Summaries")
        let enumerator = FileManager.default.enumerator(atPath: root)

        guard enumerator != nil else {
            Logger.error("Failed to create enumerator for path \(root)")
            exit(EXIT_FAILURE)
        }

        let paths = enumerator?.allObjects as! [String]

        Logger.substep("Searching for \(filename) in \(root)")
        let plistPath = paths.filter { $0.contains("action_TestSummaries.plist") }

        if plistPath.count == 0 {
            Logger.error("Failed to find action_TestSummaries.plist in \(root)")
            exit(EXIT_FAILURE)
        }

        for path in plistPath {
            let run = Run(root: root, path: path)
            runs.append(run)
        }
    }

    // PRAGMA MARK: - HTML

    var htmlTemplate = HTMLTemplates.index
    
    var DEVICES: [String: String] {
        let device = runs.map { $0.runDestination.htmlPlaceholderValues }.first!
        return device
    }
    
    var RESULT_CLASS: [String: String] {
        let a = runs.reduce(true, { (accumulator: Bool, run: Run) -> Bool in
            return accumulator && run.status == .success
        }) ? "success" : "failure"
        print(a)
        return["RESULT_CLASS":a]
    }
    
    var RUNS: [String: String] {
        print("amountSubTests:\(runs[0].testSummaries[0].tests[0].amountSubTests)")
        
        return ["aa":"aa"]
    }
    
    var htmlPlaceholderValues: [String: String] {
        return [
            "DEVICES": runs.map { $0.runDestination.html }.joined(),
            "RESULT_CLASS": runs.reduce(true, { (accumulator: Bool, run: Run) -> Bool in
                return accumulator && run.status == .success
            }) ? "success" : "failure",
            "RUNS": runs.map { $0.html }.joined()
        ]
    }
}

