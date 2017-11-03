//
//  NSDate+ISO.swift
//  OJT
//
//  Created by Rob Hendriks on 18/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import Foundation

extension NSDate {
  var shortDateString: String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "d MMM"
    dateFormatter.timeZone = NSTimeZone.localTimeZone()
    return dateFormatter.stringFromDate(self)
  }
  
  var shortString: String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "d MMM HH:mm"
    dateFormatter.timeZone = NSTimeZone.localTimeZone()
    return dateFormatter.stringFromDate(self)
  }
  
  class func fromISOString(ISOString: String) -> NSDate? {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    dateFormatter.timeZone = NSTimeZone.localTimeZone()
    return dateFormatter.dateFromString(ISOString)
  }
}