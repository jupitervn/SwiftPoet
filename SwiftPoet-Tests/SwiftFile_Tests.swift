//
//  SwiftFile_Tests.swift
//  SwiftPoet
//
//  Created by Jupiter on 9/16/16.
//  Copyright © 2016 Jupiter. All rights reserved.
//

import XCTest

class SwiftFile_Tests: XCTestCase {
  let testOutputDir = "test_results/"
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  
  func test_shouldEmitSimpleClass() {
    let classSpec = try? TypeSpec.newClass("TestClass")
      .addProperty(FieldSpecBuilder(name: "field01", fieldType: "Int").initWith("1").build())
      .addProperty(FieldSpecBuilder(name: "field02", fieldType: "String").initWith("\"abc\"").build())
      .addProperty(FieldSpecBuilder(name: "field03").modifiable().initWith("\"abc\"").build())
      .addMethod(MethodSpec.initBuilder().addParam(ParameterSpec("name", paramType: "String")).build())
      .build()
    
    let swiftFile = SwiftFile
      .newSingleClass("sample_class01_output", classSpec: classSpec!)
      .build()
      .writeTo(testOutputDir)
    
    XCTAssertTrue(isSourceFileEqual(getResourceFilePath("sample_class01")!, path2: swiftFile!))
  }
  
  func test_shouldEmitClassWithMethod() {
    let classSpecBuilder = TypeSpec.newClass("TestClass")
      .addProperty(FieldSpecBuilder(name: "field01", fieldType: "Int").initWith("1").build())
      .addProperty(FieldSpecBuilder(name: "field02", fieldType: "String").initWith("\"abc\"").build())
      .addProperty(FieldSpecBuilder(name: "field03").modifiable().initWith("\"abc\"").build())
      .addMethod(MethodSpec.initBuilder().addParam(ParameterSpec("name", paramType: "String")).build())
      .addMethod(MethodSpec.methodBuilder("testFunc").build())
      .superClass("SuperClass")
    let codeBlock = CodeBlock.newCodeBlock() { codeBlock in
      codeBlock.beginControlFlow("if (param == \"test\")")
        .statement("return 123")
        .nextControlFlow("else")
        .statement("return 456")
        .endControlFlow()
    }
    let method = MethodSpec.methodBuilder("testFunc1")
      .addParam(ParameterSpec("param", paramType: "String"))
      .returnType("Int")
      .code(codeBlock)
      .build()
    classSpecBuilder.addMethod(method)
    let methodWithCode = MethodSpec.methodBuilder("testFunc2")
      .addParam(ParameterSpec("param", paramType: "String", defaultValue: "\"abc\""))
      .addParam(ParameterSpec("param2", paramType: "Int", isInOut: true))
      .code("print(\"abc\")\n")
      .build()
    
    classSpecBuilder.addMethod(methodWithCode)
    let classSpec = try? classSpecBuilder.build()
    let swiftFile = SwiftFile
      .newSingleClass("sample_class02_output", classSpec: classSpec!)
      .build()
      .writeTo(testOutputDir)
    
    XCTAssertTrue(isSourceFileEqual(getResourceFilePath("sample_class02")!, path2: swiftFile!))
    
  }
  
  func test_shouldEmitGenericMethodAndClass() {
    let genericMethod = MethodSpec
      .methodBuilder("findIndex")
      .genericType("T")
      .addParam(ParameterSpec("valueToFind", paramType: "T", argLabel: "of"))
      .addParam(ParameterSpec("array", paramType: "[T]", argLabel: "in"))
      .returnType("Int?")
      .code("return nil\n")
      .build()
    let pushMethod = MethodSpec
      .methodBuilder("push")
      .modifiers(TypeModifier.MUTATING)
      .addParam(ParameterSpec("item", paramType: "Element", argLabel: "_"))
      .code("items.append(item)\n")
      .build()
    
    let popMethod = MethodSpec
      .methodBuilder("pop")
      .modifiers(TypeModifier.MUTATING)
      .returnType("Element")
      .code("return items.removeLast()\n")
      .build()
    
    let genericStruct = try? TypeSpec.newStruct("Stack")
      .genericClause("Element")
      .addProperty(FieldSpecBuilder(name: "items").modifiable().initWith("[Element]()").build())
      .addMethod(pushMethod)
      .addMethod(popMethod)
      .build()
    
    let swiftFile = SwiftFile
      .newFile("sample_class03_output")
      .addMethod(genericMethod)
      .addType(genericStruct!)
      .build()
      .writeTo(testOutputDir)
    
    XCTAssertTrue(isSourceFileEqual(getResourceFilePath("sample_class03")!, path2: swiftFile!))
  }
  
  func test_shouldEmitProtocol() {
    let classSpec = try? TypeSpec.newProtocol("TestProtocol")
      .addMethod(MethodSpec.methodBuilder("testProtocolFunc", isAbstract: true).build())
      .addMethod(MethodSpec.methodBuilder("testProtocolFunc", isAbstract: true).addParam(ParameterSpec("value", paramType: "Int")).build())
      .addMethod(MethodSpec.methodBuilder("testProtocolFunc", isAbstract: true).addParam(ParameterSpec("value", paramType: "String", defaultValue: "\"abc\"")).build())
      .build()
    
    let swiftFile = SwiftFile.newSingleClass("sample_protocol01_output", classSpec: classSpec!)
      .build().writeTo(testOutputDir)
    
    XCTAssertTrue(isSourceFileEqual(getResourceFilePath("sample_protocol01")!, path2: swiftFile!))
  }
  
