import XCTest
@testable import LinterKit

final class LinterTypeTests: XCTestCase {
    // MARK: - Tests

    func test_json_type_reporter_returns_json() {
        // GIVEN
        let type = LinterType.json

        // WHEN
        let reporter = type.reporter

        // THEN
        XCTAssertEqual(reporter, "json")
    }

    func test_code_quality_type_reporter_returns_codeclimate() {
        // GIVEN
        let type = LinterType.codeQuality

        // WHEN
        let reporter = type.reporter

        // THEN
        XCTAssertEqual(reporter, "codeclimate")
    }

    func test_console_type_reporter_returns_json() {
        // GIVEN
        let type = LinterType.console

        // WHEN
        let reporter = type.reporter

        // THEN
        XCTAssertEqual(reporter, "json")
    }

    func test_json_type_raw_value() {
        // GIVEN & WHEN
        let type = LinterType.json

        // THEN
        XCTAssertEqual(type.rawValue, "json")
    }

    func test_code_quality_type_raw_value() {
        // GIVEN & WHEN
        let type = LinterType.codeQuality

        // THEN
        XCTAssertEqual(type.rawValue, "code-quality")
    }

    func test_console_type_raw_value() {
        // GIVEN & WHEN
        let type = LinterType.console

        // THEN
        XCTAssertEqual(type.rawValue, "console")
    }

    func test_init_from_raw_value_json() {
        // GIVEN
        let rawValue = "json"

        // WHEN
        let type = LinterType(rawValue: rawValue)

        // THEN
        XCTAssertEqual(type, .json)
    }

    func test_init_from_raw_value_code_quality() {
        // GIVEN
        let rawValue = "code-quality"

        // WHEN
        let type = LinterType(rawValue: rawValue)

        // THEN
        XCTAssertEqual(type, .codeQuality)
    }

    func test_init_from_raw_value_console() {
        // GIVEN
        let rawValue = "console"

        // WHEN
        let type = LinterType(rawValue: rawValue)

        // THEN
        XCTAssertEqual(type, .console)
    }

    func test_init_from_invalid_raw_value_returns_nil() {
        // GIVEN
        let rawValue = "invalid-type"

        // WHEN
        let type = LinterType(rawValue: rawValue)

        // THEN
        XCTAssertNil(type)
    }
}
