# SwiftPoet

SwiftPoet is a library that help Swift developers easy to generate Swift source code

## Instruction

### Swift file: 
In order to generate swift file, you can use `SwiftFile.newFile()` or `SwiftFile.newSingleClass()` method.
Example:
```
let swiftFile = SwiftFile
        .newFile({file_name})
        .addType(classSpec)
        .addMethod(operatorMethod)
        .build()
        .writeTo(testOutputDir)
```

SwiftFileBuilder will contains other methods to add `variable` or `class/protocol/extension/enum` or `method` or even `codeblock`

### TypeSpec
Please use these static methods to construct a class/protocol/struct/enum/extension

```
public static func newClass(name: String) -> TypeSpecBuilder
public static func newProtocol(name: String) -> TypeSpecBuilder
public static func newStruct(name: String) -> TypeSpecBuilder
public static func newEnum(name: String, indirect: Bool = false) -> TypeSpecBuilder
public static func newExtension(ofType: String) -> TypeSpecBuilder
```

Example
```
 let classSpec = try? TypeSpec.newClass("TestClass")
      .addProperty(FieldSpecBuilder(name: "field01", fieldType: "Int").initWith("1").build())
      .addProperty(FieldSpecBuilder(name: "field02", fieldType: "String").initWith("\"abc\"").build())
      .addProperty(FieldSpecBuilder(name: "field03").modifiable().initWith("\"abc\"").build())
      .addMethod(MethodSpec.initBuilder().addParam(ParameterSpec(name: "name", paramType: "String")).build())
      .build()
    
    let swiftFile = SwiftFile
      .newSingleClass("sample_class01_output", classSpec: classSpec!)
      .build()
      .writeTo(testOutputDir)
```
will generate this file
```
class TestClass {
  let field01: Int = 1
  let field02: String = "abc"
  var field03 = "abc"

  init(name: String) {
  }

}
```

### CodeBlock
In order to construct a codeblock, please use: `CodeBlock.newCodeBlock() {}`
`.statement()` is used to insert a new statement inside codeblock
`.beginControlFlow()` will start a block of control flow and handle all the indents for you
`.nextControlFlow()` is used to generate ` else clause`
'.endControlFlow()` will close the current block of control flow.

Example:
```
let codeBlock = CodeBlock.newCodeBlock() { codeBlock in
      codeBlock.beginControlFlow("if (param == \"test\")")
        .statement("return 123")
        .nextControlFlow("else")
        .statement("return 456")
        .endControlFlow()
    }
```

will generate this piece of code
```
if (param == "test") {
      return 123
    } else {
      return 456
    }
```

Please find more examples inside SwiftFile_Tests.swift to learn more about the usage of this library.




