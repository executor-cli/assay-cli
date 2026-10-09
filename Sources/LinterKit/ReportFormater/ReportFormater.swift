import Foundation

public protocol ReportFormater: Sendable {
    func report(from data: Data, verbose: Bool) throws
}
