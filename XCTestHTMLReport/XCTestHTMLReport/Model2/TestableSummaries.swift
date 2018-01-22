//
//  TestableSummaries.swift
//  XCTestHTMLReport
//
//  Created by 张天琛 on 2018/1/16.
//  Copyright © 2018年 Tito. All rights reserved.
//

import Foundation

//趋势存储的最大数量
let trendnum = 10

class TestableSummaries{
    private let filename = "action_TestSummaries.plist"
    var data :Dictionary<String, Any>
    
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
        
        let path = plistPath[0]
        let run = runTest(root: root, path: path)
        self.data = run.setResult()
    }

}

//一次run 可以不同的手机
class runTest:NSObject{
    private let activityLogsFilename = "action.xcactivitylog"

    var testData : testModel
    var targetDevice :TargetDevice
    
    init(root: String, path: String)
    {
        let fullpath = root + "/" + path
        Logger.step("Parsing summary")
        Logger.substep("Found summary at \(fullpath)")
        let dict = NSDictionary(contentsOfFile: fullpath)
        
        guard dict != nil else {
            Logger.error("Failed to parse the content of \(fullpath)")
            exit(EXIT_FAILURE)
        }
        //设备信息
        let dic = dict!["RunDestination"] as! [String : Any]
        self.targetDevice = TargetDevice(dict: dic["TargetDevice"] as! [String : Any])
        
        //数据信息
        let dic2 = dict!["TestableSummaries"] as! [[String: Any]]
        let dic3 = dic2[0]
        let rawTests = dic3["Tests"] as! [[String: Any]]
        let dic4 = rawTests[0]
        let array = dic4["Subtests"] as! [[String: Any]]
        let dic5 = array[0]
        self.testData = testModel.init(dict: dic5)
    }
    
    func addlog(_ fullpath:String){
        Logger.substep("Parsing Activity Logs")
        let parentDirectory = fullpath.dropLastPathComponent()
        Logger.substep("Searching for \(activityLogsFilename) in \(parentDirectory)")
        let logsPath = parentDirectory + "/" + activityLogsFilename
        
        if !FileManager.default.fileExists(atPath: logsPath) {
            Logger.warning("Failed to find \(activityLogsFilename) in \(parentDirectory). Not appending activity logs to report.")
        } else {
            Logger.substep("Found \(logsPath)")
            
            let data = NSData(contentsOfFile: logsPath)
            
            Logger.substep("Gunzipping activity logs")
            let gunzippedData = data!.gunzipped()!
            let logs = String(data: gunzippedData, encoding: .utf8)!
            
            Logger.substep("Extracting useful activity logs")
            let runningTestsPattern = "Running tests..."
            let runningTestsRegex = try! NSRegularExpression(pattern: runningTestsPattern, options: .caseInsensitive)
            let runningTestsMatches = runningTestsRegex.matches(in: logs, options: [], range: NSRange(location: 0, length: logs.count))
            let lastRunningTestsMatch = runningTestsMatches.last
            
            guard lastRunningTestsMatch != nil else {
                Logger.warning("Failed to extract activity logs. Could not locate match for \"\(runningTestsPattern)\" ")
                return
            }
            
            let pattern = "Test Suite '.+' (failed|passed).+\r.+seconds"
            let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let matches = regex.matches(in: logs, options: [], range: NSRange(location: 0, length: logs.count))
            let lastMatch = matches.last
            
            guard lastMatch != nil else {
                Logger.warning("Failed to extract activity logs. Could not locate match for \"\(pattern)\" ")
                return
            }
            
            let startIndex = lastRunningTestsMatch!.range.location
            let endIndex = lastMatch!.range.location + lastMatch!.range.length
            let start = logs.index(logs.startIndex, offsetBy: startIndex)
            let end = logs.index(logs.startIndex, offsetBy: endIndex)
            let activityLogs = logs[start..<end]
            
            do {
                let file = "\(result.value!)/logs-\(targetDevice.identifier).txt"
                try activityLogs.write(toFile: file, atomically: false, encoding: .utf8)
            }
            catch let e {
                Logger.error("An error has occured while create the activity log file. Error: \(e)")
            }
    }
    
}
    
    func setResult()->Dictionary<String, Any>{
        //设置trend
        self.settrendData()
        let res = resultModel.init(device: self.targetDevice, testData: self.testData)
        return res.dictionary
    }
    
    
    func settrendData(){
        //test
        let trendPath = "/Users/ztcq/agent/iospackage/trend.json"
        var newDict : Dictionary<String,Any>!

        var orgDict : Dictionary<String,Any>!
        
        if let content = try? String.init(contentsOfFile: trendPath){
            let data = content.data(using: String.Encoding.utf8)
            if let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers){
                orgDict = dict as! Dictionary<String, Any>
            }
        }
        print(orgDict.description )
        let addDic:[String : Any]  = ["jobnum":jobnum.value ?? "jobnum","fail":32,"success":22]
        //添加
        newDict = orgDict
        //删除
        var array = newDict["trend"]! as! Array<Dictionary<String,Any>>
        array.append(addDic)
        if array.count > trendnum{
            let i = array.count-trendnum
            array.removeSubrange(0..<i)
        }
        newDict["trend"] = array
        file.write(dict: newDict, name: trendPath)
    }
    
    var value: [String: Any] {
        return [
            "device": targetDevice,
            "TEST_SUMMARIES": ""
        ]
    }
    
    func getJSONStringFromDictionary(dictionary:NSDictionary) -> String {
        if (!JSONSerialization.isValidJSONObject(dictionary)) {
            print("无法解析出JSONString")
            return ""
        }
        let data : NSData! = try? JSONSerialization.data(withJSONObject: dictionary, options: []) as NSData!
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
        
    }

}


class file: NSObject {
    class func write(dict:Dictionary<String, Any>,name:String) -> Void {
        let data : NSData! = try? JSONSerialization.data(withJSONObject: dict, options: []) as NSData!
        let logs = String(data: data as Data, encoding: .utf8)!
        
        do {
            let file = name
            try logs.write(toFile: file, atomically: false, encoding: .utf8)
            Logger.success("\nReport data successfully created at \(file)")
        }
        catch let e {
            Logger.error("An error has occured while create the activity log file. Error: \(e)")
        }
    }
}


