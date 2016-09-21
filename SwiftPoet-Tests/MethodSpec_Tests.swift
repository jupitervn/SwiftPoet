//
//  MethodSpec_Tests.swift
//  SwiftPoet
//
//  Created by Jupiter on 9/15/16.
//  Copyright © 2016 Jupiter. All rights reserved.
//

import XCTest

class MethodSpec_Tests: XCTestCase {
  let outputStream = StringOutputStream()
  var codeWriter: CodeWriter {
    get {
      return CodeWriter(outputStream: outputStream)
    }
  }
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func test_shouldEmitIfNoParams() {
    let methodSpec = MethodSpecBuilder(name: "function").build()
    methodSpec.emit(codeWriter)
    XCTAssertEqual(outputStream.toString(), "func function() {\n}\n")
  }
  
  func test_shouldEmitParams() {
    let methodSpec = MethodSpecBuilder(name: "function")
      .addParam(ParameterSpec(name: "param1", paramType: "Int"))
      .addParam(ParameterSpec(name: "param2", paramType: "String", defaultValue: "\"value\""))
      .build()
    methodSpec.emit(codeWriter)
    XCTAssertEqual(outputStream.toString(), "func function(param1: Int, param2: String = \"value\") {\n}\n")
  }
  
  func test_shouldEmitReturnType() {
    let methodSpec = MethodSpecBuilder(name: "function")
      .addParam(ParameterSpec(name: "param1", paramType: "Int"))
      .addParam(ParameterSpec(name: "param2", paramType: "String", defaultValue: "\"value\""))
      .returnType("String")
      .build()
    methodSpec.emit(codeWriter)
    XCTAssertEqual(outputStream.toString(), "func function(param1: Int, param2: String = \"value\") -> String {\n}\n")
  }
  
  func test_shouldEmitCodeBlockInside() {
    let methodSpec = MethodSpecBuilder(name: "function")
      .addParam(ParameterSpec(name: "param1", paramType: "Int"))
      .addParam(ParameterSpec(name: "param2", paramType: "String", defaultValue: "\"value\""))
      .returnType("String")
      .code("return \"test\"\n")
      .build()
    methodSpec.emit(codeWriter)
    XCTAssertEqual(outputStream.toString(), "func function(param1: Int, param2: String = \"value\") -> String {\n  return \"test\"\n}\n")
  }
}
