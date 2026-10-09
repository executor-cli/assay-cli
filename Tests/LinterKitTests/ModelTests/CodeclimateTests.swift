//
//  CodeclimateTests.swift
//  executor
//
//  Created by unit tests
//
import Foundation
import XCTest
@testable import LinterKit

final class CodeclimateTests: XCTestCase {
    // MARK: - Tests

    func test_codeclimate_decodes_complete_structure() throws {
        // GIVEN
        let json = """
        {
            "type": "issue",
            "check_name": "missing_docs",
            "description": "Missing documentation for public function",
            "engine_name": "SwiftLint",
            "fingerprint": "abc123def456",
            "severity": "minor",
            "location": {
                "path": "/Users/test/project/Sources/MyClass.swift",
                "lines": {
                    "begin": 15,
                    "end": 15
                }
            }
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))

        // WHEN
        let decoded = try JSONDecoder().decode(Codeclimate.self, from: data)

        // THEN
        XCTAssertEqual(decoded.type, "issue")
        XCTAssertEqual(decoded.check_name, "missing_docs")
        XCTAssertEqual(decoded.description, "Missing documentation for public function")
        XCTAssertEqual(decoded.engine_name, "SwiftLint")
        XCTAssertEqual(decoded.fingerprint, "abc123def456")
        XCTAssertEqual(decoded.severity, "minor")
        XCTAssertEqual(decoded.location.path, "/Users/test/project/Sources/MyClass.swift")
        XCTAssertEqual(decoded.location.lines.begin, 15)
        XCTAssertEqual(decoded.location.lines.end, 15)
    }

    func test_codeclimate_decodes_with_null_path() throws {
        // GIVEN
        let json = """
        {
            "type": "issue",
            "check_name": "missing_docs",
            "description": "Missing documentation",
            "engine_name": "SwiftLint",
            "fingerprint": "xyz789",
            "severity": "major",
            "location": {
                "path": null,
                "lines": {
                    "begin": 1,
                    "end": 1
                }
            }
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))

        // WHEN
        let decoded = try JSONDecoder().decode(Codeclimate.self, from: data)

        // THEN
        XCTAssertNil(decoded.location.path)
        XCTAssertEqual(decoded.location.lines.begin, 1)
        XCTAssertEqual(decoded.location.lines.end, 1)
    }

    func test_codeclimate_encodes_correctly() throws {
        // GIVEN
        let codeclimate = Codeclimate(
            check_name: "test_check",
            description: "Test description",
            engine_name: "TestEngine",
            fingerprint: "test123",
            severity: "minor",
            type: "issue",
            location: Codeclimate.Location(
                lines: Codeclimate.Location.Line(begin: 10, end: 20),
                path: "/test/path.swift"
            )
        )

        // WHEN
        let encoded = try JSONEncoder().encode(codeclimate)
        let decoded = try JSONDecoder().decode(Codeclimate.self, from: encoded)

        // THEN
        XCTAssertEqual(decoded.check_name, codeclimate.check_name)
        XCTAssertEqual(decoded.description, codeclimate.description)
        XCTAssertEqual(decoded.engine_name, codeclimate.engine_name)
        XCTAssertEqual(decoded.fingerprint, codeclimate.fingerprint)
        XCTAssertEqual(decoded.severity, codeclimate.severity)
        XCTAssertEqual(decoded.type, codeclimate.type)
        XCTAssertEqual(decoded.location.path, codeclimate.location.path)
        XCTAssertEqual(decoded.location.lines.begin, codeclimate.location.lines.begin)
        XCTAssertEqual(decoded.location.lines.end, codeclimate.location.lines.end)
    }

    func test_codeclimate_decodes_array_from_json() throws {
        // GIVEN
        let json = """
        [
            {
                "type": "issue",
                "check_name": "missing_docs",
                "description": "Missing docs 1",
                "engine_name": "SwiftLint",
                "fingerprint": "abc123",
                "severity": "minor",
                "location": {
                    "path": "/path/to/file1.swift",
                    "lines": {
                        "begin": 10,
                        "end": 10
                    }
                }
            },
            {
                "type": "issue",
                "check_name": "missing_docs",
                "description": "Missing docs 2",
                "engine_name": "SwiftLint",
                "fingerprint": "def456",
                "severity": "major",
                "location": {
                    "path": null,
                    "lines": {
                        "begin": 20,
                        "end": 20
                    }
                }
            }
        ]
        """
        let data = try XCTUnwrap(json.data(using: .utf8))

        // WHEN
        let decoded = try JSONDecoder().decode([Codeclimate].self, from: data)

        // THEN
        XCTAssertEqual(decoded.count, 2)
        XCTAssertEqual(decoded[0].fingerprint, "abc123")
        XCTAssertEqual(decoded[0].location.path, "/path/to/file1.swift")
        XCTAssertNil(decoded[1].location.path)
    }

    func test_codeclimate_location_structure() throws {
        // GIVEN
        let json = """
        {
            "path": "/test/path.swift",
            "lines": {
                "begin": 5,
                "end": 10
            }
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))

        // WHEN
        let decoded = try JSONDecoder().decode(Codeclimate.Location.self, from: data)

        // THEN
        XCTAssertEqual(decoded.path, "/test/path.swift")
        XCTAssertEqual(decoded.lines.begin, 5)
        XCTAssertEqual(decoded.lines.end, 10)
    }

    func test_codeclimate_location_line_structure() throws {
        // GIVEN
        let json = """
        {
            "begin": 15,
            "end": 25
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))

        // WHEN
        let decoded = try JSONDecoder().decode(Codeclimate.Location.Line.self, from: data)

        // THEN
        XCTAssertEqual(decoded.begin, 15)
        XCTAssertEqual(decoded.end, 25)
    }

    func test_codeclimate_location_line_with_null_values() throws {
        // GIVEN
        let json = """
        {
            "begin": null,
            "end": null
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))

        // WHEN
        let decoded = try JSONDecoder().decode(Codeclimate.Location.Line.self, from: data)

        // THEN
        XCTAssertNil(decoded.begin)
        XCTAssertNil(decoded.end)
    }
}
