//
//  ReportFormaterFactoryTests.swift
//  executor
//
//  Created by unit tests
//
import XCTest
@testable import LinterKit

final class ReportFormaterFactoryTests: XCTestCase {
    // MARK: - Tests

    func test_factory_creates_console_formatter_for_console_type() {
        // GIVEN
        let type = LinterType.console
        let printerMock = PrinterMock()

        // WHEN
        let formatter = ReportFormaterFactory.build(from: type, printer: printerMock)

        // THEN
        XCTAssertTrue(formatter is ReportFormaterConsole)
    }

    func test_factory_creates_json_formatter_for_json_type() {
        // GIVEN
        let type = LinterType.json
        let printerMock = PrinterMock()

        // WHEN
        let formatter = ReportFormaterFactory.build(from: type, printer: printerMock)

        // THEN
        XCTAssertTrue(formatter is ReportFormaterJson)
    }

    func test_factory_creates_code_quality_formatter_for_codeQuality_type() {
        // GIVEN
        let type = LinterType.codeQuality
        let printerMock = PrinterMock()

        // WHEN
        let formatter = ReportFormaterFactory.build(from: type, printer: printerMock)

        // THEN
        XCTAssertTrue(formatter is ReportFormaterCodeQuality)
    }

    func test_factory_creates_instances_for_all_types() {
        // GIVEN
        let types: [LinterType] = [.console, .json, .codeQuality]
        let printerMock = PrinterMock()

        // WHEN & THEN
        for type in types {
            let formatter = ReportFormaterFactory.build(from: type, printer: printerMock)
            // Verify formatter was created for each type
            XCTAssertNotNil(formatter)
        }
    }
}
