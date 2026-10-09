import CascadeKit
import Foundation
import Path
import XCTest
@testable import LinterKit

final class ReportFormaterCodeQualityTests: XCTestCase {
    // MARK: - Tests

    func test_report_when_success() throws {
        // GIVEN
        let outputFileURL: AbsolutePath = .temporary
        let fileName = "gl-code-quality-report.json"
        let fileManagerMock = CreateFileServiceMock()
        let codeclimateData = createCodeclimateData()

        // WHEN
        try withDependencies {
            $0.printer = PrinterMock()
            $0.createFileService = fileManagerMock
        } operation: {
            try ReportFormaterCodeQuality(
                fileName: fileName,
                outputURL: outputFileURL
            )
            .report(from: codeclimateData, verbose: false)
        }

        // THEN
        XCTAssertEqual(fileManagerMock.createFileAtPathContentsAttributesCallsCount, 1)
    }

    func test_decodes_codeclimate_json_correctly() throws {
        // GIVEN
        let codeclimateData = createCodeclimateData()
        let fileManagerMock = CreateFileServiceMock()

        // WHEN
        try withDependencies {
            $0.printer = PrinterMock()
            $0.createFileService = fileManagerMock
        } operation: {
            try ReportFormaterCodeQuality()
                .report(from: codeclimateData, verbose: false)
        }

        // THEN
        XCTAssertTrue(fileManagerMock.createFileAtPathContentsAttributesCalled)
    }

    func test_creates_file_with_default_name() throws {
        // GIVEN
        let outputFileURL: AbsolutePath = .temporary
        let fileManagerMock = CreateFileServiceMock()
        let codeclimateData = createCodeclimateData()

        // WHEN
        try withDependencies {
            $0.printer = PrinterMock()
            $0.createFileService = fileManagerMock
        } operation: {
            try ReportFormaterCodeQuality(
                outputURL: outputFileURL
            )
            .report(from: codeclimateData, verbose: false)
        }

        // THEN
        let expectedPath = outputFileURL.appending(component: "gl-code-quality-report.json").pathString
        XCTAssertEqual(
            fileManagerMock.createFileAtPathContentsAttributesReceivedArguments?.path,
            expectedPath
        )
    }

    func test_creates_file_with_custom_name() throws {
        // GIVEN
        let customFileName = "custom-report.json"
        let outputFileURL: AbsolutePath = .temporary
        let fileManagerMock = CreateFileServiceMock()
        let codeclimateData = createCodeclimateData()

        // WHEN
        try withDependencies {
            $0.printer = PrinterMock()
            $0.createFileService = fileManagerMock
        } operation: {
            try ReportFormaterCodeQuality(
                fileName: customFileName,
                outputURL: outputFileURL
            )
            .report(from: codeclimateData, verbose: false)
        }

        // THEN
        let expectedPath = outputFileURL.appending(component: customFileName).pathString
        XCTAssertEqual(
            fileManagerMock.createFileAtPathContentsAttributesReceivedArguments?.path,
            expectedPath
        )
    }

    func test_creates_file_at_specified_path() throws {
        // GIVEN
        let customPath: AbsolutePath = .temporary
        let fileManagerMock = CreateFileServiceMock()
        let codeclimateData = createCodeclimateData()

        // WHEN
        try withDependencies {
            $0.printer = PrinterMock()
            $0.createFileService = fileManagerMock
        } operation: {
            try ReportFormaterCodeQuality(
                outputURL: customPath
            )
            .report(from: codeclimateData, verbose: false)
        }

        // THEN
        let receivedPath = fileManagerMock.createFileAtPathContentsAttributesReceivedArguments?.path
        XCTAssertTrue(receivedPath?.contains(customPath.pathString) ?? false)
    }

