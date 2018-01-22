//
//  main.swift
//  XCTestHTMLReport
//
//  Created by Titouan van Belle on 21.07.17.
//  Copyright © 2017 Tito. All rights reserved.
//

import Foundation


var version = "1.4.0"

print("XCTestHTMLReport \(version)")

var command = Command()
var help = BlockArgument("h", "", required: false, helpMessage: "Print usage and available options") {
    print(command.usage)
    exit(EXIT_SUCCESS)
}
var verbose = BlockArgument("v", "", required: false, helpMessage: "Provide additional logs") {
    Logger.verbose = true
}

var result = ValueArgument(.path, "r", "resultBundePath", required: false, helpMessage: "Path to the result bundle")

var jobnum = ValueArgument(.num, "j", "jobnum", required: false, helpMessage: "jenkins job number")

command.arguments = [help, verbose, result,jobnum]
jobnum.value = "jobnum2"
result.value = "/Users/ztcq/Documents/workdir/uitestreport/casereport"
if !command.isValid {
    print(command.usage)
    exit(EXIT_FAILURE)
}

//处理数据
let summary = Summary(root: result.value!)
let summary2  = TestableSummaries(root: result.value!)



Logger.step("Building HTML..")
let html = summary.html

do {
    let path = "\(result.value!)/index.html"
    Logger.substep("Writing report to \(path)")

    try html.write(toFile: path, atomically: false, encoding: .utf8)
    Logger.success("\nReport successfully created at \(path)")
}
catch let e {
    Logger.error("An error has occured while creating the report. Error: \(e)")
}

let data = summary2.data
file.write(dict: data, name: "data.json")

exit(EXIT_SUCCESS)
