//
//  CodeWriter.swift
//  SwiftPoet
//
//  Created by Jupiter on 9/14/16.
//  Copyright © 2016 Jupiter. All rights reserved.
//

import Foundation

protocol SwiftComponentWriter {
  func emit(codeWriter: CodeWriter)
}

public class CodeWriter {
  var indents = 0
  let indentString: String
  let outputStream:OutputStream;
  var isWrittingAfterNewLine = false
  
  init(outputStream: OutputStream, indent:String = "  ") {
    self.outputStream = outputStream
    self.indentString = indent
  }
  
  func indent(level: Int = 1) -> CodeWriter {
    indents += level
    return self
  }
  
  func unindent(level: Int = 1) -> CodeWriter {
    indents -= level
    return self
  }
  
  func emit(code: String) -> CodeWriter {
    emitAndIndent(code)
    return self
  }
  
  func emitModifiers<T : Modifier>(modifiers: T...) -> CodeWriter {
    return emitModifiers(modifiers)
  }
  
  func emitModifiers<T : Modifier>(modifiers: [T]) -> CodeWriter {
    modifiers.forEach { (modifier) in
      emitAndIndent(modifier.value())
      emitAndIndent(" ")
    }
    return self
  }
  
  func emit(codeBlock: CodeBlock?) -> CodeWriter {
    if let codeBlock = codeBlock {
      codeBlock.emit(self)
    }
    return self
  }
  
  private func emitAndIndent(code: String) {
    var isFirstLine = true
    let lineParts = code.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
    lineParts.forEach { (line) in
      if (!isFirstLine) {
        self.outputStream.write("\n")
        isWrittingAfterNewLine = true
      }
      isFirstLine = false
      if (line.isEmpty) {
        return
      }
      
      if (isWrittingAfterNewLine) {
        self.emitIndent()
      }
      self.outputStream.write(line)
      isWrittingAfterNewLine = false
      
    }
  }
  
  private func emitIndent() {
    (0..<indents).forEach { (level) in
      self.outputStream.write(indentString)
    }
  }
}