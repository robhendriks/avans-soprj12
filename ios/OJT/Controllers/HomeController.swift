//
//  LeaderHomeController.swift
//  OJT
//
//  Created by Rob Hendriks on 13/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import UIKit
import SwiftOverlays

class HomeController : UITableViewController {
  // MARK: Outlets
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var typeLabel: UILabel!
  @IBOutlet weak var actionLabel: UILabel!
  
  // MARK: - Properties
  
  var user: User?
  var team: Team?
  var children: [Contact]?
  
  var working: Bool = false {
    didSet {
      if working {
        SwiftOverlays.showCenteredWaitOverlay(view.superview!)
      } else {
        SwiftOverlays.removeAllOverlaysFromView(view.superview!)
      }
    }
  }
  
  // MARK: - UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    user = Auth.sharedInstance.user
    navigationItem.title = "Home"
    populate()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowTeamDetail" {
      let viewController = segue.destinationViewController as! TeamDetailController
      viewController.navigationItem.title = "Mijn Team"
      viewController.team = team
    } else if segue.identifier == "ShowChildren" {
      let viewController = segue.destinationViewController as! ChildrenController
      viewController.navigationItem.title = "Mijn Kinderen"
      viewController.children = children
    }
  }
  
  // MARK: - Methods
  
  private func populate() {
    if let user = user {
      nameLabel.text = user.contact.name
      typeLabel.text = user.contact.type.description
      
      if user.contact.type == .Leader {
        actionLabel.text = "Mijn Team"
      } else if user.contact.type == .Parent {
        actionLabel.text = "Mijn Kinderen"
      }
    }
  }
  
  private func performAction() {
    if user!.contact.type == .Leader {
      showTeam()
    } else if user!.contact.type == .Parent {
      showChildren()
    }
  }
  
  private func showTeam() {
    if let _ = team {
      return self.performSegueWithIdentifier("ShowTeamDetail", sender: self)
    }
    
    working = true
    TeamService.byUser(user!) { team, error in
      dispatch_async(dispatch_get_main_queue()) {
        self.working = false
        if let team = team {
          self.team = team
          self.performSegueWithIdentifier("ShowTeamDetail", sender: self)
        }
      }
    }
  }
  
  private func showChildren() {
    if let _ = children {
      return self.performSegueWithIdentifier("ShowChildren", sender: self)
    }
    
    working = true
    ContactService.byUser(user!) { contacts, error in
      dispatch_async(dispatch_get_main_queue()) {
        if let contacts = contacts {
          self.children = contacts
          self.performSegueWithIdentifier("ShowChildren", sender: self)
        }
      }
    }
  }
  
  private func showLogoutQuestion() {
    let alert = UIAlertController(title: nil, message: "Weet je zeker dat je wilt uitloggen?", preferredStyle: .ActionSheet)
    alert.addAction(UIAlertAction(title: "Ja", style: .Default, handler: performLogout))
    alert.addAction(UIAlertAction(title: "Nee", style: .Default, handler: nil))
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  private func performLogout(action: UIAlertAction) {
    Auth.sharedInstance.logout()
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let viewController = storyboard.instantiateViewControllerWithIdentifier("Welcome")
    presentViewController(viewController, animated: true, completion: nil)
  }
  
  // MARK: - UITableView
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    if indexPath.section == 1 && indexPath.row == 0 {
      performAction()
    } else if indexPath.section == 2 && indexPath.row == 0 {
      showLogoutQuestion()
    }
  }
}
