import Foundation
import XCTest
@testable import ExecutorCore
@testable import LinterKit

final class ReportFormaterConsoleTests: XCTestCase {
    // MARK: - Mock Printer

    private class MockPrinter: Printer, @unchecked Sendable {
        var printedMessages: [String] = []

        func print(_ string: String) {
            printedMessages.append(string)
        }
    }

    // MARK: - Tests

    func test_prints_success_message_when_empty_violations() throws {
        // GIVEN
        let emptyData = "[]".data(using: .utf8)!
        let mockPrinter = MockPrinter()
        let formater = ReportFormaterConsole(printer: mockPrinter)

        // WHEN
        try formater.report(from: emptyData, verbose: false)

        // THEN
        XCTAssertEqual(mockPrinter.printedMessages.count, 1)
        XCTAssertEqual(mockPrinter.printedMessages.first, "✅ no issues found")
    }

    func test_decodes_swiftlint_json_with_violations() throws {
        // GIVEN
        let swiftLintData = createSwiftLintData()
        let mockPrinter = MockPrinter()
        let formater = ReportFormaterConsole(printer: mockPrinter)

        // WHEN
        try formater.report(from: swiftLintData, verbose: false)

        // THEN
        XCTAssertGreaterThan(mockPrinter.printedMessages.count, 0)
        XCTAssertTrue(mockPrinter.printedMessages.contains("❌ some issues was found"))
    }

    func test_handles_multiple_violations() throws {
        // GIVEN
        let swiftLintData = createMultipleViolationsData()
        let mockPrinter = MockPrinter()
        let formater = ReportFormaterConsole(printer: mockPrinter)

        // WHEN
        try formater.report(from: swiftLintData, verbose: false)

        // THEN
        XCTAssertGreaterThan(mockPrinter.printedMessages.count, 0)
        XCTAssertTrue(mockPrinter.printedMessages.contains("❌ some issues was found"))
    }

    func test_handles_violations_with_optional_fields() throws {
        // GIVEN
        let json = """
        [
            {
                "character": null,
                "file": null,
                "line": null,
                "reason": "Missing documentation",
                "rule_id": "missing_docs",
                "severity": "warning",
                "type": "Documentation"
            }
        ]
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let mockPrinter = MockPrinter()
        let formater = ReportFormaterConsole(printer: mockPrinter)

        // WHEN
        try formater.report(from: data, verbose: false)

        // THEN
        XCTAssertGreaterThan(mockPrinter.printedMessages.count, 0)
        XCTAssertTrue(mockPrinter.printedMessages.contains("❌ some issues was found"))
    }

    func test_handles_complete_violation_structure() throws {
        // GIVEN
        let json = """
        [
            {
                "character": 10,
                "file": "/path/to/file.swift",
                "line": 42,
                "reason": "Missing documentation for public function",
                "rule_id": "missing_docs",
                "severity": "error",
                "type": "Documentation"
            }
        ]
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let mockPrinter = MockPrinter()
        let formater = ReportFormaterConsole(printer: mockPrinter)

        // WHEN
        try formater.report(from: data, verbose: false)

        // THEN
        XCTAssertGreaterThan(mockPrinter.printedMessages.count, 0)
        XCTAssertTrue(mockPrinter.printedMessages.contains("❌ some issues was found"))
    }

