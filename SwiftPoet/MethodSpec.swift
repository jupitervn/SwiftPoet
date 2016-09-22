//
//  MethodSpec.swift
//  SwiftPoet
//
//  Created by Jupiter on 9/14/16.
//  Copyright © 2016 Jupiter. All rights reserved.
//

import Foundation

public enum MethodType: String {
  case INIT = "init"
  case OPTIONAL_INIT = "init?"
  case SUBSCRIPT = "subscript"
  case NORMAL = "normal"
  case ABSTRACT = "abstract"
}

//For method
public class MethodSpec : SwiftComponentWriter {
  let methodType: MethodType
  let name:String
  let modifiers: [TypeModifier]
  let parameters: [ParameterSpec]?
  let returnType: String?
  let methodBlock: CodeBlock?
  let genericClause: String?
  let whereClause: String?
  let isErrorThrown: Bool
  
  init(_ methodType: MethodType, name: String, modifiers: [TypeModifier] = [], parameters: [ParameterSpec]? = nil,
       returnType: String? = nil, genericClause: String? = nil, whereClause: String? = nil, methodBlock: CodeBlock? = nil, isErrorThrown : Bool = false) {
    self.methodType = methodType
    self.name = name
    self.modifiers = modifiers
    self.parameters = parameters
    self.returnType = returnType
    self.methodBlock = methodBlock
    self.genericClause = genericClause
    self.whereClause = whereClause
    self.isErrorThrown = isErrorThrown
  }
  
  public static func methodBuilder(name: String) -> MethodSpecBuilder {
    return MethodSpecBuilder(MethodType.NORMAL, name: name)
  }
  
  public static func abstractMethodBuilder(name: String) -> MethodSpecBuilder {
    return MethodSpecBuilder(MethodType.ABSTRACT, name: name)
  }
  
  public static func initBuilder() -> MethodSpecBuilder {
    return MethodSpecBuilder(MethodType.INIT, name: "init")
  }
  
  public static func optionalInitBuilder() -> MethodSpecBuilder {
    return MethodSpecBuilder(MethodType.OPTIONAL_INIT, name: "init?")
  }
  
  public static func subscriptBuilder() -> MethodSpecBuilder {
    return MethodSpecBuilder(MethodType.SUBSCRIPT, name: "subscript")
  }
  
  func emit(codeWriter: CodeWriter) {
    codeWriter.emitModifiers(modifiers)
    if (methodType == .NORMAL || methodType == .ABSTRACT) {
      codeWriter.emit("func \(name)")
    } else {
      codeWriter.emit(methodType.rawValue)
    }
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
    if (methodType != .ABSTRACT) {
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
  let methodType: MethodType
  let name: String
  var returnType: String?
  var paramList: [ParameterSpec] = [ParameterSpec]()
  var modifiers = [TypeModifier]()
  var methodCode: CodeBlock?
  var genericTypeClause: String?
  var whereClause: String?
  var isErrorThrown = false
  
  init(_ methodType: MethodType = .NORMAL, name: String) {
    self.methodType = methodType
    self.name = name
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
    return MethodSpec(methodType, name: name, modifiers: modifiers,
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