//
//  TeamController.swift
//  OJT
//
//  Created by Rob Hendriks on 14/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import UIKit
import SwiftOverlays

class TeamDetailController : UITableViewController {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  
  var team: Team?
  var contacts: [Contact]?
  
  var working: Bool = false {
    didSet {
      if working {
        SwiftOverlays.showCenteredWaitOverlay(view.superview!)
      } else {
        SwiftOverlays.removeAllOverlaysFromView(view.superview!)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    populate()
  }
  
  // MARK: - Methods
  
  private func populate() {
    if let team = team {
      nameLabel.text = team.name
      descriptionLabel.text = team.description.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
    }
  }
  
  private func showMembers() {
    if let _ = contacts {
      return performSegueWithIdentifier("ShowChildren", sender: self)
    }
    
    working = true
    
    ContactService.byTeam(team!) { contacts, error in
      dispatch_async(dispatch_get_main_queue()) {
        self.working = false        
        if let contacts = contacts {
          self.contacts = contacts
          self.performSegueWithIdentifier("ShowChildren", sender: self)
        }
      }
    }
  }
  
  // MARK: - Table View
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    if indexPath.section == 1 && indexPath.row == 0 {
      showMembers()
    }
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowChildren" {
      let viewController = segue.destinationViewController as! ChildrenController
      viewController.navigationItem.title = "Teamleden"
      viewController.children = contacts
    }
  }
  
}
