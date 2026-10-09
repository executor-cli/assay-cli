import Foundation
import Path
@testable import FormatKit

final class FormatterProviderMock: FormatterProvider, @unchecked Sendable {
    // MARK: - format

    private(set) var formatCallsCount = 0
    var formatCalled: Bool {
        formatCallsCount > 0
    }

    private(set) var formatReceivedArguments: (paths: [AbsolutePath], args: String)?
    private(set) var formatReceivedInvocations: [(paths: [AbsolutePath], args: String)] = []

    func format(_ paths: [AbsolutePath], args: String) {
        formatCallsCount += 1
        formatReceivedArguments = (paths: paths, args: args)
        formatReceivedInvocations.append((paths: paths, args: args))
    }
}
