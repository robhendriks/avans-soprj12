//
//  ChildrenController.swift
//  OJT
//
//  Created by Rob Hendriks on 14/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import UIKit
import ContactsUI

class ChildrenController : UITableViewController {
  // MARK: Properties
  var children: [Contact]?
  var child: Contact?
  
  // MARK: - UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - UITableView
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let children = children {
      return children.count
    }
    return 0
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    
    if let child = children?[indexPath.row] {
      cell.textLabel?.text = child.name
    }
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    if let child = children?[indexPath.row] {
      let contactViewController = CNContactViewController(forUnknownContact: child.createContact())
      contactViewController.allowsEditing = false
      contactViewController.allowsActions = false
      contactViewController.navigationItem.title = child.name
      
      self.navigationController?.pushViewController(contactViewController, animated: true)
    }
  }
}
