import Foundation
@testable import SwiftGraphStore

extension Index {
    static var testInstance: Index {
        let secondsPerYear = 60*60*24*365
        let offset = (-secondsPerYear...0).randomElement()!
        let date = Date(timeIntervalSinceNow: Double(offset))
        return Index(date: date)
    }
}
