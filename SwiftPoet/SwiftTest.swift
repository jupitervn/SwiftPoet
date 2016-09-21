//
//  SwiftTest.swift
//  SwiftPoet
//
//  Created by Jupiter on 9/13/16.
//  Copyright © 2016 Jupiter. All rights reserved.
//

import Foundation
public enum BAC {
  case upd(Int , Int, Int), abc(Int)
}

public enum TEST: Int {
  case NAME = 0
  case FIRST
  case LAST
  case FULL
}

protocol ABC {
   
  var a: String {
    get
  }
  
}

protocol DEF {
  func getABC() -> String
}

class ABCImpl : ABC, DEF {
  var a: String {
    get {
      return "abc"
    }
  }
  func getABC() -> String {
    return ""
  }
}
var abc: String {
get {
  return "bce"
}



}

class A {
  var def = { return "DEF"}
  
}









