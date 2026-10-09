import Foundation
import Path
import SwiftFormat

/// The formatter executor
public enum Formatter {
    /// Folder names that are always excluded from formatting.
    /// `.build` is SPM's output directory; `DerivedData` is Xcode's.
    static let defaultExcludes: [String] = [".build", "DerivedData"]

    /// Run format executor
    /// - Parameters:
    ///   - paths: The folders or files to be formatted
    ///   - swiftVersion: The swift version
    ///   - exclude: Additional folder names or paths to skip. Combined with the built-in defaults
    ///              (`.build`, `DerivedData`). Values are passed through to SwiftFormat's native
    ///              `--exclude` argument.
    public static func format(
        _ paths: [AbsolutePath],
        swiftVersion: String,
        exclude: [String] = []
    ) throws {
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

        let args = makeArguments(swiftVersion: swiftVersion, exclude: exclude)

        for path in paths {
            _ = SwiftFormat.CLI.run(
                in: path.pathString,
                with: args
            )
        }
    }

    static func makeArguments(swiftVersion: String, exclude: [String]) -> String {
        var combined: [String] = []
        for value in defaultExcludes + exclude where !combined.contains(value) {
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
