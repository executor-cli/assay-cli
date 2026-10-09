//
//  ReportFormaterMock.swift
//  executor
//
//  Created by unit tests
//
import Foundation
@testable import LinterKit

final class ReportFormaterMock: ReportFormater {
    // MARK: - report

    var reportCallsCount = 0
    var reportCalled: Bool {
        reportCallsCount > 0
    }

    var reportReceivedData: Data?
    var reportReceivedArguments: (data: Data, verbose: Bool)?
    var reportReceivedInvocations: [(data: Data, verbose: Bool)] = []
    var reportThrowableError: Error?

    func report(from data: Data, verbose: Bool) throws {
        reportCallsCount += 1
        reportReceivedData = data
        reportReceivedArguments = (data: data, verbose: verbose)
        reportReceivedInvocations.append((data: data, verbose: verbose))

        if let error = reportThrowableError {
            throw error
        }
    }
}
