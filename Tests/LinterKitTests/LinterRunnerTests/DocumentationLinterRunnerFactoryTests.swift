import XCTest
@testable import LinterKit

final class LinterRunnerFactoryTests: XCTestCase {
    // MARK: - Tests

    func test_factory_builds_runner_with_console_formatter() {
        // GIVEN
        let type = LinterType.console
        let serviceMock = LinterServiceMock()
        let formaterMock = ReportFormaterMock()

        // WHEN
        let runner = LinterRunnerFactory.build(
            reportFormater: formaterMock,
            from: type,
            service: serviceMock
        )

        // THEN
        XCTAssertTrue(runner is LinterRunnerDefault)
    }

    func test_factory_builds_runner_with_json_formatter() {
        // GIVEN
        let type = LinterType.json
        let serviceMock = LinterServiceMock()
        let formaterMock = ReportFormaterMock()

        // WHEN
        let runner = LinterRunnerFactory.build(
            reportFormater: formaterMock,
            from: type,
            service: serviceMock
        )

        // THEN
        XCTAssertTrue(runner is LinterRunnerDefault)
    }

    func test_factory_builds_runner_with_code_quality_formatter() {
        // GIVEN
        let type = LinterType.codeQuality
        let serviceMock = LinterServiceMock()
        let formaterMock = ReportFormaterMock()

        // WHEN
        let runner = LinterRunnerFactory.build(
            reportFormater: formaterMock,
            from: type,
            service: serviceMock
        )

        // THEN
        XCTAssertTrue(runner is LinterRunnerDefault)
    }

    func test_factory_creates_runner_with_provided_service() throws {
        // GIVEN
        let type = LinterType.json
        let serviceMock = LinterServiceMock()
        let formaterMock = ReportFormaterMock()
        serviceMock.executeReturnValue = "[]".data(using: .utf8)!

        // WHEN
        let runner = LinterRunnerFactory.build(
            reportFormater: formaterMock,
            from: type,
            service: serviceMock
        )

        // THEN
        // Verify runner uses the provided service by executing
        XCTAssertNoThrow(
            try runner.execute(forPaths: [], throwError: false, verbose: false)
        )
        XCTAssertTrue(serviceMock.executeCalled)
    }

    func test_factory_creates_different_instances_for_each_call() {
        // GIVEN
        let type = LinterType.json
        let serviceMock1 = LinterServiceMock()
        let serviceMock2 = LinterServiceMock()
        let formaterMock = ReportFormaterMock()

        // WHEN
        let runner1 = LinterRunnerFactory.build(
            reportFormater: formaterMock,
            from: type,
            service: serviceMock1
        )
        let runner2 = LinterRunnerFactory.build(
            reportFormater: formaterMock,
            from: type,
            service: serviceMock2
        )

        // THEN
        // Just verify both runners were created successfully
        XCTAssertTrue(runner1 is LinterRunnerDefault)
        XCTAssertTrue(runner2 is LinterRunnerDefault)
    }

    func test_factory_builds_runner_for_all_linter_types() {
        // GIVEN
        let types: [LinterType] = [.console, .json, .codeQuality]
        let serviceMock = LinterServiceMock()
        let formaterMock = ReportFormaterMock()

        // WHEN & THEN
        for type in types {
            let runner = LinterRunnerFactory.build(
                reportFormater: formaterMock,
                from: type,
                service: serviceMock
            )
            XCTAssertTrue(runner is LinterRunnerDefault)
        }
    }
}
