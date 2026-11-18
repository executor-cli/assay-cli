import Foundation
import LinterKit

final class ReportFormaterMock: ReportFormater, @unchecked Sendable {
    var reportReceivedInvocations: [(data: Data, verbose: Bool)] = []

    func report(from data: Data, verbose: Bool) throws {
        reportReceivedInvocations.append((data: data, verbose: verbose))
    }
}
