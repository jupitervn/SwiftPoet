//
//  EnumSpec.swift
//  SwiftPoet
//
//  Created by Jupiter on 9/21/16.
//  Copyright © 2016 Jupiter. All rights reserved.
//

import Foundation

public class EnumConstantSpec : SwiftComponentWriter {
  let name: String
  let caseParams : [EnumTupleSpec]
  let value: String?
  let isIndirect: Bool
  
  init(name: String, value: String?, caseParams: [EnumTupleSpec] = [], isIndirect: Bool = false) {
    self.name = name
    self.caseParams = caseParams
    self.isIndirect = isIndirect
    self.value = value
  }
  
  func emit(codeWriter: CodeWriter) {
    codeWriter
      .emit(isIndirect ? "indirect " : "")
      .emit("case ")
      .emit(name)
    if (!caseParams.isEmpty) {
      codeWriter.emit("(")
      var delimeter = ""
      caseParams.forEach({ (tupleSpec) in
        codeWriter.emit(delimeter)
        tupleSpec.emit(codeWriter)
        delimeter = ", "
      })
      codeWriter.emit(")")
    }
    if let value = value {
      codeWriter.emit(" = \(value)")
    }
    
  }
  
  public static func newEnumValue(name: String) -> EnumConstantSpecBuilder {
    return EnumConstantSpecBuilder(name: name)
  }
}

public class EnumConstantSpecBuilder {
  let name: String
  var isIndirect: Bool = false
  var tupleSpecs = [EnumTupleSpec]()
  var enumValue: String? = nil
  
  public init(name: String) {
    self.name = name
  }
  
  public func addTuple(tupleSpec: EnumTupleSpec) -> EnumConstantSpecBuilder {
    tupleSpecs.append(tupleSpec)
    return self
  }
  
  public func value(value: String) -> EnumConstantSpecBuilder {
    self.enumValue = value
    return self
  }
  
  public func indirect() -> EnumConstantSpecBuilder {
    isIndirect = true
    return self
  }
  
  public func build() -> EnumConstantSpec {
    return EnumConstantSpec(name: name, value: enumValue, caseParams: tupleSpecs, isIndirect: isIndirect)
  }
}

public class EnumTupleSpec : SwiftComponentWriter {
  let name: String?
  let type: String
  
  public init(name: String? = nil, type: String) {
    self.name = name
    self.type = type
  }
  
  func emit(codeWriter: CodeWriter) {
    if let name = name {
      codeWriter.emit("\(name): ")
    }
    codeWriter.emit(type)
  }
}
