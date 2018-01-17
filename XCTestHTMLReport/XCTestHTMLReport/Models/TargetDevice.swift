//
//  RunDestination.swift
//  XCTestHTMLReport
//
//  Created by Titouan van Belle on 21.07.17.
//  Copyright © 2017 Tito. All rights reserved.
//

import Foundation

struct TargetDevice
{
    var identifier: String
    var osVersion: String
    var model: String

    init(dict: [String : Any])
    {
        Logger.substep("Parsing TargetDevice")
        
        identifier = dict["Identifier"] as! String
        osVersion = dict["OperatingSystemVersion"] as! String
        model = dict["ModelName"] as! String
    }
    
    var dictionary: [String: Any] {
        return [
            "identifier" : identifier,
            "osVersion" : osVersion,
            "model" : model
        ]
    }
    
}

