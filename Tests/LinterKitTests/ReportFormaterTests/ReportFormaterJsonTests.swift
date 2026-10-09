//
//  ReportFormaterJsonTests.swift
//  executor
//
//  Created by unit tests
//
import ExecutorCore
import Foundation
import Path
import XCTest
@testable import LinterKit

final class ReportFormaterJsonTests: XCTestCase {
    // MARK: - Tests

    func test_decodes_swiftlint_json_correctly() throws {
        // GIVEN
        let swiftLintData = createSwiftLintData()
        let fileManagerMock = CreateFileServiceMock()
        let printerMock = PrinterMock()

        let formater = ReportFormaterJson(
            printer: printerMock,
            fileManager: fileManagerMock
        )

        // WHEN
        try formater.report(from: swiftLintData, verbose: false)

        // THEN
        XCTAssertTrue(fileManagerMock.createFileAtPathContentsAttributesCalled)
    }

    func test_creates_file_with_default_name() throws {
        // GIVEN
        let outputFileURL: AbsolutePath = .temporary
        let fileManagerMock = CreateFileServiceMock()
        let printerMock = PrinterMock()
        let swiftLintData = createSwiftLintData()

        let formater = ReportFormaterJson(
            printer: printerMock,
            outputURL: outputFileURL,
            fileManager: fileManagerMock
        )

        // WHEN
        try formater.report(from: swiftLintData, verbose: false)

        // THEN
        let expectedPath = outputFileURL.appending(component: "documentation-linter.json").pathString
        XCTAssertEqual(
            fileManagerMock.createFileAtPathContentsAttributesReceivedArguments?.path,
            expectedPath
        )
    }

    func test_creates_file_with_custom_name() throws {
        // GIVEN
        let customFileName = "custom-linter-report.json"
        let outputFileURL: AbsolutePath = .temporary
        let fileManagerMock = CreateFileServiceMock()
        let printerMock = PrinterMock()
        let swiftLintData = createSwiftLintData()

        let formater = ReportFormaterJson(
            printer: printerMock,
            fileName: customFileName,
            outputURL: outputFileURL,
            fileManager: fileManagerMock
        )

        // WHEN
        try formater.report(from: swiftLintData, verbose: false)

        // THEN
        let expectedPath = outputFileURL.appending(component: customFileName).pathString
        XCTAssertEqual(
            fileManagerMock.createFileAtPathContentsAttributesReceivedArguments?.path,
            expectedPath
        )
    }

    func test_creates_file_at_specified_output_path() throws {
        // GIVEN
        let customPath: AbsolutePath = .temporary
        let fileManagerMock = CreateFileServiceMock()
        let printerMock = PrinterMock()
        let swiftLintData = createSwiftLintData()

        let formater = ReportFormaterJson(
            printer: printerMock,
            outputURL: customPath,
            fileManager: fileManagerMock
        )

        // WHEN
        try formater.report(from: swiftLintData, verbose: false)

        // THEN
        let receivedPath = fileManagerMock.createFileAtPathContentsAttributesReceivedArguments?.path
        XCTAssertTrue(receivedPath?.contains(customPath.pathString) ?? false)
    }

    func test_uses_provided_file_manager() throws {
        // GIVEN
        let fileManagerMock = CreateFileServiceMock()
        let printerMock = PrinterMock()
        let swiftLintData = createSwiftLintData()

        let formater = ReportFormaterJson(
            printer: printerMock,
            fileManager: fileManagerMock
        )

        // WHEN
        try formater.report(from: swiftLintData, verbose: false)

        // THEN
        XCTAssertTrue(fileManagerMock.createFileAtPathContentsAttributesCalled)
        XCTAssertEqual(fileManagerMock.createFileAtPathContentsAttributesCallsCount, 1)
    }

    func test_throws_on_invalid_input_json() throws {
        // GIVEN
        let fileManagerMock = CreateFileServiceMock()
        let printerMock = PrinterMock()
        let invalidData = "invalid json".data(using: .utf8)!

        let formater = ReportFormaterJson(
            printer: printerMock,
            fileManager: fileManagerMock
        )

        // WHEN & THEN
        XCTAssertThrowsError(try formater.report(from: invalidData, verbose: false))
    }

    func test_encodes_json_correctly() throws {
        // GIVEN
        let fileManagerMock = CreateFileServiceMock()
        let printerMock = PrinterMock()
        let swiftLintData = createSwiftLintData()

        let formater = ReportFormaterJson(
            printer: printerMock,
            fileManager: fileManagerMock
        )

        // WHEN
        try formater.report(from: swiftLintData, verbose: false)

        // THEN
        guard let contents = fileManagerMock.createFileAtPathContentsAttributesReceivedArguments?.data else {
            XCTFail("No contents created")
            return
        }

        // Verify it can be decoded back
        let decoded = try JSONDecoder().decode([SwiftLintFile].self, from: contents)
        XCTAssertGreaterThan(decoded.count, 0)
    }

    func test_file_creation_success_no_error_message() throws {
        // GIVEN
        let fileManagerMock = CreateFileServiceMock()
        fileManagerMock.createFileAtPathContentsAttributesReturnValue = true
        let printerMock = PrinterMock()
        let swiftLintData = createSwiftLintData()

        let formater = ReportFormaterJson(
            printer: printerMock,
            fileManager: fileManagerMock
        )

        // WHEN
        try formater.report(from: swiftLintData, verbose: false)

        // THEN
        // No error message should be printed
        XCTAssertTrue(fileManagerMock.createFileAtPathContentsAttributesCalled)
    }

