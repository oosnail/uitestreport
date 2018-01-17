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
    
    var amountSubTests: Int {
        if let subTests = subTests {
            let a = subTests.reduce(0) { $0 + $1.amountSubTests }
            return a == 0 ? subTests.count : a
        }
        return 0
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
        
//        if let rawActivitySummaries = dict["ActivitySummaries"] as? [[String : Any]] {
//            activities = rawActivitySummaries.map { Activity(root: root, dict: $0, padding: 20) }
//        }
        
        let rawStatus = dict["TestStatus"] as? String ?? ""
        status = Status(rawValue: rawStatus)!
//        if status == .success{
//            successNum.sharedInstance.successnum = successNum.sharedInstance.successnum + 1
//        }
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
    var device : TargetDevice
    var overview : Array<chartModel>
    //测试套
    var suites : Dictionary<String, Any>
    //时间
    var duration : Dictionary<String, Any>
    var dictionary: [String: Any] {
        return [
            "device": device.dictionary,
            "overview": overview,
            "suites":suites,
            "duration":duration
        ]
    }
}
