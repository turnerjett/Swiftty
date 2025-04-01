import Foundation

protocol Capturable: Lockable {}

extension Capturable {
  func safeCall(_ block: () throws -> Void) rethrows {
    lock()
    defer { unlock() }
    try block()
  }

  func captureStdout(_ block: () throws -> Void) throws -> String {
    lock()
    defer { unlock() }

    let pipe = Pipe()
    let stdoutFD = FileHandle.standardOutput.fileDescriptor
    let originalStdout = dup(stdoutFD)

    dup2(pipe.fileHandleForWriting.fileDescriptor, stdoutFD)

    try block()

    fflush(stdout)

    dup2(originalStdout, stdoutFD)

    try pipe.fileHandleForWriting.close()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    try pipe.fileHandleForReading.close()

    return String(data: data, encoding: .utf8)!
  }
}