    func test_file_creation_failure_handles_gracefully() throws {
        // GIVEN
        let fileManagerMock = CreateFileServiceMock()
        fileManagerMock.createFileAtPathContentsAttributesReturnValue = false
        let printerMock = PrinterMock()
        let swiftLintData = createSwiftLintData()

        let formater = ReportFormaterJson(
            printer: printerMock,
            fileManager: fileManagerMock
        )

        // WHEN
        // Should not throw even if file creation fails
        try formater.report(from: swiftLintData, verbose: false)

        // THEN
        XCTAssertTrue(fileManagerMock.createFileAtPathContentsAttributesCalled)
    }

    func test_handles_empty_violations_array() throws {
        // GIVEN
        let fileManagerMock = CreateFileServiceMock()
        let printerMock = PrinterMock()
        let emptyData = "[]".data(using: .utf8)!

        let formater = ReportFormaterJson(
            printer: printerMock,
            fileManager: fileManagerMock
        )

        // WHEN
        try formater.report(from: emptyData, verbose: false)

        // THEN
        XCTAssertTrue(fileManagerMock.createFileAtPathContentsAttributesCalled)

        guard let contents = fileManagerMock.createFileAtPathContentsAttributesReceivedArguments?.data else {
            XCTFail("No contents created")
            return
        }

        let decoded = try JSONDecoder().decode([SwiftLintFile].self, from: contents)
        XCTAssertTrue(decoded.isEmpty)
    }

    func test_preserves_swiftlint_file_structure() throws {
        // GIVEN
        let fileManagerMock = CreateFileServiceMock()
        let printerMock = PrinterMock()
        let swiftLintData = createDetailedSwiftLintData()

        let formater = ReportFormaterJson(
            printer: printerMock,
            fileManager: fileManagerMock
        )

        // WHEN
        try formater.report(from: swiftLintData, verbose: false)

        // THEN
        guard let contents = fileManagerMock.createFileAtPathContentsAttributesReceivedArguments?.data else {
            XCTFail("No contents created")
            return
        }

        let decoded = try JSONDecoder().decode([SwiftLintFile].self, from: contents)
        XCTAssertEqual(decoded.count, 2)
        XCTAssertEqual(decoded[0].character, 8)
        XCTAssertEqual(decoded[0].file, "/path/to/file.swift")
        XCTAssertEqual(decoded[0].line, 15)
        XCTAssertEqual(decoded[0].severity, "warning")
    }

    func test_printer_prints_file_path_on_success() throws {
        // GIVEN
        let outputFileURL: AbsolutePath = .temporary
        let fileManagerMock = CreateFileServiceMock()
        fileManagerMock.createFileAtPathContentsAttributesReturnValue = true
        let printerMock = PrinterMock()
        let swiftLintData = createSwiftLintData()

        let formater = ReportFormaterJson(
            printer: printerMock,
            outputURL: outputFileURL,
            fileManager: fileManagerMock
        )

        // WHEN
        try formater.report(from: swiftLintData, verbose: false)

        // THEN
        XCTAssertTrue(printerMock.printCalled)
        let expectedPath = outputFileURL.appending(component: "documentation-linter.json").pathString
        XCTAssertEqual(printerMock.printReceivedInvocations.first, expectedPath)
    }

    func test_printer_prints_error_message_on_failure() throws {
        // GIVEN
        let fileManagerMock = CreateFileServiceMock()
        fileManagerMock.createFileAtPathContentsAttributesReturnValue = false
        let printerMock = PrinterMock()
        let swiftLintData = createSwiftLintData()

        let formater = ReportFormaterJson(
            printer: printerMock,
            fileManager: fileManagerMock
        )

        // WHEN
        try formater.report(from: swiftLintData, verbose: true)

        // THEN
        XCTAssertTrue(printerMock.printCalled)
        XCTAssertEqual(printerMock.printCallsCount, 2)
        XCTAssertEqual(printerMock.printReceivedInvocations.last, "❌ Json report file not created")
    }

    func test_printer_prints_both_path_and_error_on_failure() throws {
        // GIVEN
        let outputFileURL: AbsolutePath = .temporary
        let fileManagerMock = CreateFileServiceMock()
        fileManagerMock.createFileAtPathContentsAttributesReturnValue = false
        let printerMock = PrinterMock()
        let swiftLintData = createSwiftLintData()

        let formater = ReportFormaterJson(
            printer: printerMock,
            outputURL: outputFileURL,
            fileManager: fileManagerMock
        )

        // WHEN
        try formater.report(from: swiftLintData, verbose: true)

        // THEN
        XCTAssertEqual(printerMock.printCallsCount, 2)
        let expectedPath = outputFileURL.appending(component: "documentation-linter.json").pathString
        XCTAssertEqual(printerMock.printReceivedInvocations[0], expectedPath)
        XCTAssertEqual(printerMock.printReceivedInvocations[1], "❌ Json report file not created")
    }

    // MARK: - Helper Methods

    private func createSwiftLintData() -> Data {
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

    private func createDetailedSwiftLintData() -> Data {
        let json = """
        [
            {
                "character": 8,
                "file": "/path/to/file.swift",
                "line": 15,
                "reason": "Missing documentation for function",
                "rule_id": "missing_docs",
                "severity": "warning",
                "type": "Documentation"
            },
            {
                "character": null,
                "file": null,
                "line": null,
                "reason": "Missing documentation for class",
                "rule_id": "missing_docs",
                "severity": "error",
                "type": "Documentation"
            }
        ]
        """
        return json.data(using: .utf8)!
    }
}
