//
//  Schedule.swift
//  OJT
//
//  Created by Rob Hendriks on 18/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import SwiftyJSON

struct Schedule {
  let scheduleId: String
  let name: String
  let date: NSDate?
  let starts: String
  let ends: String
  
  init(_ json: JSON) {
    scheduleId = json["_id"].stringValue
    name = json["name"].stringValue
    date = NSDate.fromISOString(json["date"].stringValue)
    starts = json["starts"].stringValue
    ends = json["ends"].stringValue
  }
}