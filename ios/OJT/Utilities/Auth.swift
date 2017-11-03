//
//  Auth.swift
//  OJT
//
//  Created by Rob Hendriks on 13/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import Alamofire
import SwiftyJSON

class Auth {
  static let sharedInstance = Auth()
  
  private(set) var accessToken: String? {
    didSet {
      save()
    }
  }
  private(set) var user: User?
  
  private init() {
    load()
  }
  
  private func load() {
    let defaults = NSUserDefaults.standardUserDefaults()
    if let accessToken = defaults.stringForKey("accessToken") {
      self.accessToken = accessToken
    }
  }
  
  private func save() {
    let defaults = NSUserDefaults.standardUserDefaults()
    if let accessToken = self.accessToken {
      defaults.setObject(accessToken, forKey: "accessToken")
    }
  }
  
  func prepare(callback: (User?) -> Void) {
    UserService.me { user, _ in
      if let user = user {
        self.user = user
        callback(user)
      } else {
        callback(nil)
      }
    }
  }
  
  func authenticate(username: String, _ password: String, _ callback: (User?, NSError?) -> Void) {
    let parameters = [
      "client_id": Constants.clientId,
      "client_secret": Constants.clientSecret,
      "grant_type": "password",
      "username": username,
      "password": password
    ]
    
    Requests.manager.request(.POST, Constants.baseUrl + "/oauth/token", parameters: parameters)
      .validate()
      .responseData { response in
        switch response.result {
        case .Failure(let error):
            callback(nil, error)
        case .Success(let value):
          let json = JSON(data: value)
          if let accessToken = json["access_token"].string {
            self.accessToken = accessToken
          }
          
          UserService.me { user, error in
            if let user = user {
              self.user = user
              return callback(user, nil)
            }
            callback(nil, error)
          }
        }
      }
  }
  
  func logout() {
    self.accessToken = nil
    self.user = nil
    
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.removeObjectForKey("accessToken")
  }
  
  func authenticated() -> Bool {
    return user != nil
  }
}
