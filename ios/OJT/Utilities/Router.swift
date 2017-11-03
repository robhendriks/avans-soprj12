//
//  Router.swift
//  OJT
//
//  Created by Rob Hendriks on 17/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import Alamofire

enum Router : URLRequestConvertible {
  case Me()
  case TeamsByPage(Int)
  case TeamByUser(User)
  case ContactsByPage(Int)
  case ContactsByUserAndPage(User, Int)
  case ContactsByTeamAndPage(Team, Int)
  case ChildrenByPage(Int)
  case CurrentEventsByPage(Int)
  case Scoreboard()
  case ActionsByPage(Int, String, String)
  case TeamScore(Team, String, Float)
  case ContactScore(Contact, String, Float)
  
  var URLRequest: NSMutableURLRequest {
    let result: (method: String, url: String, parameters: [String: AnyObject]?) = {
      switch self {
      case .Me():
        return ("GET", "/api/me/", nil)
      
      case .TeamsByPage(let page):
        return ("GET", "/api/teams", ["page": page])
      case .TeamByUser(let user):
        return ("GET", "/api/contacts/\(user.contact.contactId)/team/", nil)
      
      case .ContactsByPage(let page):
        return ("GET", "/api/contacts", ["page": page])
      case .ContactsByUserAndPage(let user, let page):
        return ("GET", "/api/contacts/\(user.contact.contactId)/children", ["page": page])
      case .ContactsByTeamAndPage(let team, let page):
        return ("GET", "/api/teams/\(team.teamId)/members", ["page": page])
      
      case .ChildrenByPage(let page):
        return ("GET", "/api/contacts/children", ["page": page])
        
      case .CurrentEventsByPage(let page):
        return ("GET", "/api/events/current", ["page": page])
        
      case .Scoreboard:
        return ("GET", "/api/scoreboard", nil)
        
      case .ActionsByPage(let page, let targetType, let targetId):
        return ("GET", "/api/actions/\(targetType)/\(targetId)", ["page": page])
        
      case .TeamScore(let team, let op, let value):
        return ("PUT", "/api/teams/\(team.teamId)/score", ["operator": op, "value": value])
      case .ContactScore(let contact, let op, let value):
        return ("PUT", "/api/contacts/\(contact.contactId)/score", ["operator": op, "value": value])
      }
    }()
    
    let url = NSURL(string: Constants.baseUrl)!
    let request = NSMutableURLRequest(URL: url.URLByAppendingPathComponent(result.url))
    request.HTTPMethod = result.method
    
    print(request.URL)
    
    if let accessToken = Auth.sharedInstance.accessToken {
      request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    }
    
    let encoding = Alamofire.ParameterEncoding.URLEncodedInURL
    return encoding.encode(request, parameters: result.parameters).0
  }
}
