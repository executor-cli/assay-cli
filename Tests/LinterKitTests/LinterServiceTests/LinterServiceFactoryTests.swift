import Foundation
import XCTest
@testable import LinterKit

final class LinterServiceFactoryTests: XCTestCase {
    // MARK: - Tests

    func test_factory_creates_swiftLint_service() {
        // WHEN
        let service = LinterServiceFactory().swiftLint(fileResourceName: "test-config")

        // THEN
        XCTAssertTrue(service is LinterServiceSwiftLint)
    }

    func test_factory_creates_swiftLint_service_with_custom_encoder() {
        // GIVEN
        let customEncoder = JSONEncoder()
        customEncoder.outputFormatting = .prettyPrinted

        // WHEN
        let service = LinterServiceFactory().swiftLint(
            fileResourceName: "test-config",
            jsonEncoder: customEncoder
        )

        // THEN
        XCTAssertTrue(service is LinterServiceSwiftLint)
    }

    func test_factory_creates_swiftLint_service_with_additional_configuration() {
        // GIVEN
        let additionalConfig = ["reporter": "json"]

        // WHEN
        let service = LinterServiceFactory().swiftLint(
            fileResourceName: "test-config",
            additionalConfiguration: additionalConfig
        )

        // THEN
        XCTAssertTrue(service is LinterServiceSwiftLint)
    }

    func test_factory_creates_swiftLint_service_with_only_rule() {
        // GIVEN
        let rules = ["missing_docs"]

        // WHEN
        let service = LinterServiceFactory().swiftLint(
            fileResourceName: "test-config",
            onlyRule: rules
        )

        // THEN
        XCTAssertTrue(service is LinterServiceSwiftLint)
    }

    func test_factory_creates_swiftLint_service_with_different_file_names() {
        // GIVEN
        let fileNames = [
            "swiftlint-missingdoc",
            "com.raywenderlich.swiftlint",
            "custom-config"
        ]

        // WHEN & THEN
        for fileName in fileNames {
            let service = LinterServiceFactory().swiftLint(fileResourceName: fileName)
            XCTAssertTrue(service is LinterServiceSwiftLint)
        }
    }

    func test_factory_returns_protocol_type() {
        // WHEN
        let service = LinterServiceFactory().swiftLint(fileResourceName: "test-config")

        // THEN
        XCTAssertTrue(service is any LinterService)
    }

    func test_factory_creates_swiftLint_service_with_custom_config_file_path() {
        // GIVEN
        let configPath = "/tmp/custom.swiftlint.yml"

        // WHEN
        let service = LinterServiceFactory().swiftLint(
            fileResourceName: "test-config",
            configFilePath: configPath
        )

        // THEN
        XCTAssertTrue(service is LinterServiceSwiftLint)
    }
}
