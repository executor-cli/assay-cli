import Foundation

extension String {
    func adding(prefix: String?, separator: String = ".") -> Self {
        guard let prefix, !prefix.isEmpty else { return self }

        return prefix + separator + self
    }
}

extension String {
    /// The default filename for code quality reports
    public static let codeQualityReportFileName: String = "gl-code-quality-report.json"

    /// The default filename for documentation linter reports
    public static let documentationReportFileName: String = "documentation-linter.json"
}
