//
//  CollectionType+Safe.swift
//  OJT
//
//  Created by Rob Hendriks on 22/05/16.
//  Copyright © 2016 Rob Hendriks. All rights reserved.
//

extension CollectionType {
  subscript (safe index: Index) -> Generator.Element? {
    return indices.contains(index) ? self[index] : nil
  }
}