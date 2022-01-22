import Foundation
import BigInt

// TODO: allow this index to be based off a @da, instead of a swift `Date`
public struct Index {
    public let values: [BigUInt]

    public init(value: BigUInt) {
        self.init(values: [value])
    }

    public init(values: [BigUInt]) {
        self.values = values
    }
}

extension Index: RawRepresentable {
    public var rawValue: String {
        string
    }
    
    public init?(rawValue: String) {
        guard let stringValues = Self.valuesFromString(string: rawValue) else {
            return nil
        }
        values = stringValues
    }
}

extension Index {
    public init(date: Date = .now) {
        self.init(value: BigUInt(date.timeIntervalSinceReferenceDate * 1000))
    }
}

extension Index {
    public init?(_ string: String) {
        self.init(rawValue: string)
    }
    
    public var stringWithSeparators: String {
        let strings = values.map { value in
            String(value)
                .split(every: 3)
                .joined(separator: ".")
        }
        return makePath(strings)
    }
    
    public var string: String {
        let strings = values.map { String($0) }
        return makePath(strings)
    }
    
    private func makePath(_ strings: [String]) -> String {
        if strings.count == 1 {
            return strings.joined()
        } else {
            return "/" + strings.joined(separator: "/")
        }
    }
    
    private static func valuesFromString(string: String) -> [BigUInt]? {
        let values = string.split(separator: "/")
            .map { $0.split(separator: ".").joined() }
            .map { BigUInt($0) }
        
        if values.contains(where: {$0 == nil }) {
            return nil
        } else {
            return values.compactMap { $0 }
        }
    }
    
    public static func convertStringDictionary<T>(_ dict: [String: T]) throws -> [Index: T] {
        var newDict = [Index: T]()
        try dict.forEach { (key, value) in
            guard let indexKey = Index(key) else {
                throw NSError()
            }
            newDict[indexKey] = value
        }
        return newDict
    }
    
    public static func convertIndexDictionary<T>(_ dict: [Index: T]) -> [String: T] {
        var newDict = [String: T]()
        dict.forEach { (key, value) in
            newDict[key.string] = value
        }
        return newDict
    }
}

extension Index: Codable {}

extension Index: Equatable {}

extension Index: Hashable {
    public func hash(into hasher: inout Hasher) {
        values.forEach { hasher.combine($0) }
    }
}

extension Index: Comparable {
    public static func < (lhs: Index, rhs: Index) -> Bool {
        for (lhs, rhs) in zip(lhs.values, rhs.values) {
            if lhs < rhs {
                return true
            } else if rhs < lhs {
                return false
            }
        }
        
        return false
    }
}

extension Index: CustomStringConvertible {
    public var description: String {
        string
    }
}

fileprivate extension String {
    func split(every: Int) -> [String] {
        var result = [String]()
        for i in stride(from: 0, to: self.count, by: every) {
            let endIndex = self.index(self.endIndex, offsetBy: -i)
            let startIndex = self.index(endIndex, offsetBy: -every, limitedBy: self.startIndex) ?? self.startIndex
            result.insert(String(self[startIndex..<endIndex]), at: 0)
        }
        return result
    }
}
