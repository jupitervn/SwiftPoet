//
//  FieldSpec.swift
//  SwiftPoet
//
//  Created by Jupiter on 9/13/16.
//  Copyright © 2016 Jupiter. All rights reserved.
//

import Foundation

public class VariableSpec : SwiftComponentWriter {
  public let name: String
  
  let fieldType:String?
  let initializer: CodeBlock?
  let modifiers:[FieldModifier]
  var canBeModified: Bool
  let initCodeBlock : [String: CodeBlock?]?
  
  private init(name:String, fieldType:String? = nil, initializer:CodeBlock? = nil, modifiers:[FieldModifier] = [], canBeModified:Bool = false,
               initBlock: [String: CodeBlock?]? = nil) {
    self.name = name
    self.fieldType = fieldType
    self.initializer = initializer
    self.modifiers = modifiers
    self.canBeModified = canBeModified
    self.initCodeBlock = initBlock
  }
  
  func emit(codeWriter: CodeWriter) {
    let codeWriter = codeWriter
      .emitModifiers(modifiers)
      .emit(canBeModified ? "var " : "let ")
      .emit(name)
      .emit(fieldType?.prepend(": ") ?? "")
    if let initializer = initializer {
      codeWriter
          .emit(" = ")
          .emit(initializer)
      
    }
    if !(initCodeBlock?.isEmpty ?? true) {
      codeWriter.emit(" {\n")
      initCodeBlock?.forEach({ (string, codeBlock) in
        codeWriter.emit(string)
        if let codeBlock = codeBlock {
          codeWriter.emit(" {\n")
          .emit(codeBlock)
          .emit("\n}\n")
        }
      })
      codeWriter.emit("}")
    }
  }
}

public class FieldSpecBuilder {
  let name: String
  let fieldType: String?
  var initializer: CodeBlock?
  var modifiers = [FieldModifier]()
  var canBeModified = false
  var initCodeBlock = [String: CodeBlock?]()
  
  public init(name:String, fieldType: String? = nil) {
    self.name = name
    self.fieldType = fieldType
  }
  
  public func initWith(initializer: CodeBlock?) -> FieldSpecBuilder {
    self.initializer = initializer
    return self
  }
  
  public func initWith(initializer: String?) -> FieldSpecBuilder {
    self.initializer = CodeBlock.newCodeBlock(initializer)
    return self
  }
  
  public func modifiable() -> FieldSpecBuilder {
    self.canBeModified = true
    return self
  }
  
  public func addModifier(fieldModifiers: FieldModifier...) -> FieldSpecBuilder {
    self.modifiers.appendContentsOf(fieldModifiers)
    return self
  }
  
  public func getter(codeBlock: CodeBlock?) -> FieldSpecBuilder {
    initCodeBlock["get"] = codeBlock
    return self
  }
  
  public func setter(varName: String? = nil, codeBlock: CodeBlock?) -> FieldSpecBuilder {
    initCodeBlock["set".append(varName != nil ? "(\(varName))" : "")] = codeBlock
    return self
  }
  
  public func willSet(varName: String? = nil, codeBlock: CodeBlock?) -> FieldSpecBuilder {
    initCodeBlock["willSet".append(varName != nil ? "(\(varName))" : "")] = codeBlock
    return self
  }
  
  public func didSet(codeBlock: CodeBlock) -> FieldSpecBuilder {
    initCodeBlock["didSet"] = codeBlock
    return self
  }
  
  public func build() -> VariableSpec {
    return VariableSpec(name: name, fieldType: fieldType, initializer: initializer,modifiers: modifiers, canBeModified: canBeModified, initBlock: initCodeBlock)
  }

}

