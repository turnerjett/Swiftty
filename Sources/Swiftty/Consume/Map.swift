public struct Map {
  static let controlCodeEvent: [ControlCode: Event.Match] = [
    .nul: .multi([
      .key(KeyEvent(code: .cc(.nul))), .key(KeyEvent(code: .char("@"), modifiers: .ctrl)),
    ]),
    .soh: .multi([
      .key(KeyEvent(code: .cc(.soh))), .key(KeyEvent(code: .char("a"), modifiers: .ctrl)),
    ]),
    .stx: .multi([
      .key(KeyEvent(code: .cc(.stx))), .key(KeyEvent(code: .char("b"), modifiers: .ctrl)),
    ]),
    .etx: .multi([
      .key(KeyEvent(code: .cc(.etx))), .key(KeyEvent(code: .char("c"), modifiers: .ctrl)),
    ]),
    .eot: .multi([
      .key(KeyEvent(code: .cc(.eot))), .key(KeyEvent(code: .char("d"), modifiers: .ctrl)),
    ]),
    .enq: .multi([
      .key(KeyEvent(code: .cc(.enq))), .key(KeyEvent(code: .char("e"), modifiers: .ctrl)),
    ]),
    .ack: .multi([
      .key(KeyEvent(code: .cc(.ack))), .key(KeyEvent(code: .char("f"), modifiers: .ctrl)),
    ]),
    .bel: .multi([
      .key(KeyEvent(code: .cc(.bel))), .key(KeyEvent(code: .char("g"), modifiers: .ctrl)),
    ]),
    .bs: .multi([
      .key(KeyEvent(code: .cc(.bs))), .key(KeyEvent(code: .char("h"), modifiers: .ctrl)),
    ]),
    .ht: .multi([
      .key(KeyEvent(code: .cc(.ht))), .key(KeyEvent(code: .char("i"), modifiers: .ctrl)),
    ]),
    .lf: .multi([
      .key(KeyEvent(code: .cc(.lf))), .key(KeyEvent(code: .char("j"), modifiers: .ctrl)),
    ]),
    .vt: .multi([
      .key(KeyEvent(code: .cc(.vt))), .key(KeyEvent(code: .char("k"), modifiers: .ctrl)),
    ]),
    .ff: .multi([
      .key(KeyEvent(code: .cc(.ff))), .key(KeyEvent(code: .char("l"), modifiers: .ctrl)),
    ]),
    .cr: .multi([
      .key(KeyEvent(code: .cc(.cr))), .key(KeyEvent(code: .char("m"), modifiers: .ctrl)),
    ]),
    .so: .multi([
      .key(KeyEvent(code: .cc(.so))), .key(KeyEvent(code: .char("n"), modifiers: .ctrl)),
    ]),
    .si: .multi([
      .key(KeyEvent(code: .cc(.si))), .key(KeyEvent(code: .char("o"), modifiers: .ctrl)),
    ]),
    .dle: .multi([
      .key(KeyEvent(code: .cc(.dle))), .key(KeyEvent(code: .char("p"), modifiers: .ctrl)),
    ]),
    .dc1: .multi([
      .key(KeyEvent(code: .cc(.dc1))), .key(KeyEvent(code: .char("q"), modifiers: .ctrl)),
    ]),
    .dc2: .multi([
      .key(KeyEvent(code: .cc(.dc2))), .key(KeyEvent(code: .char("r"), modifiers: .ctrl)),
    ]),
    .dc3: .multi([
      .key(KeyEvent(code: .cc(.dc3))), .key(KeyEvent(code: .char("s"), modifiers: .ctrl)),
    ]),
    .dc4: .multi([
      .key(KeyEvent(code: .cc(.dc4))), .key(KeyEvent(code: .char("t"), modifiers: .ctrl)),
    ]),
    .nak: .multi([
      .key(KeyEvent(code: .cc(.nak))), .key(KeyEvent(code: .char("u"), modifiers: .ctrl)),
    ]),
    .syn: .multi([
      .key(KeyEvent(code: .cc(.syn))), .key(KeyEvent(code: .char("v"), modifiers: .ctrl)),
    ]),
    .etb: .multi([
      .key(KeyEvent(code: .cc(.etb))), .key(KeyEvent(code: .char("w"), modifiers: .ctrl)),
    ]),
    .can: .multi([
      .key(KeyEvent(code: .cc(.can))), .key(KeyEvent(code: .char("x"), modifiers: .ctrl)),
    ]),
    .em: .multi([
      .key(KeyEvent(code: .cc(.em))), .key(KeyEvent(code: .char("y"), modifiers: .ctrl)),
    ]),
    .sub: .multi([
      .key(KeyEvent(code: .cc(.sub))), .key(KeyEvent(code: .char("z"), modifiers: .ctrl)),
    ]),
    .esc: .multi([
      .key(KeyEvent(code: .cc(.esc))), .key(KeyEvent(code: .char("["), modifiers: .ctrl)),
    ]),
    .fs: .multi([
      .key(KeyEvent(code: .cc(.fs))), .key(KeyEvent(code: .char("\\"), modifiers: .ctrl)),
    ]),
    .gs: .multi([
      .key(KeyEvent(code: .cc(.gs))), .key(KeyEvent(code: .char("]"), modifiers: .ctrl)),
    ]),
    .rs: .multi([
      .key(KeyEvent(code: .cc(.rs))), .key(KeyEvent(code: .char("^"), modifiers: .ctrl)),
    ]),
    .us: .multi([
      .key(KeyEvent(code: .cc(.us))), .key(KeyEvent(code: .char("_"), modifiers: .ctrl)),
    ]),
    .del: .multi([
      .key(KeyEvent(code: .cc(.del))), .key(KeyEvent(code: .char("?"), modifiers: .ctrl)),
    ]),
  ]

  public static let escapeEvent: [[UInt8]: Event.Match] = {
    var s: [[UInt8]: Event.Match] = [:]
    for (bytes, event) in csiEventBase {
      s[bytes] = .single(event)
      if case let .key(keyEvent) = event, keyEvent.modifiers?.contains(.alt) ?? false == false {
        let updatedBytes = [0x1B] + bytes
        let updatedEvent = keyEvent.copy(modifiers: keyEvent.modifiers?.union(.alt) ?? .alt)
        s[updatedBytes] = .single(.key(updatedEvent))
      }
    }

    // ALT+CHAR
    (0x20...0x7E).forEach { byte in
      s[[0x1B, byte]] = .single(.key(KeyEvent(code: .charFromByte(byte), modifiers: .alt)))
    }
    // ALT+SPACE
    s[[0x1B, 0x20]] = .single(.key(KeyEvent(code: .char(" "), modifiers: .alt)))
    // ALT+ESCAPE
    s[[0x1B, 0x1B]] = .single(.key(KeyEvent(code: .escape, modifiers: .alt)))

    return s
  }()

  private static let csiEventBase: [[UInt8]: Event] = [
    // Arrow keys
    Csi(.cuu).bytes: .key(KeyEvent(code: .up)),
    Csi(.cud).bytes: .key(KeyEvent(code: .down)),
    Csi(.cuf).bytes: .key(KeyEvent(code: .right)),
    Csi(.cub).bytes: .key(KeyEvent(code: .left)),

    Csi([1, 2], .cuu).bytes: .key(KeyEvent(code: .up, modifiers: .shift)),
    Csi([1, 2], .cud).bytes: .key(KeyEvent(code: .down, modifiers: .shift)),
    Csi([1, 2], .cuf).bytes: .key(KeyEvent(code: .right, modifiers: .shift)),
    Csi([1, 2], .cub).bytes: .key(KeyEvent(code: .left, modifiers: .shift)),

    Csi([0], .cuu).bytes: .key(KeyEvent(code: .up, modifiers: .shift)),  // DECCKM
    Csi([0], .cud).bytes: .key(KeyEvent(code: .down, modifiers: .shift)),  // DECCKM
    Csi([0], .cuf).bytes: .key(KeyEvent(code: .right, modifiers: .shift)),  // DECCKM
    Csi([0], .cub).bytes: .key(KeyEvent(code: .left, modifiers: .shift)),  // DECCKM

    Csi(ControlFunction(final: 0x61)!).bytes: .key(KeyEvent(code: .up, modifiers: .shift)),  // urxvt
    Csi(ControlFunction(final: 0x62)!).bytes:
      .key(KeyEvent(code: .down, modifiers: .shift)),  // urxvt
    Csi(ControlFunction(final: 0x63)!).bytes:
      .key(KeyEvent(code: .right, modifiers: .shift)),  // urxvt
    Csi(ControlFunction(final: 0x64)!).bytes:
      .key(KeyEvent(code: .left, modifiers: .shift)),  // urxvt

    Csi([1, 3], .cuu).bytes: .key(KeyEvent(code: .up, modifiers: .alt)),
    Csi([1, 3], .cud).bytes: .key(KeyEvent(code: .down, modifiers: .alt)),
    Csi([1, 3], .cuf).bytes: .key(KeyEvent(code: .right, modifiers: .alt)),
    Csi([1, 3], .cub).bytes: .key(KeyEvent(code: .left, modifiers: .alt)),

    Csi([1, 4], .cuu).bytes: .key(KeyEvent(code: .up, modifiers: [.alt, .shift])),
    Csi([1, 4], .cud).bytes: .key(KeyEvent(code: .down, modifiers: [.alt, .shift])),
    Csi([1, 4], .cuf).bytes: .key(KeyEvent(code: .right, modifiers: [.alt, .shift])),
    Csi([1, 4], .cub).bytes: .key(KeyEvent(code: .left, modifiers: [.alt, .shift])),

    Csi([1, 5], .cuu).bytes: .key(KeyEvent(code: .up, modifiers: .ctrl)),
    Csi([1, 5], .cud).bytes: .key(KeyEvent(code: .down, modifiers: .ctrl)),
    Csi([1, 5], .cuf).bytes: .key(KeyEvent(code: .right, modifiers: .ctrl)),
    Csi([1, 5], .cub).bytes: .key(KeyEvent(code: .left, modifiers: .ctrl)),

    Csi([0], ControlFunction(final: 0x61)!).bytes:
      .key(
        KeyEvent(code: .up, modifiers: [.alt, .ctrl])),  // urxvt
    Csi([0], ControlFunction(final: 0x62)!).bytes:
      .key(
        KeyEvent(code: .down, modifiers: [.alt, .ctrl])),  // urxvt
    Csi([0], ControlFunction(final: 0x63)!).bytes:
      .key(
        KeyEvent(code: .right, modifiers: [.alt, .ctrl])),  // urxvt
    Csi([0], ControlFunction(final: 0x64)!).bytes:
      .key(
        KeyEvent(code: .left, modifiers: [.alt, .ctrl])),  // urxvt

    Csi([1, 6], .cuu).bytes: .key(KeyEvent(code: .up, modifiers: [.ctrl, .shift])),
    Csi([1, 6], .cud).bytes: .key(KeyEvent(code: .down, modifiers: [.ctrl, .shift])),
    Csi([1, 6], .cuf).bytes: .key(KeyEvent(code: .right, modifiers: [.ctrl, .shift])),
    Csi([1, 6], .cub).bytes: .key(KeyEvent(code: .left, modifiers: [.ctrl, .shift])),

    Csi([1, 7], .cuu).bytes: .key(KeyEvent(code: .up, modifiers: [.alt, .ctrl])),
    Csi([1, 7], .cud).bytes: .key(KeyEvent(code: .down, modifiers: [.alt, .ctrl])),
    Csi([1, 7], .cuf).bytes: .key(KeyEvent(code: .right, modifiers: [.alt, .ctrl])),
    Csi([1, 7], .cub).bytes: .key(KeyEvent(code: .left, modifiers: [.alt, .ctrl])),

    Csi([1, 8], .cuu).bytes: .key(KeyEvent(code: .up, modifiers: [.ctrl, .alt, .shift])),
    Csi([1, 8], .cud).bytes:
      .key(KeyEvent(code: .down, modifiers: [.ctrl, .alt, .shift])),
    Csi([1, 8], .cuf).bytes:
      .key(KeyEvent(code: .right, modifiers: [.ctrl, .alt, .shift])),
    Csi([1, 8], .cub).bytes:
      .key(KeyEvent(code: .left, modifiers: [.ctrl, .alt, .shift])),

    // Miscellaneous keys
    Csi(.cbt).bytes: .key(KeyEvent(code: .tab, modifiers: .shift)),

    Csi(2, .kbc).bytes: .key(KeyEvent(code: .insert)),
    Csi([3, 2], .kbc).bytes: .key(KeyEvent(code: .insert, modifiers: .alt)),

    Csi(3, .kbc).bytes: .key(KeyEvent(code: .delete)),
    Csi([3, 3], .kbc).bytes: .key(KeyEvent(code: .delete, modifiers: .alt)),
  ]

  static let altKeyEvent: [[UInt8]: Event.Match] = [
    // "¡" (U+00A1) – Alt+1
    [UInt8](Character("¡").utf8): .multi([
      .key(KeyEvent(code: .char("¡"))),
      .key(KeyEvent(code: .char("1"), modifiers: .alt)),
    ]),
    // "¢" (U+00A2) – Alt+4
    [UInt8](Character("¢").utf8): .multi([
      .key(KeyEvent(code: .char("¢"))),
      .key(KeyEvent(code: .char("4"), modifiers: .alt)),
    ]),
    // "£" (U+00A3) – Alt+3
    [UInt8](Character("£").utf8): .multi([
      .key(KeyEvent(code: .char("£"))),
      .key(KeyEvent(code: .char("3"), modifiers: .alt)),
    ]),
    // "¥" (U+00A5) – Alt+Y
    [UInt8](Character("¥").utf8): .multi([
      .key(KeyEvent(code: .char("¥"))),
      .key(KeyEvent(code: .char("y"), modifiers: .alt)),
    ]),
    // "§" (U+00A7) – Alt+6
    [UInt8](Character("§").utf8): .multi([
      .key(KeyEvent(code: .char("§"))),
      .key(KeyEvent(code: .char("6"), modifiers: .alt)),
    ]),
    // "¨" (U+00A8) – Alt+U
    [UInt8](Character("¨").utf8): .multi([
      .key(KeyEvent(code: .char("¨"))),
      .key(KeyEvent(code: .char("u"), modifiers: .alt)),
    ]),
    // "©" (U+00A9) – Alt+G
    [UInt8](Character("©").utf8): .multi([
      .key(KeyEvent(code: .char("©"))),
      .key(KeyEvent(code: .char("g"), modifiers: .alt)),
    ]),
    // "ª" (U+00AA) – Alt+9
    [UInt8](Character("ª").utf8): .multi([
      .key(KeyEvent(code: .char("ª"))),
      .key(KeyEvent(code: .char("9"), modifiers: .alt)),
    ]),
    // "«" (U+00AB) – Alt+\
    [UInt8](Character("«").utf8): .multi([
      .key(KeyEvent(code: .char("«"))),
      .key(KeyEvent(code: .char("\\"), modifiers: .alt)),
    ]),
    // "¬" (U+00AC) – Alt+L
    [UInt8](Character("¬").utf8): .multi([
      .key(KeyEvent(code: .char("¬"))),
      .key(KeyEvent(code: .char("l"), modifiers: .alt)),
    ]),
    // "®" (U+00AE) – Alt+R
    [UInt8](Character("®").utf8): .multi([
      .key(KeyEvent(code: .char("®"))),
      .key(KeyEvent(code: .char("r"), modifiers: .alt)),
    ]),
    // "´" (U+00B4) – Alt+E
    [UInt8](Character("´").utf8): .multi([
      .key(KeyEvent(code: .char("´"))),
      .key(KeyEvent(code: .char("e"), modifiers: .alt)),
    ]),
    // "µ" (U+00B5) – Alt+M
    [UInt8](Character("µ").utf8): .multi([
      .key(KeyEvent(code: .char("µ"))),
      .key(KeyEvent(code: .char("m"), modifiers: .alt)),
    ]),
    // "¶" (U+00B6) – Alt+7
    [UInt8](Character("¶").utf8): .multi([
      .key(KeyEvent(code: .char("¶"))),
      .key(KeyEvent(code: .char("7"), modifiers: .alt)),
    ]),
    // "º" (U+00BA) – Alt+0
    [UInt8](Character("º").utf8): .multi([
      .key(KeyEvent(code: .char("º"))),
      .key(KeyEvent(code: .char("0"), modifiers: .alt)),
    ]),
    // "ß" (U+00DF) - Alt+S
    [UInt8](Character("ß").utf8): .multi([
      .key(KeyEvent(code: .char("ß"))),
      .key(KeyEvent(code: .char("s"), modifiers: .alt)),
    ]),
    // "å" (U+00E5) – Alt+A
    [UInt8](Character("å").utf8): .multi([
      .key(KeyEvent(code: .char("å"))),
      .key(KeyEvent(code: .char("a"), modifiers: .alt)),
    ]),
    // "æ" (U+00E6) – Alt+'
    [UInt8](Character("æ").utf8): .multi([
      .key(KeyEvent(code: .char("æ"))),
      .key(KeyEvent(code: .char("'"), modifiers: .alt)),
    ]),
    // "ç" (U+00E7) – Alt+C
    [UInt8](Character("ç").utf8): .multi([
      .key(KeyEvent(code: .char("ç"))),
      .key(KeyEvent(code: .char("c"), modifiers: .alt)),
    ]),
    // "÷" (U+00F7) – Alt+/
    [UInt8](Character("÷").utf8): .multi([
      .key(KeyEvent(code: .char("÷"))),
      .key(KeyEvent(code: .char("/"), modifiers: .alt)),
    ]),
    // "ø" (U+00F8) – Alt+O
    [UInt8](Character("ø").utf8): .multi([
      .key(KeyEvent(code: .char("ø"))),
      .key(KeyEvent(code: .char("o"), modifiers: .alt)),
    ]),
    // "œ" (U+0153) – Alt+Q
    [UInt8](Character("œ").utf8): .multi([
      .key(KeyEvent(code: .char("œ"))),
      .key(KeyEvent(code: .char("q"), modifiers: .alt)),
    ]),
    // "ƒ" (U+0192) – Alt+F
    [UInt8](Character("ƒ").utf8): .multi([
      .key(KeyEvent(code: .char("ƒ"))),
      .key(KeyEvent(code: .char("f"), modifiers: .alt)),
    ]),
    // "ˆ" (U+02C6) – Alt+I
    [UInt8](Character("ˆ").utf8): .multi([
      .key(KeyEvent(code: .char("ˆ"))),
      .key(KeyEvent(code: .char("i"), modifiers: .alt)),
    ]),
    // "˙" (U+02D9) – Alt+H
    [UInt8](Character("˙").utf8): .multi([
      .key(KeyEvent(code: .char("˙"))),
      .key(KeyEvent(code: .char("h"), modifiers: .alt)),
    ]),
    // "˚" (U+02DA) – Alt+K
    [UInt8](Character("˚").utf8): .multi([
      .key(KeyEvent(code: .char("˚"))),
      .key(KeyEvent(code: .char("k"), modifiers: .alt)),
    ]),
    // "˜" (U+02DC) – Alt+N
    [UInt8](Character("˜").utf8): .multi([
      .key(KeyEvent(code: .char("˜"))),
      .key(KeyEvent(code: .char("n"), modifiers: .alt)),
    ]),
    // "Ω" (U+03A9) – Alt+Z
    [UInt8](Character("Ω").utf8): .multi([
      .key(KeyEvent(code: .char("Ω"))),
      .key(KeyEvent(code: .char("z"), modifiers: .alt)),
    ]),
    // "π" (U+03C0) – Alt+P
    [UInt8](Character("π").utf8): .multi([
      .key(KeyEvent(code: .char("π"))),
      .key(KeyEvent(code: .char("p"), modifiers: .alt)),
    ]),
    // "–" (U+2013) – Alt+-
    [UInt8](Character("–").utf8): .multi([
      .key(KeyEvent(code: .char("–"))),
      .key(KeyEvent(code: .char("-"), modifiers: .alt)),
    ]),
    // "“" (U+201C) – Alt+[
    [UInt8](Character("“").utf8): .multi([
      .key(KeyEvent(code: .char("“"))),
      .key(KeyEvent(code: .char("["), modifiers: .alt)),
    ]),
    // "'" (U+2018) – Alt+]
    [UInt8](Character("'").utf8): .multi([
      .key(KeyEvent(code: .char("'"))),
      .key(KeyEvent(code: .char("]"), modifiers: .alt)),
    ]),
    // "†" (U+2020) – Alt+T
    [UInt8](Character("†").utf8): .multi([
      .key(KeyEvent(code: .char("†"))),
      .key(KeyEvent(code: .char("t"), modifiers: .alt)),
    ]),
    // "•" (U+2022) – Alt+8
    [UInt8](Character("•").utf8): .multi([
      .key(KeyEvent(code: .char("•"))),
      .key(KeyEvent(code: .char("8"), modifiers: .alt)),
    ]),
    // "…" (U+2026) – Alt+;
    [UInt8](Character("…").utf8): .multi([
      .key(KeyEvent(code: .char("…"))),
      .key(KeyEvent(code: .char(";"), modifiers: .alt)),
    ]),
    // "™" (U+2122) – Alt+2
    [UInt8](Character("™").utf8): .multi([
      .key(KeyEvent(code: .char("™"))),
      .key(KeyEvent(code: .char("2"), modifiers: .alt)),
    ]),
    // "∂" (U+2202) – Alt+D
    [UInt8](Character("∂").utf8): .multi([
      .key(KeyEvent(code: .char("∂"))),
      .key(KeyEvent(code: .char("d"), modifiers: .alt)),
    ]),
    // "∆" (U+2206) – Alt+J
    [UInt8](Character("∆").utf8): .multi([
      .key(KeyEvent(code: .char("∆"))),
      .key(KeyEvent(code: .char("j"), modifiers: .alt)),
    ]),
    // "∑" (U+2211) – Alt+W
    [UInt8](Character("∑").utf8): .multi([
      .key(KeyEvent(code: .char("∑"))),
      .key(KeyEvent(code: .char("w"), modifiers: .alt)),
    ]),
    // "√" (U+221A) – Alt+V
    [UInt8](Character("√").utf8): .multi([
      .key(KeyEvent(code: .char("√"))),
      .key(KeyEvent(code: .char("v"), modifiers: .alt)),
    ]),
    // "∞" (U+221E) – Alt+5
    [UInt8](Character("∞").utf8): .multi([
      .key(KeyEvent(code: .char("∞"))),
      .key(KeyEvent(code: .char("5"), modifiers: .alt)),
    ]),
    // "∫" (U+222B) – Alt+B
    [UInt8](Character("∫").utf8): .multi([
      .key(KeyEvent(code: .char("∫"))),
      .key(KeyEvent(code: .char("b"), modifiers: .alt)),
    ]),
    // "≈" (U+2248) – Alt+X
    [UInt8](Character("≈").utf8): .multi([
      .key(KeyEvent(code: .char("≈"))),
      .key(KeyEvent(code: .char("x"), modifiers: .alt)),
    ]),
    // "≠" (U+2260) – Alt+=
    [UInt8](Character("≠").utf8): .multi([
      .key(KeyEvent(code: .char("≠"))),
      .key(KeyEvent(code: .char("="), modifiers: .alt)),
    ]),
    // "≤" (U+2264) – Alt+,
    [UInt8](Character("≤").utf8): .multi([
      .key(KeyEvent(code: .char("≤"))),
      .key(KeyEvent(code: .char(","), modifiers: .alt)),
    ]),
    // "≥" (U+2265) – Alt+.
    [UInt8](Character("≥").utf8): .multi([
      .key(KeyEvent(code: .char("≥"))),
      .key(KeyEvent(code: .char("."), modifiers: .alt)),
    ]),
  ]
}
