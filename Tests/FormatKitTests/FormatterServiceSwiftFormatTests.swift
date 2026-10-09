import AppCore
import Foundation
import Path
import Testing
@testable import FormatKit

@Suite("FormatterServiceSwiftFormat")
struct FormatterServiceSwiftFormatTests {
    @Test("forwards the given paths to the formatter provider")
    func forwardsPaths() throws {
        let provider = FormatterProviderMock()
        let service = FormatterServiceSwiftFormat(formatterProvider: provider)
        let paths = try [
            AbsolutePath(validating: "/tmp/Sample.swift"),
            AbsolutePath(validating: "/tmp/Other.swift")
        ]

        try service.format(paths, configuration: AppConfiguration(), exclude: [])

        #expect(provider.formatCallsCount == 1)
        #expect(provider.formatReceivedArguments?.paths == paths)
    }

    @Test("includes the configured swift version in the formatter arguments")
    func includesSwiftVersion() throws {
        let provider = FormatterProviderMock()
        let service = FormatterServiceSwiftFormat(formatterProvider: provider)
        let configuration = AppConfiguration(
            format: FormatConfiguration(swiftVersion: "5.9", defaultExcludes: [])
        )

        try service.format([], configuration: configuration, exclude: [])

        let args = try #require(provider.formatReceivedArguments?.args)
        #expect(args.contains("--swiftversion 5.9"))
    }

    @Test("merges default excludes with the provided excludes without duplicates")
    func mergesExcludesWithoutDuplicates() throws {
        let provider = FormatterProviderMock()
        let service = FormatterServiceSwiftFormat(formatterProvider: provider)
        let configuration = AppConfiguration(
            format: FormatConfiguration(
                swiftVersion: "6.1",
                defaultExcludes: [".build", "DerivedData"]
            )
        )

        try service.format([], configuration: configuration, exclude: ["DerivedData", "Generated"])

        let args = try #require(provider.formatReceivedArguments?.args)
        #expect(args.contains("--exclude .build,DerivedData,Generated"))
    }

    @Test("builds arguments starting with the current directory")
    func startsWithCurrentDirectory() throws {
        let provider = FormatterProviderMock()
        let service = FormatterServiceSwiftFormat(formatterProvider: provider)

        try service.format([], configuration: AppConfiguration(), exclude: [])

        let args = try #require(provider.formatReceivedArguments?.args)
        #expect(args.hasPrefix(". --swiftversion"))
    }

    @Test("includes the fixed SwiftFormat rule flags")
    func includesFixedRuleFlags() throws {
        let provider = FormatterProviderMock()
        let service = FormatterServiceSwiftFormat(formatterProvider: provider)

        try service.format([], configuration: AppConfiguration(), exclude: [])

        let args = try #require(provider.formatReceivedArguments?.args)
        #expect(args.contains("--wraparguments before-first"))
        #expect(args.contains("--trailingCommas never"))
        #expect(args.contains("--maxwidth 110"))
        #expect(args.contains("--header strip"))
    }
}
