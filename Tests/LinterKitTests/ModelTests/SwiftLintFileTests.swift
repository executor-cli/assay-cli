//
//  SwiftLintFileTests.swift
//  executor
//
//  Created by unit tests
//
import Foundation
import XCTest
@testable import LinterKit

final class SwiftLintFileTests: XCTestCase {
    // MARK: - Tests

    func test_swiftLintFile_decodes_complete_object() throws {
        // GIVEN
        let json = """
        {
            "character": 8,
            "file": "/Users/test/project/Sources/MyClass.swift",
            "line": 15,
            "reason": "Missing documentation for public function",
            "rule_id": "missing_docs",
            "severity": "warning",
            "type": "Documentation"
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))

        // WHEN
        let decoded = try JSONDecoder().decode(SwiftLintFile.self, from: data)

        // THEN
        XCTAssertEqual(decoded.character, 8)
        XCTAssertEqual(decoded.file, "/Users/test/project/Sources/MyClass.swift")
        XCTAssertEqual(decoded.line, 15)
        XCTAssertEqual(decoded.reason, "Missing documentation for public function")
        XCTAssertEqual(decoded.rule_id, "missing_docs")
        XCTAssertEqual(decoded.severity, "warning")
        XCTAssertEqual(decoded.type, "Documentation")
    }

    func test_swiftLintFile_decodes_with_optional_nils() throws {
        // GIVEN
        let json = """
        {
            "character": null,
            "file": null,
            "line": null,
            "reason": "Missing documentation",
            "rule_id": "missing_docs",
            "severity": "error",
            "type": "Documentation"
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))

        // WHEN
        let decoded = try JSONDecoder().decode(SwiftLintFile.self, from: data)

        // THEN
        XCTAssertNil(decoded.character)
        XCTAssertNil(decoded.file)
        XCTAssertNil(decoded.line)
        XCTAssertEqual(decoded.reason, "Missing documentation")
        XCTAssertEqual(decoded.rule_id, "missing_docs")
        XCTAssertEqual(decoded.severity, "error")
        XCTAssertEqual(decoded.type, "Documentation")
    }

    func test_swiftLintFile_encodes_correctly() throws {
        // GIVEN
        let swiftLintFile = SwiftLintFile(
            character: 10,
            file: "/path/to/file.swift",
            line: 20,
            reason: "Test reason",
            rule_id: "test_rule",
            severity: "warning",
            type: "TestType"
        )

        // WHEN
        let encoded = try JSONEncoder().encode(swiftLintFile)
        let decoded = try JSONDecoder().decode(SwiftLintFile.self, from: encoded)

        // THEN
        XCTAssertEqual(decoded.character, swiftLintFile.character)
        XCTAssertEqual(decoded.file, swiftLintFile.file)
        XCTAssertEqual(decoded.line, swiftLintFile.line)
        XCTAssertEqual(decoded.reason, swiftLintFile.reason)
        XCTAssertEqual(decoded.rule_id, swiftLintFile.rule_id)
        XCTAssertEqual(decoded.severity, swiftLintFile.severity)
        XCTAssertEqual(decoded.type, swiftLintFile.type)
    }

    func test_swiftLintFile_decodes_array_from_json() throws {
        // GIVEN
        let json = """
        [
            {
                "character": 8,
                "file": "/path/to/file1.swift",
                "line": 10,
                "reason": "Missing docs 1",
                "rule_id": "missing_docs",
                "severity": "warning",
                "type": "Documentation"
            },
            {
                "character": null,
                "file": null,
                "line": null,
                "reason": "Missing docs 2",
                "rule_id": "missing_docs",
                "severity": "error",
                "type": "Documentation"
            }
        ]
        """
        let data = try XCTUnwrap(json.data(using: .utf8))

        // WHEN
        let decoded = try JSONDecoder().decode([SwiftLintFile].self, from: data)

        // THEN
        XCTAssertEqual(decoded.count, 2)
        XCTAssertEqual(decoded[0].character, 8)
        XCTAssertEqual(decoded[0].file, "/path/to/file1.swift")
        XCTAssertNil(decoded[1].character)
        XCTAssertNil(decoded[1].file)
    }

    func test_swiftLintFile_decodes_empty_array() throws {
        // GIVEN
        let json = "[]"
        let data = try XCTUnwrap(json.data(using: .utf8))

        // WHEN
        let decoded = try JSONDecoder().decode([SwiftLintFile].self, from: data)

        // THEN
        XCTAssertTrue(decoded.isEmpty)
    }
}
