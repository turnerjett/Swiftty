import Foundation

struct StdOut {
    static let handle = FileHandle.standardOutput
    public static func write(_ string: String) {
        FileHandle.standardOutput.write(Data(string.utf8))
    }

    public static func write(_ byte: UInt8) {
        FileHandle.standardOutput.write(Data([byte]))
    }

    public static func write(_ bytes: [UInt8]) {
        FileHandle.standardOutput.write(Data(bytes))
    }
}

struct StdIn {
    static let handle = FileHandle.standardInput
    public static func read() -> UInt8 {
        let data = readBytes(count: 1)
        return data.first ?? 0
    }

    public static func readBytes() -> [UInt8] {
        let data = FileHandle.standardInput.availableData
        return [UInt8](data)
    }

    public static func readBytes(count: Int) -> [UInt8] {
        guard count > 0 else { return [] }

        do {
            let data = try FileHandle.standardInput.read(upToCount: count)
            return [UInt8](data ?? Data())
        } catch {
            return []
        }
    }
}
