//
//  Event.swift
//  OJT
//
//  Created by Rob Hendriks on 18/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import Alamofire
import SwiftyJSON

struct Event {
  let eventId: String
  let name: String
  let description: String
  let dateFrom: NSDate?
  let dateTo: NSDate?
  let schedules: [Schedule]
  
  init(_ json: JSON) {
    eventId = json["_id"].stringValue
    name = json["name"].stringValue
    description = json["description"].stringValue
    dateFrom = NSDate.fromISOString(json["dateFrom"].stringValue)
    dateTo = NSDate.fromISOString(json["dateTo"].stringValue)
    
    var schedules = [Schedule]()
    for item in json["schedules"].arrayValue {
      schedules.append(Schedule(item))
    }
    self.schedules = schedules
  }
}

class EventService {
  static func current(callback: ([Event]?, NSError?) -> Void) {
    Requests.manager.request(Router.CurrentEventsByPage(0))
      .validate()
      .responseData { response in
        switch response.result {
        case .Failure(let error):
          callback(nil, error)
        case .Success(let value):
          let json = JSON(data: value)
          var events = [Event]()
          
          for item in json["items"].arrayValue {
            events.append(Event(item))
          }
          
          callback(events, nil)
        }
    }
  }
}