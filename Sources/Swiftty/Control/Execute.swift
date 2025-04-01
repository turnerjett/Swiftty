public func execute(_ controlCode: ControlCode) {
    let ccByte = controlCode.rawValue
    StdOut.write(ccByte)
}

public func execute(_ controlCodes: [ControlCode]) {
    let ccBytes = controlCodes.map(\.rawValue)
    StdOut.write(ccBytes)
}

func execute(_ controlCodes: [ControlCode], params: [UInt8]) {
    let ccBytes = controlCodes.map(\.rawValue)
    let paramBytes = params
    // print(String(bytes: ccBytes.dropFirst() + paramBytes, encoding: .utf8)!)
    StdOut.write(ccBytes + paramBytes)
}

/// Control Codes (C0 and C1)
public enum ControlCode: UInt8, Equatable, Sendable {
    // C0 Control Codes
    /// Null
    case nul = 0  // CTRL+@
    /// Start of Header
    case soh = 1  // CTRL+A
    /// Start of Text
    case stx = 2  // CTRL+B
    /// End of Text
    case etx = 3  // CTRL+C
    /// End of Transmission
    case eot = 4  // CTRL+D
    /// Enquiry
    case enq = 5  // CTRL+E
    /// Acknowledge
    case ack = 6  // CTRL+F
    /// Bell
    case bel = 7  // CTRL+G
    /// Backspace
    case bs = 8  // CTRL+H
    /// Horizontal Tab
    case ht = 9  // CTRL+I
    /// Line Feed
    case lf = 10  // CTRL+J
    /// Vertical Tab
    case vt = 11  // CTRL+K
    /// Form Feed
    case ff = 12  // CTRL+L
    /// Carriage Return
    case cr = 13  // CTRL+M
    /// Shift Out
    case so = 14  // CTRL+N
    /// Shift In
    case si = 15  // CTRL+O
    /// Data Link Escape
    case dle = 16  // CTRL+P
    /// Device Control One
    case dc1 = 17  // CTRL+Q
    /// Device Control Two
    case dc2 = 18  // CTRL+R
    /// Device Control Three
    case dc3 = 19  // CTRL+S
    /// Device Control Four
    case dc4 = 20  // CTRL+T
    /// Negative Acknowledge
    case nak = 21  // CTRL+U
    /// Synchronous Idle
    case syn = 22  // CTRL+V
    /// End of Transmission Block
    case etb = 23  // CTRL+W
    /// Cancel
    case can = 24  // CTRL+X
    /// End of Medium
    case em = 25  // CTRL+Y
    /// Substitute
    case sub = 26  // CTRL+Z
    /// Escape
    case esc = 27  // CTRL+[
    /// File Separator
    case fs = 28  // CTRL+\
    /// Group Separator
    case gs = 29  // CTRL+]
    /// Record Separator
    case rs = 30  // CTRL+^
    /// Unit Separator
    case us = 31  // CTRL+_
    /// Delete
    case del = 127  // CTRL+?

    // C1 Control Codes (Non-exhaustive)
    /// Index
    case ind = 68  // 'D'
    /// Next Line
    case nel = 69  // 'E'
    /// Horizontal Tab Set
    case hts = 72  // 'H'
    /// Device Control String
    case dcs = 80  // 'P'
    /// Control Sequence Introducer
    case csi = 91  // '['
    /// String Terminator
    case st = 92  // '\'
    /// Operating System Command
    case osc = 93  // ']'
    /// Privacy Message
    case pm = 94  // '^'
    /// Application Program Command
    case apc = 95  // '_'
}
