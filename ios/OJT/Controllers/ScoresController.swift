//
//  ScoresController.swift
//  OJT
//
//  Created by Rob Hendriks on 22/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import UIKit

enum ScoresMode : CustomStringConvertible {
  case Team, Contact
  
  var description: String {
    switch self {
    case .Team:
      return "Teams"
    case .Contact:
      return  "Kinderen"
    }
  }
}

class ScoresController : UITableViewController {
  
  var barButtonItem: UIBarButtonItem?
  
  var selectedTargetType: String?
  var selectedTargetId: String?
  
  var players: [Player]?
  var mode: ScoresMode?
  
  var working: Bool = false {
    didSet {
      updateUI()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
    fetchScores()
  }
  
  private func configure() {
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(ScoresController.fetchScores), forControlEvents: .ValueChanged)
  }
  
  func fetchScores() {
    if mode == .Team {
      fetchTeams()
    } else if mode == .Contact {
      fetchContacts()
    }
  }
  
  private func fetchTeams() {
    working = true
    TeamService.byPage { teams, error in
      dispatch_async(dispatch_get_main_queue()) {
        self.working = false
        let result = teams?.map { team in
          return team as Player
        }
        self.endFetching(result)
      }
    }
  }
  
  private func fetchContacts() {
    working = true
    ContactService.childrenByPage { contacts, error in
      dispatch_async(dispatch_get_main_queue()) {
        self.working = false
        let result = contacts?.map { contact in
          return contact as Player
        }
        self.endFetching(result)
      }
    }
  }
  
  private func endFetching(result: [Player]?) {
    if let result = result {
      players = result
      tableView.reloadData()
      refreshControl?.endRefreshing()
    }
  }
  
  private func updateScore(indexPath: NSIndexPath, _ operation: Operation, _ amount: Float) {
    working = true
    players?[indexPath.row].updateScore(operation, amount) { value, error in
      dispatch_async(dispatch_get_main_queue()) {
        self.working = false
        self.updateScoreFor(indexPath, value)
      }
    }
  }
  
  private func updateScoreFor(indexPath: NSIndexPath, _ value: Float?) {
    if let value = value {
      players?[indexPath.row].score = value
    }
    
    tableView.beginUpdates()
    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    tableView.endUpdates()
    
    NSNotificationCenter.defaultCenter().postNotificationName("RefreshScoreboard", object: nil)
  }
  
  private func showInput(callback: (Float) -> Void) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    
    alert.addAction(UIAlertAction(title: "5 punten", style: .Default) { action in callback(5) })
    alert.addAction(UIAlertAction(title: "10 punten", style: .Default) { action in callback(10) })
    alert.addAction(UIAlertAction(title: "20 punten", style: .Default) { action in callback(20) })
    
    alert.addAction(UIAlertAction(title: "Annuleren", style: .Cancel, handler: nil))
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  private func increaseScore(indexPath: NSIndexPath) {
    showInput { amount in
      self.updateScore(indexPath, .Add, amount)
    }
  }
  
  private func decreaseScore(indexPath: NSIndexPath) {
    showInput { amount in
      self.updateScore(indexPath, .Subtract, amount)
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
  
  // MARK: - Table View
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return players?.count ?? 0
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    
    if let player = players?[indexPath.row] {
      cell.textLabel?.text = player.name
      cell.detailTextLabel?.text = String(format: "%.0f punt%@", player.score, (player.score != 1) ? "en" : "")
    }
    
    return cell
  }
  
  override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    // Add
    let add = UITableViewRowAction(style: .Normal, title: "+1") { action, index in
      self.updateScore(indexPath, .Add, 1.0)
    }
    add.backgroundColor = UIColor.greenTintColor()
    
    // Remove
    let remove = UITableViewRowAction(style: .Normal, title: "-1") { action, index in
      self.updateScore(indexPath, .Subtract, 1.0)
    }
    remove.backgroundColor = UIColor.tintColor()
    
    // More
    let more = UITableViewRowAction(style: .Normal, title: "Meer") { action, index in
      let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
      
      // Add
      alert.addAction(UIAlertAction(title: "Punten Toevoegen", style: .Default) { action in
        self.increaseScore(indexPath)
      })
      
      // Subtract
      alert.addAction(UIAlertAction(title: "Punten Verwijderen", style: .Default) { action in
        self.decreaseScore(indexPath)
      })
      
      // Cancel
      alert.addAction(UIAlertAction(title: "Annuleren", style: .Cancel, handler: nil))
      self.presentViewController(alert, animated: true, completion: nil)
    }
    
    return [add, remove, more]
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    if let team = players?[indexPath.row] as? Team {
      selectedTargetType = "team"
      selectedTargetId = team.teamId
    } else if let contact = players?[indexPath.row] as? Contact {
      selectedTargetType = "contact"
      selectedTargetId = contact.contactId
    }
    
    if let _ = selectedTargetType, _ = selectedTargetId {
      performSegueWithIdentifier("ShowActions", sender: self)
    }
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowActions" {
      let actionsController = segue.destinationViewController as! ActionsController
      actionsController.targetType = selectedTargetType
      actionsController.targetId = selectedTargetId
    }
  }
}