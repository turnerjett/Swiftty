import Testing

@testable import Swiftty

@Suite("Execute")
struct ExecuteTests: Capturable {
  @Test("Writes control code to stdout")
  func testExecute() throws {
    let output = try captureStdout {
      execute(.bel)
    }
    #expect(output == "\u{07}")
  }

  @Test("Writes multiple control codes to stdout")
  func testExecuteMultiple() throws {
    let output = try captureStdout {
      execute([.esc, .csi])
    }
    #expect(output == "\u{1B}\u{5B}")
  }

  @Test("Writes control codes with parameters to stdout")
  func testExecuteWithParams() throws {
    let output = try captureStdout {
      execute([.esc, .csi], params: [0x01, 0x02])
    }
    #expect(output == "\u{1B}\u{5B}\u{01}\u{02}")
  }
}
