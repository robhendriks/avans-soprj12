//
//  DummyController.swift
//  OJT
//
//  Created by Rob Hendriks on 13/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import UIKit
import SwiftOverlays

class DummyController : UIViewController {
  // MARK: UIViewController
  override func viewDidLoad() {
    super.viewDidLoad()
  
    Auth.sharedInstance.prepare { user in
      dispatch_async(dispatch_get_main_queue()) {
        var identifier = "Welcome"
        
        if let user = user {
          switch user.contact.type {
          case .Parent:
            identifier = "Parent"
          case .Leader:
            identifier = "Leader"
          default:
            print("Unknown contact type")
          }
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier(identifier)
        self.presentViewController(viewController, animated: false, completion: nil)
      }
    }
  }
}
