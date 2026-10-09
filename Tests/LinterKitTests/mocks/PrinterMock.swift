import Foundation
import Path
@testable import LinterKit

final class PrinterMock: Printer, @unchecked Sendable {
    // MARK: - print

    var printCallsCount = 0
    var printCalled: Bool {
        printCallsCount > 0
    }

    var printReceivedArguments: String?
    var printReceivedInvocations: [String] = []
    var printClosure: ((String) -> Void)?

    func print(_ string: String) {
        printCallsCount += 1
        printReceivedArguments = string
        printReceivedInvocations.append(string)
        printClosure?(string)
    }
}