    func test_groups_violations_by_severity() throws {
        // GIVEN
        let json = """
        [
            {
                "character": 10,
                "file": "/path/to/file1.swift",
                "line": 15,
                "reason": "Warning violation",
                "rule_id": "missing_docs",
                "severity": "warning",
                "type": "Documentation"
            },
            {
                "character": 20,
                "file": "/path/to/file2.swift",
                "line": 25,
                "reason": "Error violation",
                "rule_id": "missing_docs",
                "severity": "error",
                "type": "Documentation"
            },
            {
                "character": 30,
                "file": "/path/to/file3.swift",
                "line": 35,
                "reason": "Another warning",
                "rule_id": "missing_docs",
                "severity": "warning",
                "type": "Documentation"
            }
        ]
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let mockPrinter = MockPrinter()
        let formater = ReportFormaterConsole(printer: mockPrinter)

        // WHEN
        try formater.report(from: data, verbose: false)

        // THEN
        XCTAssertGreaterThan(mockPrinter.printedMessages.count, 0)
        XCTAssertTrue(mockPrinter.printedMessages.contains("❌ some issues was found"))
    }

    func test_throws_on_invalid_json() throws {
        // GIVEN
        let invalidData = "invalid json".data(using: .utf8)!
        let mockPrinter = MockPrinter()
        let formater = ReportFormaterConsole(printer: mockPrinter)

        // WHEN & THEN
        XCTAssertThrowsError(try formater.report(from: invalidData, verbose: false))
    }

    func test_handles_malformed_json_structure() throws {
        // GIVEN
        let malformedJson = "{\"not\": \"an array\"}".data(using: .utf8)!
        let mockPrinter = MockPrinter()
        let formater = ReportFormaterConsole(printer: mockPrinter)

        // WHEN & THEN
        XCTAssertThrowsError(try formater.report(from: malformedJson, verbose: false))
    }

    func test_handles_mixed_severity_types() throws {
        // GIVEN
        let json = """
        [
            {
                "character": 1,
                "file": "/file1.swift",
                "line": 1,
                "reason": "Minor issue",
                "rule_id": "missing_docs",
                "severity": "minor",
                "type": "Documentation"
            },
            {
                "character": 2,
                "file": "/file2.swift",
                "line": 2,
                "reason": "Major issue",
                "rule_id": "missing_docs",
                "severity": "major",
                "type": "Documentation"
            },
            {
                "character": 3,
                "file": "/file3.swift",
                "line": 3,
                "reason": "Warning issue",
                "rule_id": "missing_docs",
                "severity": "warning",
                "type": "Documentation"
            },
            {
                "character": 4,
                "file": "/file4.swift",
                "line": 4,
                "reason": "Error issue",
                "rule_id": "missing_docs",
                "severity": "error",
                "type": "Documentation"
            }
        ]
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let mockPrinter = MockPrinter()
        let formater = ReportFormaterConsole(printer: mockPrinter)

        // WHEN
        try formater.report(from: data, verbose: false)

        // THEN
        XCTAssertGreaterThan(mockPrinter.printedMessages.count, 0)
        XCTAssertTrue(mockPrinter.printedMessages.contains("❌ some issues was found"))
    }

    func test_handles_violations_without_file_path() throws {
        // GIVEN
        let json = """
        [
            {
                "character": null,
                "file": null,
                "line": 10,
                "reason": "Missing documentation",
                "rule_id": "missing_docs",
                "severity": "warning",
                "type": "Documentation"
            }
        ]
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let mockPrinter = MockPrinter()
        let formater = ReportFormaterConsole(printer: mockPrinter)

        // WHEN
        try formater.report(from: data, verbose: false)

        // THEN
        XCTAssertGreaterThan(mockPrinter.printedMessages.count, 0)
        XCTAssertTrue(mockPrinter.printedMessages.contains("❌ some issues was found"))
    }

    func test_handles_violations_without_line_number() throws {
        // GIVEN
        let json = """
        [
            {
                "character": 5,
                "file": "/path/to/file.swift",
                "line": null,
                "reason": "Missing documentation",
                "rule_id": "missing_docs",
                "severity": "warning",
                "type": "Documentation"
            }
        ]
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let mockPrinter = MockPrinter()
        let formater = ReportFormaterConsole(printer: mockPrinter)

        // WHEN
        try formater.report(from: data, verbose: false)

        // THEN
        XCTAssertGreaterThan(mockPrinter.printedMessages.count, 0)
        XCTAssertTrue(mockPrinter.printedMessages.contains("❌ some issues was found"))
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

    private func createMultipleViolationsData() -> Data {
        let json = """
        [
            {
                "character": 8,
                "file": "/path/to/file1.swift",
                "line": 15,
                "reason": "Missing documentation for function",
                "rule_id": "missing_docs",
                "severity": "warning",
                "type": "Documentation"
            },
            {
                "character": 14,
                "file": "/path/to/file2.swift",
                "line": 42,
                "reason": "Missing documentation for class",
                "rule_id": "missing_docs",
                "severity": "error",
                "type": "Documentation"
            },
            {
                "character": 20,
                "file": "/path/to/file3.swift",
                "line": 100,
                "reason": "Missing documentation for property",
                "rule_id": "missing_docs",
                "severity": "warning",
                "type": "Documentation"
            }
        ]
        """
        return json.data(using: .utf8)!
    }
}
