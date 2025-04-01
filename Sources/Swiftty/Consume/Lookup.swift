public func lookup(_ string: String) -> Event.Match? {
  lookup(Array(string.utf8))
}

public func lookup(_ bytes: [UInt8]) -> Event.Match? {
  if bytes.count > 0 {
    print(bytes)
  }

  return switch bytes.count {
  // Empty read
  case 0: nil

  // Read a single byte
  case 1: lookupByte(bytes.first!)

  // Read a escape sequence
  case 2... where bytes.first == 0x1b: lookupEscape(bytes)

  default: lookupOther(bytes)
  }
}

private func lookupByte(_ byte: UInt8) -> Event.Match? {
  if (0x20...0x7E).contains(byte) {
    return .single(.key(KeyEvent(code: .char(Character(Unicode.Scalar(byte))))))
  }

  if let cc = ControlCode(rawValue: byte),
    let match = Map.controlCodeEvent[cc]
  {
    return match
  }

  return nil
}

private func lookupEscape(_ bytes: [UInt8]) -> Event.Match? {
  if let match = Map.escapeEvent[bytes] {
    return match
  }

  return nil
}

private func lookupOther(_ bytes: [UInt8]) -> Event.Match? {
  if let match = Map.altKeyEvent[bytes] {
    return match
  }

  return nil
}