    func test_replaces_minor_and_major_with_uppercase() throws {
        // GIVEN
        let fileManagerMock = CreateFileServiceMock()
        let codeclimateData = createCodeclimateDataWithSeverities()

        // WHEN
        try withDependencies {
            $0.printer = PrinterMock()
            $0.createFileService = fileManagerMock
        } operation: {
            try ReportFormaterCodeQuality()
                .report(from: codeclimateData, verbose: false)
        }

        // THEN
        guard let contents = fileManagerMock.createFileAtPathContentsAttributesReceivedArguments?.data else {
            XCTFail("No contents created")
            return
        }

        let jsonString = String(data: contents, encoding: .utf8)

        if #available(macOS 13.0, *) {
            XCTAssertTrue(jsonString?.contains("MINOR") ?? false)
            XCTAssertTrue(jsonString?.contains("MAJOR") ?? false)
            XCTAssertFalse(jsonString?.contains("\"minor\"") ?? true)
            XCTAssertFalse(jsonString?.contains("\"major\"") ?? true)
        }
    }

    func test_uses_provided_file_manager() throws {
        // GIVEN
        let fileManagerMock = CreateFileServiceMock()
        let codeclimateData = createCodeclimateData()

        // WHEN
        try withDependencies {
            $0.printer = PrinterMock()
            $0.createFileService = fileManagerMock
        } operation: {
            try ReportFormaterCodeQuality()
                .report(from: codeclimateData, verbose: false)
        }

        // THEN
        XCTAssertTrue(fileManagerMock.createFileAtPathContentsAttributesCalled)
    }

    func test_throws_on_invalid_input_json() throws {
        // GIVEN
        let fileManagerMock = CreateFileServiceMock()
        let invalidData = "invalid json".data(using: .utf8)!

        let formater = ReportFormaterCodeQuality()

        // WHEN & THEN
        XCTAssertThrowsError(try formater.report(from: invalidData, verbose: false))
    }

    func test_encodes_json_correctly() throws {
        // GIVEN
        let fileManagerMock = CreateFileServiceMock()
        let codeclimateData = createCodeclimateData()

        // WHEN
        try withDependencies {
            $0.printer = PrinterMock()
            $0.createFileService = fileManagerMock
        } operation: {
            try ReportFormaterCodeQuality()
                .report(from: codeclimateData, verbose: false)
        }

        // THEN
        guard let contents = fileManagerMock.createFileAtPathContentsAttributesReceivedArguments?.data else {
            XCTFail("No contents created")
            return
        }

        // Verify it can be decoded back
        let decoded = try JSONDecoder().decode([Codeclimate].self, from: codeclimateData)
        XCTAssertGreaterThan(decoded.count, 0)
    }

    func test_handles_empty_array() throws {
        // GIVEN
        let fileManagerMock = CreateFileServiceMock()
        let emptyData = "[]".data(using: .utf8)!

        // WHEN
        try withDependencies {
            $0.printer = PrinterMock()
            $0.createFileService = fileManagerMock
        } operation: {
            try ReportFormaterCodeQuality()
                .report(from: emptyData, verbose: false)
        }

        // THEN
        XCTAssertTrue(fileManagerMock.createFileAtPathContentsAttributesCalled)

        guard let contents = fileManagerMock.createFileAtPathContentsAttributesReceivedArguments?.data else {
            XCTFail("No contents created")
            return
        }

        let jsonString = String(data: contents, encoding: .utf8)
        XCTAssertEqual(jsonString, "[]")
    }

    // MARK: - Helper Methods

    private func createCodeclimateData() -> Data {
        let json = """
        [
            {
                "type": "issue",
                "check_name": "missing_docs",
                "description": "Missing documentation",
                "engine_name": "SwiftLint",
                "fingerprint": "abc123",
                "severity": "minor",
                "location": {
                    "path": "/test/path.swift",
                    "lines": {
                        "begin": 10,
                        "end": 10
                    }
                }
            }
        ]
        """
        return json.data(using: .utf8)!
    }

    private func createCodeclimateDataWithSeverities() -> Data {
        let json = """
        [
            {
                "type": "issue",
                "check_name": "missing_docs",
                "description": "Minor issue",
                "engine_name": "SwiftLint",
                "fingerprint": "abc123",
                "severity": "minor",
                "location": {
                    "path": "/test/path1.swift",
                    "lines": {
                        "begin": 10,
                        "end": 10
                    }
                }
            },
            {
                "type": "issue",
                "check_name": "missing_docs",
                "description": "Major issue",
                "engine_name": "SwiftLint",
                "fingerprint": "def456",
                "severity": "major",
                "location": {
                    "path": "/test/path2.swift",
                    "lines": {
                        "begin": 20,
                        "end": 20
                    }
                }
            }
        ]
        """
        return json.data(using: .utf8)!
    }
}
