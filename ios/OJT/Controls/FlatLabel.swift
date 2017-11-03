//
//  FlatLabel.swift
//  OJT
//
//  Created by Rob Hendriks on 22/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

import UIKit

@IBDesignable class FlatLabel : UILabel {
  @IBInspectable var topInset: CGFloat = 5.0
  @IBInspectable var leftInset: CGFloat = 5.0
  @IBInspectable var bottomInset: CGFloat = 5.0
  @IBInspectable var rightInset: CGFloat = 5.0
  
  @IBInspectable var cornerRadius: CGFloat = 5 {
    didSet {
      layer.cornerRadius = cornerRadius
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }
  
  private func configure() {
    self.textColor = UIColor.whiteColor()
    self.backgroundColor = UIColor.blackColor()
    self.clipsToBounds = true
  }
  
  override func intrinsicContentSize() -> CGSize {
    var size = super.intrinsicContentSize()
    size.width += topInset + bottomInset
    size.height += leftInset + rightInset
    return size
  }
  
  override func drawTextInRect(rect: CGRect) {
    super.drawTextInRect(UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(topInset, leftInset, bottomInset, rightInset)))
  }
}
