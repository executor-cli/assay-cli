import AppCore
import Foundation
import Path
@preconcurrency import SwiftFormat

/// The formatter executor
public enum Formatter {
    public enum Factory {
        public static var `default`: any FormatterService {
            FormatterServiceSwiftFormat(formatterProvider: FormatterProviderSwiftFormat())
        }
    }
}

public protocol FormatterService: Sendable {
    func format(
        _ paths: [AbsolutePath],
        configuration: AppConfiguration,
        exclude: [String]
    ) throws
}

protocol FormatterProvider: Sendable {
    func format(_ paths: [AbsolutePath], args: String)
}

struct FormatterProviderSwiftFormat: FormatterProvider {
    func format(_ paths: [AbsolutePath], args: String) {
        SwiftFormat.CLI.print = { (output: String, type: SwiftFormat.CLI.OutputType) in
            guard let data = output
                .appending("\n")
                .data(using: .utf8) else { return }

            switch type {
            case .error:
                FileHandle.standardError.write(data)
            default:
                FileHandle.standardOutput.write(data)
            }
        }

        for path in paths {
            _ = SwiftFormat.CLI.run(
                in: path.pathString,
                with: args
            )
        }
    }
}

struct FormatterServiceSwiftFormat: FormatterService {
    private let formatterProvider: any FormatterProvider

    init(formatterProvider: any FormatterProvider) {
        self.formatterProvider = formatterProvider
    }

    func format(
        _ paths: [AbsolutePath],
        configuration: AppConfiguration,
        exclude: [String]
    ) throws {
        let excludeMerge = configuration.format.defaultExcludes.merging(exclude)

        let args = makeArguments(
            swiftVersion: configuration.format.swiftVersion,
            exclude: excludeMerge
        )

        formatterProvider.format(paths, args: args)
    }

    private func makeArguments(swiftVersion: String, exclude: [String]) -> String {
        var combined: [String] = []
        for value in exclude where !combined.contains(value) {
            combined.append(value)
        }
        let excludeArg = "--exclude " + combined.joined(separator: ",")

        return [
            ".",
            "--swiftversion \(swiftVersion)",
            "--ifdef outdent",
            "--wraparguments before-first",
            "--wrapparameters before-first",
            "--wrapcollections before-first",
            "--funcattributes prev-line",
            "--typeattributes prev-line",
            "--trailingCommas never",
            "--enable isEmpty",
            "--enable blankLinesBetweenScopes",
            "--enable blankLinesBetweenImports",
            "--enable blankLineAfterImports",
            "--enable blockComments",
            "--enable wrapEnumCases",
            "--enable wrapSingleLineComments",
            "--disable wrapMultilineStatementBraces",
            "--disable wrapMultilineConditionalAssignment",
            "--disable preferKeyPath",
            "--disable opaqueGenericParameters",
            "--disable preferForLoop",
            "--header strip",
            "--self init-only",
            "--decimalgrouping 3",
            "--stripunusedargs closure-only",
            "--extensionacl on-declarations",
            "--importgrouping testable-last",
            "--maxwidth 110",
            "--enable blankLinesBetweenChainedFunctions",
            "--enable environmentEntry",
            "--enable preferCountWhere",
            "--enable blankLinesAfterGuardStatements",
            "--enable emptyExtensions",
            "--enable privateStateVariables",
            "--enable trailingCommas",
            "--disable unusedPrivateDeclarations",
            "--doc-comments before-declarations",
            "--enable docCommentsBeforeModifiers",
            excludeArg
        ].joined(separator: " ")
    }
}
