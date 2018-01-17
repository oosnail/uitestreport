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

struct chartModel{
    var value:Int
    var name:String
    var dictionary: [String: Any] {
        return [
            "value": value,
            "value": name
        ]
    }
}

//最终返回的model
struct resultModel{
    var device :  Dictionary<String, Any>
    var overview : Array<chartModel>{
        return self.overviewData()
    }
    var testModel :testModel
    //测试套
    var suites : Dictionary<String, Any>{
        return self.suiteData()
    }
    //时间
    var duration : Dictionary<String, Any>
    
    init(device:TargetDevice, testData: testModel) {
        self.testModel = testData
        self.device = device.dictionary
        self.duration = ["1":"2"]
    }
    
    var dictionary: [String: Any] {
        return [
            "device": device,
            "overview": overview,
            "suites":suites,
            "duration":duration
        ]
    }
    
    func overviewData()->Array<chartModel>{
        let success = self.testModel.amountSuccessTests
        let fail = self.testModel.amountSubTests - success
        let chartModel1 = chartModel.init(value: fail, name: "失败")
        let chartModel2 = chartModel.init(value: success, name: "成功")
        return [chartModel1,chartModel2]
    }
    
    func suiteData()->Dictionary<String, Any>{
        let names = self.testModel.subTests?.map({$0.name})
        let successs = self.testModel.subTests?.map({$0.amountSuccessTests})
        let fails = self.testModel.subTests?.map({$0.amountFailTests})
        var suites = Array<Dictionary<String, Any>>()
        for index in 0...(names?.count)!-1 {
            let name  = names![index]
            let chartModel1 = chartModel.init(value: successs![index], name: "成功")
            let chartModel2 = chartModel.init(value: fails![index], name: "失败")
            let dic = [name:[chartModel1,chartModel2]]
            suites.append(dic)
        }
        
        print("suites:=========>\(suites)")
        return ["1":"2"]
    }
    
    
}
