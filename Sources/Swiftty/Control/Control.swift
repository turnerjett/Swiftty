import Darwin.POSIX.termios
import Foundation

public protocol TerminalInterface: Sendable {
  var windowSize: Size? { get }
}

public struct SystemTerminal: TerminalInterface {
  public var windowSize: Size? {
    var size = winsize()
    let result = ioctl(STDOUT_FILENO, TIOCGWINSZ, &size)
    if result == 0 {
      return Size(width: Int(size.ws_col), height: Int(size.ws_row))
    } else {
      return nil
    }
  }
}

public struct RawMode {
  let blocking: Bool
  let timeout: UInt8
  var originalTermios = termios()

  init(blocking: Bool = false, timeout: UInt8 = 0) {
    self.blocking = blocking
    self.timeout = timeout
  }

  mutating func enable() {
    try? enableOrThrow()
  }

  mutating func enableOrThrow() throws {
    // TODO: Add conditional logic to allow for cross-platform enabling
    try enablePosix()
  }

  mutating func enablePosix() throws {
    var settings = originalTermios

    guard tcgetattr(STDIN_FILENO, &settings) == 0 else {
      throw RawModeError.failedToGetTerminalSettings
    }
    originalTermios = settings

    cfmakeraw(&settings)

    guard cfsetispeed(&settings, speed_t(B9600)) == 0 else {
      throw RawModeError.failedToSetTerminalSettings
    }
    guard cfsetospeed(&settings, speed_t(B9600)) == 0 else {
      throw RawModeError.failedToSetTerminalSettings
    }

    // VTIME
    settings.c_cc.16 = timeout
    // VMIN
    settings.c_cc.17 = blocking ? 1 : 0

    guard tcsetattr(STDIN_FILENO, TCSANOW, &settings) == 0 else {
      throw RawModeError.failedToSetTerminalSettings
    }
  }

  func disable() {
    try? disableOrThrow()
  }

  func disableOrThrow() throws {
    // TODO: Add conditional logic to allow for cross-platform disabling
    try disablePosix()
  }

  func disablePosix() throws {
    var settings = originalTermios
    guard tcsetattr(STDIN_FILENO, TCSANOW, &settings) == 0 else {
      throw RawModeError.failedToSetTerminalSettings
    }
  }
}

private enum RawModeError: Error {
  case failedToGetTerminalSettings
  case failedToSetTerminalSettings
}

public struct Cursor {
  public static func moveTo(_ pos: Position) {
    let xParam = pos.x.description
    let yParam = pos.y.description
    executeCsi {
      try Csi([yParam, xParam], .cup).call()
    }
  }

  public static func moveTo(x: Int, y: Int) {
    moveTo(Position(x: x, y: y))
  }
}
