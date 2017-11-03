//
//  Team.swift
//  OJT
//
//  Created by Rob Hendriks on 14/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import Alamofire
import SwiftyJSON

struct Team : Player {
  
  let teamId: String
  let name: String
  let description: String
  let leader: Contact
  let leaderId: String
  var score: Float
  
  init(_ json: JSON) {
    teamId = json["_id"].stringValue
    name = json["name"].stringValue
    description = json["description"].stringValue
    leader = Contact(json["leader"])
    leaderId = json["leader"].stringValue
    score = json["score"].floatValue
  }
  
  func updateScore(operation: Operation, _ value: Float, _ callback: (Float?, NSError?) -> Void) {
    TeamService.updateScore(self, operation, value) { json, error in
      callback(json?["value"]["new"].float, error)
    }
  }
  
}

class TeamService {
  
  static func byPage(page: Int = 0, _ callback: ([Team]?, NSError?) -> Void) {
    Requests.manager.request(Router.TeamsByPage(page))
      .validate()
      .responseData { response in
        switch response.result {
        case .Failure(let error):
          callback(nil, error)
        case .Success(let value):
          let json = JSON(data: value)
          var teams = [Team]()
          
          for item in json["items"].arrayValue {
            teams.append(Team(item))
          }
          
          callback(teams, nil)
        }
      }
  }
  
  static func byUser(user: User, _ callback: (Team?, NSError?) -> Void) {
    Requests.manager.request(Router.TeamByUser(user))
      .validate()
      .responseData { response in
        switch response.result {
        case .Failure(let error):
          callback(nil, error)
        case .Success(let value):
          let json = JSON(data: value)
          let team = Team(json)
          callback(team, nil)
        }
    }
  }
  
  static func updateScore(team: Team, _ operation: Operation, _ value: Float, _ callback: (JSON?, NSError?) -> Void) {
    print(operation.description)
    Requests.manager.request(Router.TeamScore(team, operation.description, value))
      .validate()
      .responseData { response in
        switch response.result {
        case .Failure(let error):
          callback(nil, error)
        case .Success(let value):
          let json = JSON(data: value)
          callback(json, nil)
        }
    }
  }
  
}
