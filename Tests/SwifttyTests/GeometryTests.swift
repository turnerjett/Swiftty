import Testing

@testable import Swiftty

@Suite("Position")
struct PositionTests: Lockable {
  @Test("Returns correct x value")
  func testPositionX() throws {
    let pos = Position(x: 10, y: 20)
    #expect(pos.x == 10)
  }

  @Test("Returns correct y value")
  func testPositionY() throws {
    let pos = Position(x: 10, y: 20)
    #expect(pos.y == 20)
  }

  @Test("Returns correct description")
  func testPositionDescription() throws {
    let pos = Position(x: 10, y: 20)
    #expect(pos.description == "10,20")
  }

  @Test("Modifies x value")
  func testPositionModifyX() throws {
    let pos = Position.zero.withX(30)
    #expect(pos.x == 30)
  }

  @Test("Modifies y value")
  func testPositionModifyY() throws {
    let pos = Position.zero.withY(30)
    #expect(pos.y == 30)
  }

  @Test("Modifies x and y values directly")
  func testPositionModifyXY() throws {
    var pos = Position(x: 10, y: 20)
    pos.x = 30
    pos.y = 40
    #expect(pos.x == 30)
    #expect(pos.y == 40)
  }

  @Test("Compares two positions")
  func testPositionCompare() throws {
    let pos1 = Position(x: 10, y: 20)
    let pos2 = Position(x: 10, y: 20)
    #expect(pos1 == pos2)
  }
}

@Suite("Size")
struct SizeTests: Lockable {
  @Test("Returns correct description")
  func testSizeDescription() throws {
    let size = Size(width: 10, height: 20)
    #expect(size.description == "10x20")
  }

  @Test("Compares two sizes")
  func testSizeCompare() throws {
    let size1 = Size(width: 10, height: 20)
    let size2 = Size(width: 10, height: 20)
    #expect(size1 == size2)
  }
}
