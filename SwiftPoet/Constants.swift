//
//  Constants.swift
//  SwiftPoet
//
//  Created by Jupiter on 9/14/16.
//  Copyright © 2016 Jupiter. All rights reserved.
//

import Foundation
public protocol Modifier {
    func value() -> String
}

public enum FieldModifier: String, Modifier {
  case PUBLIC = "public"
  case PRIVATE = "private"
  case STATIC = "static"
  case LAZY = "lazy"
  case DYNAMIC = "dynamic"
  public func value() -> String {
    return rawValue
  }
}

public enum TypeModifier: String, Modifier {
  case PUBLIC = "public"
  case PRIVATE = "private"
  case FILE = "fileprivate"
  case INTERNAL = "internal"
  case STATIC = "static"
  case OVERRIDE = "override"
  case INDIRECT = "indirect"
  case CONVENIENCE = "convenience"
  case MUTATING = "mutating"
  public func value() -> String {
    return rawValue
  }
  
}
