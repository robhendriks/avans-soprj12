//
//  ScoreboardController.swift
//  OJT
//
//  Created by Rob Hendriks on 22/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import Foundation
import UIKit
import ContactsUI

class ScoreboardController : UITableViewController {

  let labels = ["1e", "2e", "3e"]
  let colors = [UIColor.goldColor(), UIColor.silverColor(), UIColor.bronzeColor()]
  
  var barButtonItem: UIBarButtonItem?
  
  var scoreboard: Scoreboard?
  var selectedTargetId: String?
  var selectedTargetType: String?
  var selectedMode: ScoresMode?
  
  var working: Bool = false {
    didSet {
      updateUI()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
    fetchScoreboard()
  }
  
  private func configure() {
    navigationItem.title = "Scorebord"
    
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(ScoreboardController.fetchScoreboard), forControlEvents: .ValueChanged)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScoreboardController.receivedNotification), name: "RefreshScoreboard", object: nil)
  }
  
  func fetchScoreboard() {
    if !working {
      working = true
      ScoreboardService.get { scoreboard, error in
        dispatch_async(dispatch_get_main_queue()) {
          self.working = false
          if let scoreboard = scoreboard {
            self.scoreboard = scoreboard
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
          }
        }
      }
    }
  }
  
  private func updateUI() {
    if working {
      barButtonItem = navigationItem.rightBarButtonItem
      
      let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
      indicator.startAnimating()
      
      navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)
    } else {
      navigationItem.rightBarButtonItem = barButtonItem
      barButtonItem = nil
    }
  }
  
  private func showTeamScores(action: UIAlertAction) {
    selectedMode = .Team
    performSegueWithIdentifier("ShowScores", sender: self)
  }
  
  private func showContactScores(action: UIAlertAction) {
    selectedMode = .Contact
    performSegueWithIdentifier("ShowScores", sender: self)
  }
  
  @IBAction func tapRefresh(sender: AnyObject) {
    fetchScoreboard()
  }
  
  @IBAction func tapAdd(sender: AnyObject) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    alert.addAction(UIAlertAction(title: "Teams", style: .Default, handler: showTeamScores))
    alert.addAction(UIAlertAction(title: "Kinderen", style: .Default, handler: showContactScores))
    alert.addAction(UIAlertAction(title: "Annuleren", style: .Cancel, handler: nil))
    presentViewController(alert, animated: true, completion: nil)
  }
  
  // MARK: notifications
  
  func receivedNotification() {
    fetchScoreboard()
  }
  
  // MARK: - Table View
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0: return scoreboard?.teams?.count ?? 0
    case 1: return scoreboard?.contacts?.count ?? 0
    default: return 0
    }
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0: return "Top 5 teams"
    case 1: return "Top 10 individueel"
    default: return nil
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ScoreboardCell
    
    if indexPath.section == 0 {
      let team = scoreboard?.teams?[indexPath.row]
      cell.nameLabel.text = team!.name
      cell.scoreLabel.text = String(format: "%.0f punt%@", team!.score, (team!.score != 1 ? "en" : ""))
    } else if indexPath.section == 1 {
      let contact = scoreboard?.contacts?[indexPath.row]
      cell.nameLabel.text = contact!.name
      cell.scoreLabel.text = String(format: "%.0f punt%@", contact!.score, (contact!.score != 1 ? "en" : ""))
    }
    
    if let color = colors[safe: indexPath.row], label = labels[safe: indexPath.row] {
      cell.trophyLabel.text = label
      cell.trophyImage.tintColor = color
    } else {
      cell.trophyLabel.hidden = true
      cell.trophyImage.hidden = true
    }
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    if indexPath.section == 0 {
      selectedTargetType = "team"
      selectedTargetId = scoreboard?.teams?[indexPath.row].teamId
    } else if indexPath.section == 1 {
      selectedTargetType = "contact"
      selectedTargetId = scoreboard?.contacts?[indexPath.row].contactId
    }
    
    performSegueWithIdentifier("ShowActions", sender: self)
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowActions" {
      let actionsController = segue.destinationViewController as! ActionsController
      actionsController.targetType = selectedTargetType
      actionsController.targetId = selectedTargetId
    } else if segue.identifier == "ShowScores" {
      let scoresController = segue.destinationViewController as! ScoresController
      scoresController.mode = selectedMode
      scoresController.navigationItem.title = selectedMode!.description
    }
  }
  
}
