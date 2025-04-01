import Foundation

protocol Lockable {
  static var testLock: NSLock { get }
  func lock()
  func unlock()
}

private let globalTestLock = NSLock()
extension Lockable {
  static var testLock: NSLock {
    return globalTestLock
  }

  func lock() {
    Self.testLock.lock()
  }

  func unlock() {
    Self.testLock.unlock()
  }
}
