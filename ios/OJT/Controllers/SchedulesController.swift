//
//  ScheduleController.swift
//  OJT
//
//  Created by Rob Hendriks on 18/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import UIKit
import SwiftOverlays

class SchedulesController : UITableViewController {
  
  var barButtonItem: UIBarButtonItem?
  
  var events: [Event]?
  var selectedSchedule: Schedule?
  
  var working: Bool = false {
    didSet {
      updateUI()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
    fetchEvents()
  }
  
  private func configure() {
    navigationItem.title = "Planning"
    
    refreshControl = UIRefreshControl()
    refreshControl!.addTarget(self, action: #selector(SchedulesController.fetchEvents), forControlEvents: .ValueChanged)
  }
  
  func fetchEvents() {
    if !working {
      working = true
      EventService.current { events, error in
        dispatch_async(dispatch_get_main_queue()) {
          self.working = false
          self.events = events
          self.tableView.reloadData()
          self.refreshControl?.endRefreshing()
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
    fetchEvents()
  }
  
  // MARK: - Table View
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return events?.count ?? 0
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return events?[section].schedules.count ?? 0
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return events?[section].name
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    
    let schedule = events?[indexPath.section].schedules[indexPath.row]
    cell.textLabel?.text = schedule?.name
    cell.detailTextLabel?.text = schedule?.date?.shortDateString
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    if let event = events?[indexPath.section] {
      selectedSchedule = event.schedules[indexPath.row]
      performSegueWithIdentifier("ShowScheduleDetail", sender: self)
    }
  }

  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowScheduleDetail" {
      let scheduleDetailController = segue.destinationViewController as! ScheduleDetailController
      scheduleDetailController.schedule = selectedSchedule
    }
  }
  
}
