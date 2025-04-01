public struct Csi {
  public let params: [String]
  public let controlFn: ControlFunction

  public init(_ controlFn: ControlFunction) {
    self.params = []
    self.controlFn = controlFn
  }

  public init(_ param: String, _ controlFn: ControlFunction) {
    self.params = [param]
    self.controlFn = controlFn
  }

  public init(_ params: [String], _ controlFn: ControlFunction) {
    self.params = params
    self.controlFn = controlFn
  }

  public init(_ param: UInt, _ controlFn: ControlFunction) {
    self.params = [String(param)]
    self.controlFn = controlFn
  }

  public init(_ params: [UInt], _ controlFn: ControlFunction) {
    self.params = params.map { String($0) }
    self.controlFn = controlFn
  }

  public var bytes: [UInt8] {
    var bytes: [UInt8] = []
    bytes.append(contentsOf: [ControlCode.esc.rawValue, ControlCode.csi.rawValue])
    bytes.append(contentsOf: (try? paramBytes()) ?? [])
    bytes.append(contentsOf: controlFn.bytes)
    return bytes
  }

  public func callAsFunction() throws {
    guard controlFn.requiredParameters == params.count || controlFn.requiredParameters == nil else {
      throw CSIError.invalidParameterCount
    }
    let paramBytes = try paramBytes()
    execute([.esc, .csi], params: paramBytes + controlFn.bytes)
  }

  public func call() throws {
    try callAsFunction()
  }

  private func paramBytes() throws -> [UInt8] {
    let paramBytes = try params.map { str in
      try [UInt8](str.utf8).map { byte in
        guard ByteRange.parameter.contains(byte) else {
          throw CSIError.invalidParameter
        }
        return byte
      }
    }

    let paramsWithSeparator: [UInt8] = paramBytes.enumerated().flatMap { index, bytes in
      if index == paramBytes.count - 1 {
        return bytes
      } else {
        return bytes + [0x3B]  // Semicolon separator
      }
    }

    return paramsWithSeparator
  }
}

// This should be used internally to execute control functions since control functions
// require specific inputs
func executeCsi(_ operation: () throws -> Void) {
  do {
    try operation()
  } catch CSIError.invalidParameter {
    preconditionFailure("Invalid parameter in CSI operation - this is a bug in Swiftty")
  } catch CSIError.invalidParameterCount {
    preconditionFailure("Invalid parameter count in CSI operation - this is a bug in Swiftty")
  } catch {
    preconditionFailure("Unhandled CSI error - this is a bug in Swiftty: \(error)")
  }
}

public enum CSIError: Error {
  case invalidParameter
  case invalidParameterCount
  case invalidControlFunction
}

public struct ControlFunction: Hashable, Sendable {
  public let intermediate: [UInt8]
  public let final: UInt8
  public let requiredParameters: Int?
  public init?(rawValue: (intermediate: [UInt8], final: UInt8), requiredParameters: Int? = 1) {
    guard rawValue.intermediate.allSatisfy({ ByteRange.intermediate.contains($0) }) else {
      return nil
    }
    guard ByteRange.final.contains(rawValue.final) else {
      return nil
    }
    self.intermediate = rawValue.intermediate
    self.final = rawValue.final
    self.requiredParameters = requiredParameters
  }

  public init?(final: UInt8, requiredParameters: Int? = 1) {
    self.init(rawValue: (intermediate: [], final: final), requiredParameters: requiredParameters)
  }

  public init?(intermediate: [UInt8], final: UInt8, requiredParameters: Int? = 1) {
    self.init(
      rawValue: (intermediate: intermediate, final: final), requiredParameters: requiredParameters)
  }

  public var bytes: [UInt8] {
    var params: [UInt8] = []
    params.append(contentsOf: intermediate)
    params.append(final)
    return params
  }

  private static let allControlFunctions: [ControlFunction] = [
    ich, sl, cuu, sr, cud, cuf, cub, cnl, cpl, cha, cup, cht, ed, el, il, dl,
    dch, su, sd, ech, cbt, hpa, hpr, rep, da, vpa, vpr, hvp, tbc, sm, rm, sgr,
    dsr, rqm, str, sca, scusr, stbm, sc, rc, ic, dc,
  ]

  public static func matching(intermediate: [UInt8] = [], final: UInt8) throws -> ControlFunction {
    guard
      let match = allControlFunctions.first(where: { cf in
        cf.intermediate == intermediate && cf.final == final
      })
    else {
      throw CSIError.invalidControlFunction
    }
    return match
  }

