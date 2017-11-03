//
//  Player.swift
//  OJT
//
//  Created by Rob Hendriks on 22/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import Foundation

enum Operation: CustomStringConvertible {
  case Add, Subtract
  
  var description: String {
    switch self {
    case .Add: return "+"
    case .Subtract: return "-"
    }
  }
}

protocol Player {
  var name: String {get}
  var score: Float {get set}
  
  func updateScore(operation: Operation, _ value: Float, _ callback: (Float?, NSError?) -> Void)
}