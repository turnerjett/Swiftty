import Testing

@testable import Swiftty

@Suite("Event")
struct EventTests {
  @Test("Checks if a key event matches a control code")
  func testEventsAreEqual() {
    #expect(
      KeyEvent(code: .cc(.nul)) == KeyEvent(code: .char("@"), modifiers: .ctrl))
    #expect(
      KeyEvent(code: .enter)
        == KeyEvent(code: .char("m"), modifiers: .ctrl))
    #expect(
      KeyEvent(code: .escape)
        == KeyEvent(code: .char("["), modifiers: .ctrl))
    #expect(
      KeyEvent(code: .delete) == KeyEvent(code: .char("?"), modifiers: .ctrl))
    #expect(
      KeyEvent(code: .up) == KeyEvent(code: .up)
    )
    #expect(
      KeyEvent(code: .char("œ")) == KeyEvent(code: .char("q"), modifiers: .alt)
    )

  }

  @Test("Checks if a key event does not match a control code")
  func testEventsAreNotEqual() {
    #expect(
      KeyEvent(code: .enter)
        != KeyEvent(code: .char("n"), modifiers: .ctrl))
  }
}
