//
//  MethodSpec.swift
//  SwiftPoet
//
//  Created by Jupiter on 9/14/16.
//  Copyright © 2016 Jupiter. All rights reserved.
//

import Foundation
//For method
public class MethodSpec : SwiftComponentWriter {
  let name:String
  let modifiers: [TypeModifier]
  let parameters: [ParameterSpec]?
  let returnType: String?
  let methodBlock: CodeBlock?
  let isAbstractMethod: Bool
  let genericClause: String?
  let whereClause: String?
  let isErrorThrown: Bool
  
  init(name: String, isAbstract: Bool = false, modifiers: [TypeModifier] = [], parameters: [ParameterSpec]? = nil,
       returnType: String? = nil, genericClause: String? = nil, whereClause: String? = nil, methodBlock: CodeBlock? = nil, isErrorThrown : Bool = false) {
    self.name = name
    self.modifiers = modifiers
    self.parameters = parameters
    self.returnType = returnType
    self.methodBlock = methodBlock
    self.isAbstractMethod = isAbstract
    self.genericClause = genericClause
    self.whereClause = whereClause
    self.isErrorThrown = isErrorThrown
  }
  
  public static func methodBuilder(name: String, isAbstract: Bool = false) -> MethodSpecBuilder {
    return MethodSpecBuilder(name: name, isAbstract: isAbstract)
  }
  
  public static func initBuilder() -> MethodSpecBuilder {
    return MethodSpecBuilder(name: "init")
  }
  
  public static func optionalInitBuilder() -> MethodSpecBuilder {
    return MethodSpecBuilder(name: "init?")
  }
  
  func emit(codeWriter: CodeWriter) {
    codeWriter.emitModifiers(modifiers)
    codeWriter.emit("init" == name || "init?" == name ? "" : "func ")
      .emit(name)
    if let genericClause = genericClause {
      codeWriter.emit("<\(genericClause)>")
    }
      
    codeWriter.emit("(")
    
    var delimeter = ""
    parameters?.forEach{ (param) in
      codeWriter.emit(delimeter)
      param.emit(codeWriter)
      delimeter = ", "
    }
    
    codeWriter.emit(")")
    
    if (isErrorThrown) {
      codeWriter.emit(" throws")
    }
    if let returnType = returnType {
      codeWriter.emit(" -> \(returnType)")
    }
    if let whereClause = whereClause {
      codeWriter.emit(" where \(whereClause)")
    }
    if (!isAbstractMethod) {
      codeWriter.emit(" {\n")
      if let methodBlock = methodBlock {
        codeWriter.indent()
        methodBlock.emit(codeWriter)
        codeWriter.unindent()
      }
      codeWriter.emit("}\n")
    }
  }
}

public class MethodSpecBuilder {
  let name: String
  var returnType: String?
  var paramList: [ParameterSpec] = [ParameterSpec]()
  var modifiers = [TypeModifier]()
  var methodCode: CodeBlock?
  let isAbstract: Bool
  var genericTypeClause: String?
  var whereClause: String?
  var isErrorThrown = false
  
  init(name: String, isAbstract: Bool = false) {
    self.name = name
    self.isAbstract = isAbstract
  }
  
  public func returnType(returnType: String) -> MethodSpecBuilder {
    self.returnType = returnType
    return self
  }
  
  public func addParam(param: ParameterSpec) -> MethodSpecBuilder {
    paramList.append(param)
    return self
  }
  
  public func modifiers(modifiers: TypeModifier...) -> MethodSpecBuilder {
    self.modifiers.appendContentsOf(modifiers)
    return self
  }
  
  public func genericType(genericClause: String) -> MethodSpecBuilder {
    self.genericTypeClause = genericClause
    return self
  }
  
  public func whereClause(whereClause: String) -> MethodSpecBuilder {
    self.whereClause = whereClause
    return self
  }
  
  public func willThrowError() -> MethodSpecBuilder {
    self.isErrorThrown = true
    return self
  }
  
  public func code(codeString:String) -> MethodSpecBuilder {
    return self.code(CodeBlock.newCodeBlock(codeString))
  }
  
  public func code(code: CodeBlock) -> MethodSpecBuilder {
    self.methodCode = code
    return self
  }
  
  public func build() -> MethodSpec {
    return MethodSpec(name: name, isAbstract: isAbstract, modifiers: modifiers,
                      parameters: paramList, returnType: returnType, methodBlock: methodCode,
                      genericClause: genericTypeClause, whereClause: whereClause, isErrorThrown: isErrorThrown)
  }
}

public class ParameterSpec : SwiftComponentWriter {
  let name:String?
  let paramType: String
  let defaultValue: String?
  let argLabel: String?
  let isInOut: Bool
  
  public init(_ name:String?, paramType: String, defaultValue: String? = nil, argLabel: String? = nil, isInOut: Bool = false) {
    self.name = name
    self.paramType = paramType
    self.defaultValue = defaultValue
    if (argLabel == nil && name == nil) {
      self.argLabel = "_"
    } else {
      self.argLabel = argLabel
    }
    self.isInOut = isInOut
  }
  
  func emit(codeWriter: CodeWriter) {
    codeWriter
      .emit(argLabel?.append(" ") ?? "")
      .emit(name ?? "")
      .emit(":")
      .emit(isInOut ? " inout" : "")
      .emit(" \(paramType)")
    
    if let defaultValue = defaultValue {
      codeWriter.emit(" = \(defaultValue)")
    }
  }
}