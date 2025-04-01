import Synchronization

public struct Window: Sendable {
  private static let rawMode = Mutex(RawMode())
  private static let terminal: Mutex<TerminalInterface> = Mutex(SystemTerminal())

  /// Should only be used for testing purposes to allow for mocking of the terminal interface.
  public static func setTerminal(_ terminal: TerminalInterface) {
    self.terminal.withLock { $0 = terminal }
  }

  /// Enable raw mode on the terminal, allowing for user input to be processed directly
  /// by the library rather than the terminal. Raw mode should be disabled when finished
  /// using the terminal. Consider following this function call with a `defer` call to
  /// `Window.disableRawMode()`.
  public static func enableRawMode(blocking: Bool = false, timeout: UInt8 = 0) {
    rawMode.withLock { rawMode in
      rawMode = RawMode(blocking: blocking, timeout: timeout)
      rawMode.enable()
    }
  }

  /// Disable raw mode on the terminal. This should be called after `Window.enableRawMode()`
  /// has been called, usually at the end of the program.
  public static func disableRawMode() {
    rawMode.withLock { $0.disable() }
  }

  /// Enter alternate screen buffer. The alternate screen buffer should be exited when the program
  /// is finished using it. Consider following this function call with a `defer` call to
  /// `Window.exitAlternateScreen()`.
  public static func enterAlternateScreen() {
    executeCsi {
      try Csi("?1049", .sm).call()
    }
  }

  /// Exit alternate screen buffer. This should be called after `Window.enterAlternateScreen()`,
  /// usually at the end of the program.
  public static func exitAlternateScreen() {
    executeCsi {
      try Csi("?1049", .rm).call()
    }
  }

  /// Returns the size of the terminal window.
  public static func getSize() -> Size {
    if let size = terminal.withLock(\.windowSize) {
      size
    } else {
      Size(width: 80, height: 25)
    }
  }
}
