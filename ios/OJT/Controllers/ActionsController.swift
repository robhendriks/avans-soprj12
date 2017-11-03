//
//  ActionsController.swift
//  OJT
//
//  Created by Rob Hendriks on 22/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import UIKit

class ActionsController : UITableViewController {
  
  var barButtonItem: UIBarButtonItem?
  
  var targetType: String?
  var targetId: String?
  var actions: [Action]?
  
  var working: Bool = false {
    didSet {
      updateUI()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
    fetchActions()
  }
  
  private func configure() {
    navigationItem.title = "Bewerkingen"
    
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(ActionsController.fetchActions), forControlEvents: .ValueChanged)
  }
  
  func fetchActions() {
    if !working {
      working = true
      ActionService.byPage(targetType ?? "", targetId ?? "") { actions, error in
        dispatch_async(dispatch_get_main_queue()) {
          self.working = false
          if let actions = actions {
            self.actions = actions
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
  
  @IBAction func tapRefresh(sender: AnyObject) {
    fetchActions()
  }
  
  // MARK: - Table View
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return actions?.count ?? 0
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Laatste bewerkingen"
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ActionCell
    
    if let action = actions?[indexPath.row] {
      cell.nameLabel.text = action.originator.contact.name
      cell.dateLabel.text = action.created?.shortString
      
      let oldValue = action.args["old"].floatValue
      let newValue = action.args["new"].floatValue
      
      if newValue > oldValue {
        cell.changeLabel.backgroundColor = UIColor.greenTintColor()
        cell.changeLabel.text = String(format: "+ %.0f", newValue - oldValue)
      } else {
        cell.changeLabel.backgroundColor = UIColor.tintColor()
        cell.changeLabel.text = String(format: "- %.0f", oldValue - newValue)
      }
      
      cell.oldLabel.text = String(format: "%.0f", oldValue)
      cell.newLabel.text = String(format: "%.0f", newValue)
    }
    
    return cell
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // TODO
  }
  
}
