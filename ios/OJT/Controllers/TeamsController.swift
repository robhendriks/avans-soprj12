//
//  TeamsController.swift
//  OJT
//
//  Created by Rob Hendriks on 18/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import UIKit
import SwiftOverlays

class TeamsController : UITableViewController {
  
  var teams: [Team]?
  var selectedTeam: Team?
  
  var working: Bool = false {
    didSet {
      updateOverlay()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
    fetchTeams()
  }
  
  private func configure() {
    navigationItem.title = "Teams"
  }
  
  private func fetchTeams() {
    if !working {
      working = true
      TeamService.byPage { teams, error in
        dispatch_async(dispatch_get_main_queue()) {
          self.working = false
          if let teams = teams {
            self.teams = teams
            self.tableView.reloadData()
          }
        }
      }
    }
  }

  private func updateOverlay() {
    if working {
      showWaitOverlay()
    } else {
      removeAllOverlays()
    }
  }
  
  // MARK: - Table View
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return teams?.count ?? 0
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    let team = teams?[indexPath.row]
    cell.textLabel?.text = team?.name
    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    if let team = teams?[indexPath.row] {
      selectedTeam = team
      performSegueWithIdentifier("ShowTeamDetail", sender: self)
    }
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowTeamDetail" {
      let teamDetailController = segue.destinationViewController as! TeamDetailController
      teamDetailController.navigationItem.title = selectedTeam!.name
      teamDetailController.team = selectedTeam
    }
  }
  
}
