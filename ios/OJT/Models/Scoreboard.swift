//
//  Scoreboard.swift
//  OJT
//
//  Created by Rob Hendriks on 22/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import Alamofire
import SwiftyJSON

struct Scoreboard {
  
  let teams: [Team]?
  let contacts: [Contact]?
  
  init(_ json: JSON) {
    teams = [Team]()
    for item in json["teams"].arrayValue {
      teams!.append(Team(item))
    }
    
    contacts = [Contact]()
    for item in json["contacts"].arrayValue {
      contacts!.append(Contact(item))
    }
  }
  
}

class ScoreboardService {
  
  static func get(callback: (Scoreboard?, NSError?) -> Void) {
    Requests.manager.request(Router.Scoreboard())
      .validate()
      .responseData { response in
        switch response.result {
        case .Failure(let error):
          callback(nil, error)
        case .Success(let value):
          let json = JSON(data: value)
          let scoreboard = Scoreboard(json)
          callback(scoreboard, nil)
        }
      }
  }
  
}