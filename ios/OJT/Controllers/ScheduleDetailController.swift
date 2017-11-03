//
//  ScheduleDetailController.swift
//  OJT
//
//  Created by Rob Hendriks on 18/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import UIKit

class ScheduleDetailController : UITableViewController {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var fromLabel: UILabel!
  @IBOutlet weak var toLabel: UILabel!
  
  var schedule: Schedule?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "Activiteit"
    updateUI()
  }
  
  private func updateUI() {
    if let schedule = schedule {
      nameLabel.text = schedule.name
      fromLabel.text = schedule.starts
      toLabel.text = schedule.ends
    }
  }
}
