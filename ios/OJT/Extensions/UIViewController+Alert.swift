//
//  UIViewController+Alert.swift
//  OJT
//
//  Created by Rob Hendriks on 17/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import UIKit

extension UIViewController {
  func showAlert(title: String, _ message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "Sluiten", style: .Cancel, handler: nil))
    presentViewController(alert, animated: true, completion: nil)
  }
}