import Foundation

/// Represents a file with a name
public class NamedFile {
    public let data: Data

    /// Filename with extension e.g. "test.txt"
    public let name: String
    
    public init(name: String, data: Data) {
        assert(!name.isEmpty)
        assert(!data.isEmpty)
        
        self.name = name
        self.data = data
    }
    
    /// Check the file extension and file header signature (SOI marker)
    func isJpeg() -> Bool {
        guard data.count > 2 else { return false }
        
        let hasRightName = name.hasSuffix(".jpg") || name.hasSuffix(".jpeg")
        if !hasRightName { return false }
        
        /// Checks jpeg SOI marker
        var byteArray = [UInt8](repeating: 0, count: 2)
        data.copyBytes(to: &byteArray, count: 2)
        let correctSignature: [UInt8] = [0xFF, 0xD8]
        let rightHeader = byteArray == correctSignature
        
        return hasRightName && rightHeader
    }
}

extension NamedFile: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(data)
    }
    
    public static func == (lhs: NamedFile, rhs: NamedFile) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
