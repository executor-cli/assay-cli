import Foundation
import Path
import XCTest
@testable import LinterKit

final class LinterRunnerDefaultTests: XCTestCase {
    // MARK: - Tests

    func test_runner_executes_service_with_correct_parameters() throws {
        // GIVEN
        let serviceMock = LinterServiceMock()
        let formaterMock = ReportFormaterMock()
        let paths = [AbsolutePath.temporary]
        let linterType = LinterType.json
        let verbose = true

        serviceMock.executeReturnValue = "[]".data(using: .utf8)!

        let runner = LinterRunnerDefault(
            reportFormater: formaterMock,
            service: serviceMock,
            linterType: linterType
        )

        // WHEN
        try runner.execute(forPaths: paths, throwError: false, verbose: verbose)

        // THEN
        XCTAssertTrue(serviceMock.executeCalled)
        XCTAssertEqual(serviceMock.executeCallsCount, 1)
        XCTAssertEqual(serviceMock.executeReceivedArguments?.paths, paths)
        XCTAssertEqual(serviceMock.executeReceivedArguments?.reporter, linterType)
        XCTAssertEqual(serviceMock.executeReceivedArguments?.verbose, verbose)
    }

    func test_runner_calls_report_formatter_with_service_results() throws {
        // GIVEN
        let serviceMock = LinterServiceMock()
        let formaterMock = ReportFormaterMock()
        let expectedData = "test data".data(using: .utf8)!

        serviceMock.executeReturnValue = expectedData

        let runner = LinterRunnerDefault(
            reportFormater: formaterMock,
            service: serviceMock,
            linterType: .json
        )

        // WHEN
        try runner.execute(forPaths: [], throwError: false, verbose: false)

        // THEN
        XCTAssertTrue(formaterMock.reportCalled)
        XCTAssertEqual(formaterMock.reportCallsCount, 1)
        XCTAssertEqual(formaterMock.reportReceivedData, expectedData)
    }

    func test_runner_throws_notPresentDocumentation_when_violations_and_throwError_true() throws {
        // GIVEN
        let serviceMock = LinterServiceMock()
        let formaterMock = ReportFormaterMock()
        let violationsData = createViolationsData()

        serviceMock.executeReturnValue = violationsData

        let runner = LinterRunnerDefault(
            reportFormater: formaterMock,
            service: serviceMock,
            linterType: .json
        )

        // WHEN & THEN
        XCTAssertThrowsError(
            try runner.execute(forPaths: [], throwError: true, verbose: false)
        ) { error in
            XCTAssertTrue(error is LinterError)
            if let linterError = error as? LinterError {
                XCTAssertEqual(linterError, .detectedSwiftLintError)
            }
        }
    }

    func test_runner_does_not_throw_when_violations_but_throwError_false() throws {
        // GIVEN
        let serviceMock = LinterServiceMock()
        let formaterMock = ReportFormaterMock()
        let violationsData = createViolationsData()

        serviceMock.executeReturnValue = violationsData

        let runner = LinterRunnerDefault(
            reportFormater: formaterMock,
            service: serviceMock,
            linterType: .json
        )

        // WHEN & THEN
        XCTAssertNoThrow(
            try runner.execute(forPaths: [], throwError: false, verbose: false)
        )
    }

    func test_runner_does_not_throw_when_no_violations_regardless_throwError() throws {
        // GIVEN
        let serviceMock = LinterServiceMock()
        let formaterMock = ReportFormaterMock()
        let emptyData = "{}".data(using: .utf8)!

        serviceMock.executeReturnValue = emptyData

        let runner = LinterRunnerDefault(
            reportFormater: formaterMock,
            service: serviceMock,
            linterType: .json
        )

        // WHEN & THEN - throwError: true but no violations
        XCTAssertNoThrow(
            try runner.execute(forPaths: [], throwError: true, verbose: false)
        )

        // WHEN & THEN - throwError: false and no violations
        XCTAssertNoThrow(
            try runner.execute(forPaths: [], throwError: false, verbose: false)
        )
    }

    func test_runner_passes_verbose_flag_to_service() throws {
        // GIVEN
        let serviceMock = LinterServiceMock()
        let formaterMock = ReportFormaterMock()
        serviceMock.executeReturnValue = "[]".data(using: .utf8)!

        let runner = LinterRunnerDefault(
            reportFormater: formaterMock,
            service: serviceMock,
            linterType: .console
        )

        // WHEN - verbose true
        try runner.execute(forPaths: [], throwError: false, verbose: true)

        // THEN
        XCTAssertEqual(serviceMock.executeReceivedArguments?.verbose, true)

        // WHEN - verbose false
        try runner.execute(forPaths: [], throwError: false, verbose: false)

        // THEN
        XCTAssertEqual(serviceMock.executeReceivedArguments?.verbose, false)
    }

