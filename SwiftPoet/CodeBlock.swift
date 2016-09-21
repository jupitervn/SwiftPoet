//
//  CodeBlock.swift
//  SwiftPoet
//
//  Created by Jupiter on 9/20/16.
//  Copyright © 2016 Jupiter. All rights reserved.
//

import Foundation
//For codeblock, closure
public class CodeBlock : SwiftComponentWriter {
  var codeStatements = [String]()
  
  private init(initialCode: String? = nil) {
    if let initialCode = initialCode {
      codeStatements.append(initialCode)
    }
  }
  
  public func statement(statement: String) -> CodeBlock {
    addStatement(statement + "\n")
    return self
  }
  
  public func block(codeBlock: CodeBlock) -> CodeBlock {
    addStatements(codeBlock.codeStatements)
    return self
  }
  
  public func beginControlFlow(statement: String) -> CodeBlock {
    addStatement("\(statement) {\n")
    indent()
    return self
  }
  
  public func nextControlFlow(statement: String) -> CodeBlock {
    unindent()
    addStatement("} \(statement) {\n")
    indent()
    return self
  }
  
  public func endControlFlow(statement: String? = nil) -> CodeBlock {
    unindent()
    addStatement("\(statement ?? "}")\n")
    return self
  }
  
  private func indent() {
    addStatement("$>$")
  }
  
  private func unindent() {
    addStatement("$<$")
  }
  
  private func addStatements(statementList: [String]) {
    codeStatements.appendContentsOf(statementList)
  }
  
  private func addStatement(statements: String...) {
    self.addStatements(statements)
  }
  
  func emit(codeWriter: CodeWriter) {
    codeStatements.forEach { (statement) in
      switch (statement) {
      case "$>$":
        codeWriter.indent()
      case "$<$":
        codeWriter.unindent()
      default:
        codeWriter.emit(statement)
      }
    }
  }
  
  public static func newCodeBlock(initialCode: String? = nil, @noescape initCode: (inout CodeBlock) -> ()) -> CodeBlock {
    var codeBlock = CodeBlock(initialCode: initialCode)
    initCode(&codeBlock)
    return codeBlock
  }
  
  public static func newCodeBlock(initialCode: String? = nil) -> CodeBlock {
    return CodeBlock(initialCode: initialCode)
  }
}

func +(left:CodeBlock, statement: String) -> CodeBlock {
  left.addStatement(statement)
  return left
}

func +=(inout left:CodeBlock, statement: String) {
  left.addStatement(statement)
}

func +(left:CodeBlock, right:CodeBlock) -> CodeBlock {
  left.block(right)
  return left
}

infix operator -| { associativity left precedence 140 }
infix operator |- { associativity left precedence 140 }

func -| (left: CodeBlock, beginFlowString: String) -> CodeBlock {
  left.beginControlFlow(beginFlowString)
  return left
}

func |- (left: CodeBlock, endFlowString: String) -> CodeBlock {
  left.endControlFlow(endFlowString)
  return left
}

let newBlock = CodeBlock.newCodeBlock {
  $0 = $0
    +  "let a = \"abc\""
    +  "let b = 'abc'"
    -| "for abc in 0..1"
    -| ""
    +  ""
    +  "left"
  
  
}
