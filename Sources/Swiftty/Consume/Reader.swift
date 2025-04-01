public actor Reader {
  private var running = false
  private var buffer = [UInt8]()

  public init() {}

  /// Runs an event loop that calls the provided block for each event received.
  /// The event loop will continue until the `stop()` function is called. The
  /// provided block is marked as `@MainActor` so that it can be called from the
  /// main thread. This is useful if you plan to update the terminal UI directly
  /// from the provided block.
  @MainActor
  public func runOnMain(using block: @MainActor @Sendable (Event) async throws -> Void) async throws
  {
    try await run(using: block)
  }

  /// Runs an event loop that calls the provided block for each event received.
  /// The event loop will continue until the `stop()` function is called.
  public func run(using block: @Sendable (Event) async throws -> Void) async throws {
    running = true
    while running {
      try Task.checkCancellation()

      try await readToBuffer()
      let eventMatch = lookup(buffer)

      switch eventMatch {
      case nil: break
      case let .single(event): try await block(event)
      case let .multi(events):
        for event in events {
          try await block(event)
        }
      }

      buffer.removeAll()
      await Task.yield()
    }
  }

  private func readToBuffer() async throws {
    while true {
      let bytes = StdIn.readBytes()
      if bytes.count == 0 {
        break
      }
      buffer.append(contentsOf: bytes)
      await Task.yield()
    }
  }

  /// Stops the event loop. Consider calling this function when an event is received,
  /// such as CTRL+C or Q.
  public func stop() {
    running = false
  }
}
