public struct Position: CustomStringConvertible, Sendable {
  public var x: Int
  public var y: Int

  public var description: String {
    "\(x),\(y)"
  }

  public static let zero = Position(x: 0, y: 0)

  public func withX(_ x: Int) -> Self {
    Self(x: x, y: self.y)
  }

  public func withY(_ y: Int) -> Self {
    Self(x: self.x, y: y)
  }
}

extension Position: Equatable {
  public static func == (lhs: Position, rhs: Position) -> Bool {
    lhs.x == rhs.x && lhs.y == rhs.y
  }
}

public struct Size: CustomStringConvertible, Sendable {
  public let width: Int
  public let height: Int

  public static let zero = Size(width: 0, height: 0)

  public var description: String {
    "\(width)x\(height)"
  }
}

extension Size: Equatable {
  public static func == (lhs: Size, rhs: Size) -> Bool {
    lhs.width == rhs.width && lhs.height == rhs.height
  }
}
