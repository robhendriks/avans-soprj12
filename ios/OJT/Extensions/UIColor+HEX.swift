//
//  UIColor+HEX.swift
//  OJT
//
//  Created by Rob Hendriks on 10/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import UIKit

extension UIColor {
  convenience init(hex: Int) {
    self.init(
      red: CGFloat((hex >> 16) & 0xFF) / 255.0,
      green: CGFloat((hex >> 8) & 0xFF) / 255.0,
      blue: CGFloat(hex & 0xFF) / 255.0,
      alpha: 1.0)
  }
  
}

extension UIColor {
  class func tintColor() -> UIColor {
    return UIColor(hex: 0xDC3522)
  }
  
  class func greenTintColor() -> UIColor {
    return UIColor(hex: 0x45BF55)
  }
  
  class func goldColor() -> UIColor {
    return UIColor(hex: 0xD4AF37)
  }
  
  class func silverColor() -> UIColor {
    return UIColor(hex: 0xC0C0C0)
  }
  
  class func bronzeColor() -> UIColor {
    return UIColor(hex: 0xCD7F32)
  }
}
