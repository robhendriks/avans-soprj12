//
//  LoginController.swift
//  OJT
//
//  Created by Rob Hendriks on 11/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import SwiftOverlays

class LoginController : FormViewController {
  // MARK: Outlets
  @IBOutlet weak var cancelButton: UIBarButtonItem!
  
  // MARK: - Properties
  
  private var working: Bool = false {
    didSet {
      if working {
        SwiftOverlays.showBlockingWaitOverlay()
      } else {
        SwiftOverlays.removeAllBlockingOverlays()
      }
    }
  }
  
  // MARK: - UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Inloggen"
    createForm()
  }
  
  // MARK: - Methods
  
  private func createForm() {
    form +++ Section()
      <<< EmailRow("Email") {
        $0.placeholder = "E-mailadres"
      }
      <<< PasswordRow("Password") {
        $0.placeholder = "Wachtwoord"
      }
    
    form +++ Section()
      <<< ButtonRow("Submit") {
        $0.title = "Inloggen"
        $0.cellUpdate { (cell, row) in cell.textLabel?.textAlignment = .Left }
        $0.onCellSelection { (cell, row) in self.submitForm() }
      }
  }
  
  private func submitForm() {
    let values = form.values()
    let email = ((values["Email"] as! String?) ?? "").stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    let password = ((values["Password"] as! String?) ?? "").stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    
    var errors = [String]()
    if email.isEmpty {
      errors.append("E-mailadres leeg.")
    }
    if password.isEmpty {
      errors.append("Wachtwoord leeg.")
    }
    
    guard errors.isEmpty else {
      return showAlert("Fout", errors.joinWithSeparator("\n"))
    }
    
    working = true
    
    Auth.sharedInstance.authenticate(email, password) { user, error in
      dispatch_async(dispatch_get_main_queue()) {
        self.working = false
        
        if let _ = error {
          self.showAlert("Fout", "Kan niet inloggen.")
        } else if let user = user {
          let identifier: String? = {
            switch user.contact.type {
            case .Leader:
              return "Leader"
            case .Parent:
              return "Parent"
            default:
              return nil
            }
          }()
          
          if let identifier = identifier {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewControllerWithIdentifier(identifier)
            
            self.presentViewController(viewController, animated: true, completion: nil)
          }
        } else {
          self.showAlert("Fout", "Onbekende fout.")
        }
      }
    }
  }
  
  // MARK: - Actions
  
  @IBAction func performCancel(sender: AnyObject) {
    self.tableView?.endEditing(true)
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}
