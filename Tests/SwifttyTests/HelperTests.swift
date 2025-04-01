import Testing

@testable import Swiftty

@Suite("StdOut")
struct StdOutTests: Capturable {
  @Test("Writes string to stdout")
  func testWriteString() throws {
    let output = try captureStdout {
      StdOut.write("Hello, World!")
    }
    #expect(output == "Hello, World!")
  }

  @Test("Writes byte to stdout")
  func testWriteByte() throws {
    let output = try captureStdout {
      StdOut.write(0x01)
    }
    #expect(output == "\u{01}")
  }

  @Test("Writes bytes to stdout")
  func testWriteBytes() throws {
    let output = try captureStdout {
      StdOut.write([0x01, 0x02])
    }
    #expect(output == "\u{01}\u{02}")
  }
}
