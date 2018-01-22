//
//  resultModel.swift
//  XCTestHTMLReport
//
//  Created by 张天琛 on 2018/1/17.
//  Copyright © 2018年 Tito. All rights reserved.
//

import Foundation


struct testModel{
    var uuid: String
    var identifier: String
    var duration: Double
    var name: String
    var subTests: [testModel]?
    //暂时不写
//    var activities: [Activity]?
    var status: Status
    var objectClass: ObjectClass
    
    //多少个test
    var amountSubTests: Int {
        if let subTests = subTests {
            let a = subTests.reduce(0) { $0 + $1.amountSubTests }
            return a == 0 ? subTests.count : a
        }
        return 0
    }
    

    
    //多少个成功test
    var amountSuccessTests: Int {
        if let subTests = subTests {
            let a = subTests.reduce(0) { $0 + $1.amountSuccessTests }
            return a
        }else{
            if status == .success{
                return 1
            }else{
                return 0
            }
        }
    }
    
    //多少个成功test
    var amountFailTests: Int {
        if let subTests = subTests {
            let a = subTests.reduce(0) { $0 + $1.amountFailTests }
            return a
        }else{
            if status == .failure{
                return 1
            }else{
                return 0
            }
        }
    }
    
    
    init(dict: [String : Any]) {
        uuid = dict["TestSummaryGUID"] as? String ?? NSUUID().uuidString
        duration = dict["Duration"] as! Double
        name = dict["TestName"] as! String
        identifier = dict["TestIdentifier"] as! String
        
        let objectClassRaw = dict["TestObjectClass"] as! String
        objectClass = ObjectClass(rawValue: objectClassRaw)!
        
        if let rawSubTests = dict["Subtests"] as? [[String : Any]] {
            subTests = rawSubTests.map { testModel( dict: $0) }
        }
        
        let rawStatus = dict["TestStatus"] as? String ?? ""
        status = Status(rawValue: rawStatus)!
    }
}

struct ChartModel{
    var value:Any
    var name:String
    var dictionary: [String: Any] {
        return [
            "value": value,
            "name": name
        ]
    }
}

//最终返回的model
struct resultModel{
    var device :  Dictionary<String, Any>
    
    var overviewData : Dictionary<String, Any>{
        let success = self.testModel.amountSuccessTests
        let total = self.testModel.amountSubTests
        return ["success":success,"total":total]
    }
    
    var overviewReport : Array<Dictionary<String, Any>>{
        return self.overviewReportData()
    }
    var testModel :testModel
    //测试套
    var suitesReport : Dictionary<String, Any>{
        return self.suiteData()
    }
    //时间
    var durationReport : Dictionary<String, Any>{
        return self.durationData()
    }
    
    init(device:TargetDevice, testData: testModel) {
        self.testModel = testData
        self.device = device.dictionary
    }
    
    
    var trend : Dictionary<String,Any>{
//        //获取plist
        
//        //test
//        let trendPath = "/Users/ztcq/agent/iospackage/trend.json"
//        if !FileManager.default.fileExists(atPath: trendPath) {
//            try "{}".write(toFile: trendPath, atomically: false, encoding: .utf8)
//        }else{
//            let orgDict = NSDictionary(contentsOfFile: trendPath)
//            let newDict = ["2":"2"]
//        }

        return ["success":[1,3,4],"fail":[1,2,3],"name":["1","2","3"]]
    }
    
    
    
    func overviewReportData()->Array<Dictionary<String, Any>>{
        let success = self.testModel.amountSuccessTests
        let fail = self.testModel.amountSubTests - success
        let chartModel1 = ChartModel.init(value: fail, name: "失败")
        let chartModel2 = ChartModel.init(value: success, name: "成功")
        return [chartModel1.dictionary,chartModel2.dictionary]
    }
    
    
    func suiteData()->Dictionary<String, Any>{
        if let subTests = testModel.subTests {
            let names = subTests.map({$0.name})
            let suites2 = subTests.map({ (model) -> Array<Dictionary<String, Array<Dictionary<String, Any>>>> in
                let chartModel1 = ChartModel(value: model.amountSuccessTests, name: "成功")
                let chartModel2 = ChartModel(value: model.amountFailTests, name: "失败")
                return [[model.name : [chartModel1.dictionary,chartModel2.dictionary]]]
            })
            return ["suitesname" : names,"suites" : suites2]
        }
        return ["suitesname":[],"suites":[]]
    }
    

    
    func durationData()->Dictionary<String, Any>{
        let names = self.testModel.subTests?.map({$0.name})
        var durations = Dictionary<String,Any>()
        for tests in self.testModel.subTests!{
            let suitName = tests.name
            var array = Array<Dictionary<String, Any>>()
            for test in tests.subTests!{
                let chartModel = ChartModel.init(value:test.duration, name: test.name)
                array.append(chartModel.dictionary)
            }
            durations[suitName] = array
        }
        return ["suitesname":names!,"durations":durations]
    }
    
    var dictionary: [String: Any] {
        return [
            "device": device,
            "overview":overviewData,
            "report":[
                "trend":trend,
                "overview": overviewReport,
                "suites":suitesReport,
                "duration":durationReport
            ]
        ]
    }
    
}
