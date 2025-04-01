public enum Event: Equatable, Sendable {
  case key(KeyEvent)
  case paste(String)
  case focus(FocusEvent)
  // TODO: Add mouse and resize events

  /// Some events can match to multiple events, such as CTRL+C also being a ETX event.
  /// This type allows for holding multiple event matches.
  public enum Match: Sendable {
    case single(Event)
    case multi([Event])
  }
}

public struct KeyEvent: Sendable {
  public let code: KeyCode
  public let modifiers: KeyModifiers?

  public init(code: KeyCode, modifiers: KeyModifiers? = nil) {
    self.code = code
    self.modifiers = modifiers
  }

  public func copy(code: KeyCode? = nil, modifiers: KeyModifiers? = nil) -> Self {
    Self(
      code: code ?? self.code,
      modifiers: modifiers ?? self.modifiers
    )
  }
}

extension KeyEvent: Equatable {
  public static func == (lhs: KeyEvent, rhs: KeyEvent) -> Bool {
    if let sides = checkSides(lhs, rhs) {
      return sides
    }
    if let sides = checkSides(rhs, lhs) {
      return sides
    }
    return lhs.code == rhs.code && lhs.modifiers == rhs.modifiers
  }

  private static func checkSides(_ a: KeyEvent, _ b: KeyEvent) -> Bool? {
    if let equals = matchMultis([Event.Match](Map.controlCodeEvent.values), a, b) {
      return equals
    }

    if let equals = matchMultis([Event.Match](Map.altKeyEvent.values), a, b) {
      return equals
    }

    return nil
  }

  private static func matchMultis(_ values: [Event.Match], _ a: KeyEvent, _ b: KeyEvent) -> Bool? {
    for case let .multi(events) in values {
      if case let .key(keyEvent1) = events[0], case let .key(keyEvent2) = events[1] {
        let case1 = keyEvent1.code == a.code && keyEvent1.modifiers == a.modifiers
        let case2 = keyEvent2.code == b.code && keyEvent2.modifiers == b.modifiers
        if case1 && case2 { return true }
      }
    }
    return nil
  }
}

// TODO: Implement
public enum FocusEvent: Equatable, Sendable {
  case gained, lost
}

public enum KeyCode: Equatable, Sendable {
  case cc(ControlCode)
  case up
  case down
  case right
  case left
  case home
  case end
  case pageUp
  case pageDown
  case insert
  /// Fn key with an integer representing the key number
  case fn(Int)
  case char(Character)

  // Common aliases
  public static let enter = Self.cc(.cr)
  public static let backspace = Self.cc(.bs)
  public static let tab = Self.cc(.ht)
  public static let escape = Self.cc(.esc)
  public static let delete = Self.cc(.del)
}

extension KeyCode {
  public static func charFromByte(_ byte: UInt8) -> KeyCode {
    return .char(Character(Unicode.Scalar(byte)))
  }
}

public struct KeyModifiers: OptionSet, Sendable {
  public var rawValue: Int8

  public init(rawValue: Int8) {
    self.rawValue = rawValue
  }

  public static let shift = KeyModifiers(rawValue: 1 << 0)
  public static let alt = KeyModifiers(rawValue: 1 << 1)
  public static let ctrl = KeyModifiers(rawValue: 1 << 2)
  public static let supr = KeyModifiers(rawValue: 1 << 3)
  public static let hyper = KeyModifiers(rawValue: 1 << 4)
  public static let meta = KeyModifiers(rawValue: 1 << 5)
  public static let caps_lock = KeyModifiers(rawValue: 1 << 6)
  public static let num_lock = KeyModifiers(rawValue: 1 << 7)
}

extension KeyModifiers: CustomStringConvertible {
  public var description: String {
    var components: [String] = []

    if contains(.shift) {
      components.append("shift")
    }
    if contains(.alt) {
      components.append("alt")
    }
    if contains(.ctrl) {
      components.append("ctrl")
    }
    if contains(.supr) {
      components.append("super")
    }
    if contains(.hyper) {
      components.append("hyper")
    }
    if contains(.meta) {
      components.append("meta")
    }
    if contains(.caps_lock) {
      components.append("caps_lock")
    }
    if contains(.num_lock) {
      components.append("num_lock")
    }

    if components.isEmpty {
      return "none"
    } else {
      return components.joined(separator: "+")
    }
  }
}

// TODO: Implement
struct ProgressiveEnhancement: OptionSet {
  var rawValue: Int8

  static let disambiguateEscapeCodes = ProgressiveEnhancement(rawValue: 1 << 0)
  static let reportEventTypes = ProgressiveEnhancement(rawValue: 1 << 1)
  static let reportAlternateKeys = ProgressiveEnhancement(rawValue: 1 << 2)
  static let reportAllKeysAsEscapeCodes = ProgressiveEnhancement(rawValue: 1 << 3)
  static let reportAssociatedText = ProgressiveEnhancement(rawValue: 1 << 4)

  static let all: ProgressiveEnhancement = [
    .disambiguateEscapeCodes, .reportEventTypes, .reportAlternateKeys,
    .reportAllKeysAsEscapeCodes, .reportAssociatedText,
  ]
}
