import Testing

@testable import Swiftty

@Suite("CSI")
struct CSITests: Capturable {
  @Test("Formats CSI sequence with multiple parameters correctly")
  func testCsi() throws {
    let output = try captureStdout {
      try Csi(["1", "2"], .cup).call()
    }
    #expect(output == "\u{1B}[1;2H")
  }

  @Test("Formats CSI sequence with no parameters correctly")
  func testCsiNoParams() throws {
    let output = try captureStdout {
      try Csi(.da).call()
    }
    #expect(output == "\u{1B}[c")
  }

  @Test("Throws error when required parameter is missing")
  func testCsiIncorrectParamCount() throws {
    #expect(throws: CSIError.invalidParameterCount) {
      try safeCall {
        try Csi(.cuu).call()
      }
    }
  }

  @Test("Throws error when too many parameters are provided")
  func testCsiIncorrectMultiParamCount() throws {
    #expect(throws: CSIError.invalidParameterCount) {
      try safeCall {
        try Csi(["1", "2", "3"], .cup).call()
      }
    }
  }

  @Test("Throws error when parameter contains invalid characters")
  func testCsiIncorrectParamRange() throws {
    #expect(throws: CSIError.invalidParameter) {
      try safeCall {
        try Csi("A", .cuu).call()
      }
    }
  }

  @Test("Formats CSI sequence with intermediate bytes correctly")
  func testCsiWithIntermediateParams() throws {
    let output = try captureStdout {
      try Csi(.str).call()
    }
    #expect(output == "\u{1B}[!p")
  }
}
