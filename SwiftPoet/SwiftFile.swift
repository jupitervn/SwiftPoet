//
//  SwiftFile.swift
//  SwiftPoet
//
//  Created by Jupiter on 8/22/16.
//  Copyright © 2016 Jupiter. All rights reserved.
//

import Foundation

protocol OutputStream {
  func write(text: String)
}

public class FileOutputStream : OutputStream {
  let fileOutputStream: NSOutputStream
  init(outputStream: NSOutputStream) {
    self.fileOutputStream = outputStream
    fileOutputStream.open()
  }
  
  func write(text: String) {
    fileOutputStream.write(text, maxLength: text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
  }
}

public class StringOutputStream : OutputStream {
  var fileContent = ""
  func write(text: String) {
    fileContent += text
  }
  
  func toString() -> String {
    return fileContent
  }
}

public class SwiftFile {
  let fileName: String
  var fileComment: String = ""
  var imports = [String]()
  let components: [SwiftComponentWriter]
  
  init(fileName: String, importList: [String] = [], components: [SwiftComponentWriter] = []) {
    self.fileName = fileName
    self.imports = importList
    self.components = components
  }
  
  public func writeTo(directory: String) -> String? {
    let outputFilePath = NSURL.fileURLWithPathComponents([directory, fileName])
    if let outputFilePath = outputFilePath {
      var isDir: ObjCBool = false
      let fm = NSFileManager()
      if !fm.fileExistsAtPath(directory, isDirectory: &isDir) {
         try! fm.createDirectoryAtPath(directory, withIntermediateDirectories: false, attributes: nil)
      }
      fm.createFileAtPath(outputFilePath.path!, contents: nil, attributes: nil)
      
      let nsOutputStream = NSOutputStream(toFileAtPath: outputFilePath.path!, append: false)!
      let codeWriter = CodeWriter(outputStream: FileOutputStream(outputStream: nsOutputStream))
      emit(codeWriter)
      nsOutputStream.close()
    }
    return outputFilePath?.path ?? nil
  }
  
  private func emit(codeWriter: CodeWriter) {
    imports.forEach { (importType) in
      codeWriter.emit("import \(importType)")
    }
    
    components.forEach { (component) in
      component.emit(codeWriter)
      if !(component is VariableSpec) {
        codeWriter.emit("\n")
      }
    }
  }
  
  public static func newSingleClass(name: String, classSpec: TypeSpec) -> SwiftFileBuilder {
    return SwiftFileBuilder(fileName: name).addType(classSpec)
  }
  
  public static func newFile(name: String) -> SwiftFileBuilder {
    return SwiftFileBuilder(fileName: name)
  }
}

public class SwiftFileBuilder {
  let fileName: String
  var fileComponents = [SwiftComponentWriter]()
  var importList = [String]()
  
  public init(fileName: String) {
    self.fileName = fileName + ".swift"
  }
  
  public func addProperty(property: VariableSpec) -> SwiftFileBuilder {
    addComponent(property)
    return self
  }
  
  public func addMethod(method: MethodSpec) -> SwiftFileBuilder {
    addComponent(method)
    return self
  }
  
  public func addType(type: TypeSpec) -> SwiftFileBuilder {
    addComponent(type)
    return self
  }
  
  public func addImport(importType: String) -> SwiftFileBuilder {
    importList.append(importType)
    return self
  }
  
  public func addCodeBlock(codeBlock: CodeBlock) -> SwiftFileBuilder {
    addComponent(codeBlock)
    return self
  }
  
  private func addComponent(component: SwiftComponentWriter) {
    fileComponents.append(component)
  }
  
  public func build() -> SwiftFile {
      return SwiftFile(fileName: fileName, importList: importList, components: fileComponents)
  }
  
}













