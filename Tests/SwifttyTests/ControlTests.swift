import Testing

@testable import Swiftty

@Suite("Window")
struct WindowTests {
  @Test("Returns window size from terminal interface")
  func testGetWindowSize() {
    struct TestTerminal: TerminalInterface {
      var windowSize: Size? {
        return Size(width: 50, height: 50)
      }
    }

    Window.setTerminal(TestTerminal())

    let size = Window.getSize()
    #expect(size == Size(width: 50, height: 50))
  }

  @Test("Returns default window size when terminal returns nil")
  func testGetDefaultWindowSize() {
    struct TestTerminal: TerminalInterface {
      var windowSize: Size? {
        return nil
      }
    }
    Window.setTerminal(TestTerminal())

    let size = Window.getSize()
    #expect(size == Size(width: 80, height: 25))
  }
}

@Suite("Cursor")
struct CursorTests: Capturable {
  @Test("Moves cursor to specified position using CSI sequence")
  func testMoveCursor() throws {
    let output = try captureStdout {
      Cursor.moveTo(x: 10, y: 20)
    }
    #expect(output == "\u{1B}[20;10H")
  }
}
