//
//  Actions.swift
//  OJT
//
//  Created by Rob Hendriks on 22/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import SwiftyJSON

struct Action {
  let originator: User
  let type: String
  let args: JSON
  let created: NSDate?
  
  init(_ json: JSON) {
    originator = User(json["originator"])
    type = json["actionType"].stringValue
    args = json["actionArgs"]
    created = NSDate.fromISOString(json["created"].stringValue)
  }
}

class ActionService {
  static func byPage(targetType: String, _ targetId: String, _ page: Int = 0, _ callback: ([Action]?, NSError?) -> Void) {
    Requests.manager.request(Router.ActionsByPage(page, targetType, targetId))
      .validate()
      .responseData { response in
        switch response.result {
        case .Failure(let error):
          callback(nil, error)
        case .Success(let value):
          let json = JSON(data: value)
          var actions = [Action]()
          
          for item in json["items"].arrayValue {
            actions.append(Action(item))
          }
          
          callback(actions, nil)
        }
    }
  }
}