  func test_shouldEmitProtocolWithSuper() {
    do {
      let classSpec = try TypeSpec.newProtocol("TestProtocol")
        .superClass("SuperTestProtocol", "SuperTestProtocol2")
        .addMethod(MethodSpec.methodBuilder("testProtocolFunc", isAbstract: true).build())
        .addMethod(MethodSpec.methodBuilder("testProtocolFunc", isAbstract: true).addParam(ParameterSpec("value", paramType: "Int")).build())
        .addMethod(MethodSpec.methodBuilder("testProtocolFunc", isAbstract: true).addParam(ParameterSpec("value", paramType: "String", defaultValue: "\"abc\"")).build())
        .build()
      let swiftFile = SwiftFile.newSingleClass("sample_protocol02_output", classSpec: classSpec)
        .build().writeTo(testOutputDir)
      
      XCTAssertTrue(isSourceFileEqual(getResourceFilePath("sample_protocol02")!, path2: swiftFile!))
    } catch let error {
      print(error)
    }
    
  }
  
  func test_shouldEmitExtension() {
    do {
      let method = MethodSpec
        .methodBuilder("prepend")
        .modifiers(TypeModifier.PUBLIC)
        .addParam(ParameterSpec("string", paramType: "String"))
        .code(CodeBlock.newCodeBlock("return string + self\n"))
        .returnType("String")
        .build()
      
      let method2 = MethodSpec
        .methodBuilder("append")
        .modifiers(TypeModifier.PUBLIC)
        .addParam(ParameterSpec("string", paramType: "String"))
        .code(CodeBlock.newCodeBlock("return self + string\n"))
        .returnType("String")
        .build()
      
      let classSpec = try TypeSpec.newExtension("String")
        .addMethod(method)
        .addMethod(method2)
        .build()
      
      let operatorMethod = MethodSpec.methodBuilder("*")
        .addParam(ParameterSpec("left", paramType: "String"))
        .addParam(ParameterSpec("right", paramType: "Int"))
        .returnType("String")
        .code(CodeBlock.newCodeBlock() { codeBlock in
          codeBlock.beginControlFlow("if right <= 0")
            .statement("return \"\"")
            .endControlFlow()
            .statement("var result = left")
            .beginControlFlow("for _ in 1..<right")
            .statement("result += left")
            .endControlFlow()
            .statement("return result")
         })
        .build()
      let swiftFile = SwiftFile
        .newFile("sample_extension01_output")
        .addType(classSpec)
        .addMethod(operatorMethod)
        .build()
        .writeTo(testOutputDir)
      
      XCTAssertTrue(isSourceFileEqual(getResourceFilePath("sample_extension01")!, path2: swiftFile!))
    } catch let error {
      print(error)
    }

  }
  
  func test_shouldEmitSimpleEnum() {
    do {
      let classSpec = try TypeSpec.newEnum("CompassPoint")
        .superClass("Int")
        .addEnumConstant(EnumConstantSpec.newEnumValue("north").value("1").build())
        .addEnumConstant(EnumConstantSpec.newEnumValue("south").build())
        .addEnumConstant(EnumConstantSpec.newEnumValue("east").build())
        .addEnumConstant(EnumConstantSpec.newEnumValue("west").build())
        .build()
      let swiftFile = SwiftFile.newSingleClass("sample_enum01_output", classSpec: classSpec)
        .build().writeTo(testOutputDir)
      
      XCTAssertTrue(isSourceFileEqual(getResourceFilePath("sample_enum01")!, path2: swiftFile!))
    } catch let error {
      print(error)
    }
    
  }

  func test_shouldEmitEnumWithTuple() {
    do {
      let enumConstant = EnumConstantSpec.newEnumValue("upc")
        .addTuple(EnumTupleSpec(type: "Int"))
        .addTuple(EnumTupleSpec(type: "Int"))
        .addTuple(EnumTupleSpec(type: "Int"))
        .addTuple(EnumTupleSpec(type: "Int"))
        .build()
      let classSpec = try TypeSpec.newEnum("Barcode")
        .addEnumConstant(enumConstant)
        .addEnumConstant(EnumConstantSpec.newEnumValue("qrCode").addTuple(EnumTupleSpec(name: "code", type: "String")).build())
        .build()
      let swiftFile = SwiftFile.newSingleClass("sample_enum02_output", classSpec: classSpec)
        .build().writeTo(testOutputDir)
      
      XCTAssertTrue(isSourceFileEqual(getResourceFilePath("sample_enum02")!, path2: swiftFile!))
    } catch let error {
      print(error)
    }
    
  }

  
  func isSourceFileEqual(path1: String, path2: String) -> Bool {
    if let aStreamReader = StreamReader(path: path1), aStreamReader2 = StreamReader(path: path2) {
      defer {
        aStreamReader.close()
      }
      var lineNo = 1
      while let line = aStreamReader.nextLine() {
        if let similarLine = aStreamReader2.nextLine() {
          if (line.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != similarLine.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())) {
            print("assert fail at line:\(lineNo)\n-->\(line)\n-->\(similarLine)")
            return false
          }
        } else {
          return false
        }
        lineNo = lineNo + 1
      }
    } else {
      return false
    }
    return true
  }
  
  private func getResourceFilePath(fileName: String) -> String? {
    return NSBundle.init(forClass: SwiftFile_Tests.self).pathForResource(fileName, ofType: "txt")
  }
  
  
}
