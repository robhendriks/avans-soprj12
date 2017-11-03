//
//  Networking.swift
//  OJT
//
//  Created by Rob Hendriks on 13/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import Alamofire

class Requests {
  static let manager: Manager = {
    let policies: [String: ServerTrustPolicy] = [
      "ojt.robhendriks.co": .DisableEvaluation
    ]
    
    return Manager(
      serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies)
    )
  }()
}