  /// Insert Character
  public static let ich = Self(final: 0x40)!  // @
  /// Scroll Left
  public static let sl = Self(intermediate: [0x20], final: 0x40)!  // SP @
  /// Cursor Up
  public static let cuu = Self(final: 0x41)!  // A
  /// Scroll Right
  public static let sr = Self(intermediate: [0x20], final: 0x41)!  // SP A
  /// Cursor Down
  public static let cud = Self(final: 0x42)!  // B
  /// Cursor Forward
  public static let cuf = Self(final: 0x43)!  // C
  /// Cursor Backward
  public static let cub = Self(final: 0x44)!  // D
  /// Cursor Next Line
  public static let cnl = Self(final: 0x45)!  // E
  /// Cursor Previous Line
  public static let cpl = Self(final: 0x46)!  // F
  /// Cursor Horizontal Absolute
  public static let cha = Self(final: 0x47)!  // G
  /// Cursor Position
  public static let cup = Self(final: 0x48, requiredParameters: 2)!  // H
  /// Cursor Horizontal Tabulation
  public static let cht = Self(final: 0x49)!  // I
  /// Erase in Display
  public static let ed = Self(final: 0x4A)!  // J
  /// Erase in Line
  public static let el = Self(final: 0x4B)!  // K
  /// Insert Line
  public static let il = Self(final: 0x4C)!  // L
  /// Delete Line
  public static let dl = Self(final: 0x4D)!  // M
  /// Delete Character
  public static let dch = Self(final: 0x50)!  // P
  /// Scroll Up
  public static let su = Self(final: 0x53)!  // S
  /// Scroll Down
  public static let sd = Self(final: 0x54)!  // T
  /// Erase Character
  public static let ech = Self(final: 0x58)!  // X
  /// Cursor Backward Tabulation
  public static let cbt = Self(final: 0x5A)!  // Z
  /// Horizontal Position Absolute (Same as CHA)
  public static let hpa = Self(final: 0x60)!  // `
  /// Horizontal Position Relative (Same as CUF)
  public static let hpr = Self(final: 0x61)!  // a
  /// Repeat Preceding Character
  public static let rep = Self(final: 0x62)!  // b
  /// Primary Device Attributes
  public static let da = Self(final: 0x63, requiredParameters: 0)!  // c
  /// Vertical Position Absolute
  public static let vpa = Self(final: 0x64)!  // d
  /// Vertical Position Relative
  public static let vpr = Self(final: 0x65)!  // e
  /// Horizontal and Vertical Position (Same as CUP)
  public static let hvp = Self(final: 0x66, requiredParameters: 2)!  // f
  /// Tab Clear
  public static let tbc = Self(final: 0x67)!  // g
  /// Set Mode
  public static let sm = Self(final: 0x68, requiredParameters: nil)!  // h
  /// Reset Mode
  public static let rm = Self(final: 0x6C, requiredParameters: nil)!  // l
  /// Select Graphic Rendition
  public static let sgr = Self(final: 0x6D, requiredParameters: nil)!  // m
  /// Device Status Report
  public static let dsr = Self(final: 0x6E)!  // n

  // Private Use
  /// Request Mode
  public static let rqm = Self(intermediate: [0x24], final: 0x70)!  // $ p
  /// Soft Terminal Reset
  public static let str = Self(intermediate: [0x21], final: 0x70, requiredParameters: 0)!  // ! p
  /// Select Character Protection Attribute
  public static let sca = Self(intermediate: [0x22], final: 0x71)!  // * q
  /// Set Cursor Style
  public static let scusr = Self(intermediate: [0x20], final: 0x71)!  // SP q
  /// Set Top and Bottom Margins
  public static let stbm = Self(final: 0x72, requiredParameters: 2)!  // r
  /// Save Cursor
  public static let sc = Self(final: 0x73, requiredParameters: 0)!  // s
  /// Restore Cursor
  public static let rc = Self(final: 0x75, requiredParameters: 0)!  // u
  /// Insert Columns
  public static let ic = Self(intermediate: [0x27], final: 0x7D)!  // ' }
  /// Delete Columns
  public static let dc = Self(intermediate: [0x27], final: 0x7E)!  // ' ~

  /// Keyboard Code
  public static let kbc = Self(final: 0x7E)!  // ~
}

/// Ranges of valid bytes for CSI control functions
struct ByteRange {
  /// Valid bytes for CSI parameter bytes
  static let parameter: ClosedRange<UInt8> = 0x30...0x3F
  /// Valid bytes for CSI intermediate bytes
  static let intermediate: ClosedRange<UInt8> = 0x20...0x2F
  /// Valid bytes for CSI final bytes
  static let final: ClosedRange<UInt8> = 0x40...0x7E
}

extension ControlFunction: Equatable {
  public static func == (lhs: ControlFunction, rhs: ControlFunction) -> Bool {
    lhs.intermediate == rhs.intermediate && lhs.final == rhs.final
  }
}
