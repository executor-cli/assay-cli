import ExecutorCore
import Foundation
@testable import LinterKit

final class LinterServiceMock: LinterService {
    // MARK: - execute

    var executeCallsCount = 0
    var executeCalled: Bool {
        executeCallsCount > 0
    }

    var executeReceivedArguments: (paths: [AbsolutePath], reporter: LinterType, verbose: Bool)?
    var executeReceivedInvocations: [(
        paths: [AbsolutePath],
        reporter: LinterType,
        verbose: Bool
    )] = []
    var executeReturnValue: Data!
    var executeThrowableError: Error?

    func execute(
        forPaths paths: [AbsolutePath],
        reporter: LinterType,
        verbose: Bool
    ) throws -> Data {
        executeCallsCount += 1
        executeReceivedArguments = (paths: paths, reporter: reporter, verbose: verbose)
        executeReceivedInvocations.append((paths: paths, reporter: reporter, verbose: verbose))

        if let error = executeThrowableError {
            throw error
        }

        return executeReturnValue
    }
}
