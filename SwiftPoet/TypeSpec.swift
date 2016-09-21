//
//  ClassSpec.swift
//  SwiftPoet
//
//  Created by Jupiter on 9/15/16.
//  Copyright © 2016 Jupiter. All rights reserved.
//

import Foundation
public enum TypeKind: String {
  case CLASS = "class"
  case PROTOCOL = "protocol"
  case STRUCT = "struct"
  case ENUM = "enum"
  case EXTENSION = "extension"
}

public enum TypeBuilderError: ErrorType {
  case InvalidSuperTypeError(cause: String)
  case InvalidMethodType(cause: String)
  case InvalidEnumConstantParam(cause: String)
}

// For building class, protocol, struct, enum, extension
public class TypeSpec : SwiftComponentWriter {
  let type: TypeKind
  let name: String
  let superType : [String]
  let methodList : [MethodSpec]
  let propertyList : [VariableSpec]
  let innerTypeList : [TypeSpec]
  let modifiers : [TypeModifier]
  let enumCases : [EnumConstantSpec]
  
  public static func newClass(name: String) -> TypeSpecBuilder {
    return TypeSpecBuilder(type: TypeKind.CLASS, name: name)
  }
  
  public static func newProtocol(name: String) -> TypeSpecBuilder {
    return TypeSpecBuilder(type: TypeKind.PROTOCOL, name: name)
  }
  
  public static func newStruct(name: String) -> TypeSpecBuilder {
    return TypeSpecBuilder(type: TypeKind.STRUCT, name: name)
  }
  
  public static func newEnum(name: String, indirect: Bool = false) -> TypeSpecBuilder {
    return TypeSpecBuilder(type: TypeKind.ENUM, name: name)
  }
  
  public static func newExtension(ofType: String) -> TypeSpecBuilder {
    return TypeSpecBuilder(type: TypeKind.EXTENSION, name: ofType)
  }
  
  init(type: TypeKind, name: String, superType: [String], modifiers: [TypeModifier], methodList: [MethodSpec] = [], propertyList: [VariableSpec] = [],
       innerTypeList: [TypeSpec] = [], enumCases: [EnumConstantSpec]) {
    self.name = name
    self.superType = superType
    self.methodList = methodList
    self.propertyList = propertyList
    self.innerTypeList = innerTypeList
    self.type = type
    self.modifiers = modifiers
    self.enumCases = enumCases
  }
  
  func emit(codeWriter: CodeWriter) {
    codeWriter
      .emitModifiers(modifiers)
      .emit(type.rawValue)
      .emit(" \(name)")
    if (!superType.isEmpty) {
      codeWriter.emit(" : ")
      codeWriter.emit(superType.joinWithSeparator(", "))
    }
    codeWriter.emit(" {\n")
      .indent()
    
    enumCases.forEach { enumConstant in
      enumConstant.emit(codeWriter)
      codeWriter.emit("\n")
    }
    
    propertyList.forEach { property in
      property.emit(codeWriter)
      codeWriter.emit("\n")
    }
    
    //Separator to make code easier to look at
    if (!propertyList.isEmpty) {
      codeWriter.emit("\n")
    }
    
    methodList.forEach { (method) in
      method.emit(codeWriter)
      codeWriter.emit("\n")
    }
    
    innerTypeList.forEach { (innerType) in
      innerType.emit(codeWriter)
      codeWriter.emit("\n")
    }
    
    codeWriter
      .unindent()
      .emit("}")
      .emit("\n")
  }
}


public class TypeSpecBuilder {
  let type: TypeKind
  let name: String
  var superClasses = [String]()
  var typeProperties = [VariableSpec]()
  var typeMethod = [MethodSpec]()
  var innerTypeList = [TypeSpec]()
  var typeModifiers = [TypeModifier]()
  var enumCases = [EnumConstantSpec]()
  
  init(type: TypeKind, name: String) {
    self.type = type
    self.name = name
  }
  
  public func addProperty(propertySpec: VariableSpec) -> TypeSpecBuilder {
    typeProperties.append(propertySpec)
    return self
  }
  
  public func addMethod(methodSpec: MethodSpec) -> TypeSpecBuilder {
    typeMethod.append(methodSpec)
    return self
  }
  
  public func addInnerType(typeSpec: TypeSpec) -> TypeSpecBuilder {
    innerTypeList.append(typeSpec)
    return self
  }
  
  public func superClass(superClass: String...) -> TypeSpecBuilder {
    superClasses.appendContentsOf(superClass)
    return self
  }
  
  public func modifier(modifiers: TypeModifier...) -> TypeSpecBuilder {
    typeModifiers.appendContentsOf(modifiers)
    return self
  }
  
  public func build() throws -> TypeSpec {
    try checkMethodOfType()
    try checkEnumCases()
    return TypeSpec(type: type, name: name, superType: superClasses, modifiers: typeModifiers, methodList: typeMethod,
                    propertyList: typeProperties, innerTypeList: innerTypeList, enumCases: enumCases)
  }
  
  private func checkEnumCases() throws {
    if (type != TypeKind.ENUM && !enumCases.isEmpty) {
      throw TypeBuilderError.InvalidEnumConstantParam(cause: "Enum constants are only allowed inside enum type")
    }
  }
  private func checkMethodOfType() throws {
    if (type == TypeKind.PROTOCOL) {
      for method in typeMethod {
        if (!method.isAbstractMethod) {
          throw TypeBuilderError.InvalidMethodType(cause: "Only abstract method is allowed inside protocol")
        }
      }
    }
  }
}

//Enum
extension TypeSpecBuilder {
  public func addEnumConstant(enumConstant: EnumConstantSpec) -> TypeSpecBuilder {
    enumCases.append(enumConstant)
    return self
  }
}



