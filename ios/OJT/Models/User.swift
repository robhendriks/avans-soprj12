//
//  User.swift
//  OJT
//
//  Created by Rob Hendriks on 13/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import Alamofire
import SwiftyJSON

struct User {
  let userId: String
  let email: String
  let contact: Contact
  
  init(_ json: JSON) {
    userId = json["_id"].stringValue
    email = json["email"].stringValue
    contact = Contact(json["contact"])
  }
}

class UserService {
  static func me(callback: (User?, NSError?) -> Void) {
    Requests.manager.request(Router.Me())
      .validate()
      .responseData { response in
        switch response.result {
        case .Failure(let error):
          callback(nil, error)
        case .Success(let value):
          let json = JSON(data: value)
          let user = User(json)
          callback(user, nil)
        }
      }
  }
}