    func test_runner_propagates_service_errors() throws {
        // GIVEN
        let serviceMock = LinterServiceMock()
        let formaterMock = ReportFormaterMock()
        let expectedError = NSError(domain: "test", code: 1, userInfo: nil)

        serviceMock.executeThrowableError = expectedError

        let runner = LinterRunnerDefault(
            reportFormater: formaterMock,
            service: serviceMock,
            linterType: .json
        )

        // WHEN & THEN
        XCTAssertThrowsError(
            try runner.execute(forPaths: [], throwError: false, verbose: false)
        ) { error in
            XCTAssertEqual(error as NSError, expectedError)
        }
    }

    func test_runner_propagates_formatter_errors() throws {
        // GIVEN
        let serviceMock = LinterServiceMock()
        let formaterMock = ReportFormaterMock()
        let expectedError = NSError(domain: "formatter", code: 2, userInfo: nil)

        serviceMock.executeReturnValue = "[]".data(using: .utf8)!
        formaterMock.reportThrowableError = expectedError

        let runner = LinterRunnerDefault(
            reportFormater: formaterMock,
            service: serviceMock,
            linterType: .json
        )

        // WHEN & THEN
        XCTAssertThrowsError(
            try runner.execute(forPaths: [], throwError: false, verbose: false)
        ) { error in
            XCTAssertEqual(error as NSError, expectedError)
        }
    }

    func test_runner_with_multiple_paths() throws {
        // GIVEN
        let serviceMock = LinterServiceMock()
        let formaterMock = ReportFormaterMock()
        let paths = [
            AbsolutePath.temporary,
            AbsolutePath.currentWorkingDirectory
        ]

        serviceMock.executeReturnValue = "[]".data(using: .utf8)!

        let runner = LinterRunnerDefault(
            reportFormater: formaterMock,
            service: serviceMock,
            linterType: .json
        )

        // WHEN
        try runner.execute(forPaths: paths, throwError: false, verbose: false)

        // THEN
        XCTAssertEqual(serviceMock.executeReceivedArguments?.paths.count, 2)
        XCTAssertEqual(serviceMock.executeReceivedArguments?.paths, paths)
    }

    func test_runner_with_different_linter_types() throws {
        // GIVEN
        let serviceMock = LinterServiceMock()
        let formaterMock = ReportFormaterMock()
        serviceMock.executeReturnValue = "[]".data(using: .utf8)!

        let types: [LinterType] = [.console, .json, .codeQuality]

        for type in types {
            let runner = LinterRunnerDefault(
                reportFormater: formaterMock,
                service: serviceMock,
                linterType: type
            )

            // WHEN
            try runner.execute(forPaths: [], throwError: false, verbose: false)

            // THEN
            XCTAssertEqual(serviceMock.executeReceivedArguments?.reporter, type)
        }
    }

    func test_runner_calls_formatter_before_checking_errors() throws {
        // GIVEN
        let serviceMock = LinterServiceMock()
        let formaterMock = ReportFormaterMock()
        let violationsData = createViolationsData()

        serviceMock.executeReturnValue = violationsData

        let runner = LinterRunnerDefault(
            reportFormater: formaterMock,
            service: serviceMock,
            linterType: .json
        )

        // WHEN
        do {
            try runner.execute(forPaths: [], throwError: true, verbose: false)
        } catch {
            // Expected error
        }

        // THEN
        // Formatter should be called even though error is thrown
        XCTAssertTrue(formaterMock.reportCalled)
        XCTAssertEqual(formaterMock.reportCallsCount, 1)
    }

    func test_runner_with_empty_paths_array() throws {
        // GIVEN
        let serviceMock = LinterServiceMock()
        let formaterMock = ReportFormaterMock()
        serviceMock.executeReturnValue = "[]".data(using: .utf8)!

        let runner = LinterRunnerDefault(
            reportFormater: formaterMock,
            service: serviceMock,
            linterType: .json
        )

        // WHEN
        try runner.execute(forPaths: [], throwError: false, verbose: false)

        // THEN
        XCTAssertTrue(serviceMock.executeCalled)
        XCTAssertTrue(serviceMock.executeReceivedArguments?.paths.isEmpty ?? false)
    }

    // MARK: - Helper Methods

    private func createViolationsData() -> Data {
        let json = """
        [
            {
                "character": 8,
                "file": "/path/to/file.swift",
                "line": 15,
                "reason": "Missing documentation",
                "rule_id": "missing_docs",
                "severity": "warning",
                "type": "Documentation"
            }
        ]
        """
        return json.data(using: .utf8)!
    }
}
