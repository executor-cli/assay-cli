import Foundation
import LinterKit

public struct DeadCodeReporter {
    private struct Declaration: Decodable {
        let kind: String
        let name: String?
        let hints: [String]
        let ids: [String]
        let location: String
    }

    private struct Issue {
        let path: String
        let line: Int?
        let column: Int?
        let hint: String
        let reason: String
        let fingerprint: String
    }

    private let reporter: LinterType
    private let reportFormater: any ReportFormater

    public init(reporter: LinterType, reportFormater: any ReportFormater) {
        self.reporter = reporter
        self.reportFormater = reportFormater
    }

    public func report(from data: Data, verbose: Bool) throws {
        let issues = try JSONDecoder().decode([Declaration].self, from: data).map(issue(from:))

        try reportFormater.report(from: encode(issues), verbose: verbose)

        guard issues.isEmpty else { throw DeadCodeError.deadCodeFound(count: issues.count) }
    }

    private func issue(from declaration: Declaration) -> Issue {
        // Split on the last two ":" so a path containing ":" stays whole.
        let parts = declaration.location.split(separator: ":", omittingEmptySubsequences: false)
        let path = parts.count >= 3 ? parts.dropLast(2).joined(separator: ":") : declaration.location
        let line = parts.count >= 3 ? Int(parts[parts.count - 2]) : nil
        let column = parts.count >= 3 ? Int(parts[parts.count - 1]) : nil
        let hint = declaration.hints.first ?? "unused"
        let name = declaration.name ?? ""

        return Issue(
            path: path,
            line: line,
            column: column,
            hint: hint,
            reason: "\(hint) \(declaration.kind) '\(name)'",
            fingerprint: declaration.ids.isEmpty
                ? "\(path):\(line.map(String.init) ?? ""):\(name)"
                : declaration.ids.joined(separator: ",")
        )
    }

    private func encode(_ issues: [Issue]) throws -> Data {
        switch reporter {
        case .console, .json:
            try JSONEncoder().encode(issues.map {
                SwiftLintFile(
                    character: $0.column,
                    file: $0.path,
                    line: $0.line,
                    reason: $0.reason,
                    rule_id: $0.hint,
                    severity: "warning",
                    type: "Dead Code"
                )
            })
        case .codeQuality:
            try JSONEncoder().encode(issues.map {
                Codeclimate(
                    check_name: $0.hint,
                    description: $0.reason,
                    engine_name: "periphery",
                    fingerprint: $0.fingerprint,
                    severity: "minor",
                    type: "issue",
                    location: .init(lines: .init(begin: $0.line, end: $0.line), path: $0.path)
                )
            })
        }
    }
}
