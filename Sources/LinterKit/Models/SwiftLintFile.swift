import Foundation

public struct SwiftLintFile: Codable {
    public let character: Int?
    public let file: String?
    public let line: Int?
    public let reason: String
    public let rule_id: String
    public let severity: String
    public let type: String

    public init(
        character: Int?,
        file: String?,
        line: Int?,
        reason: String,
        rule_id: String,
        severity: String,
        type: String
    ) {
        self.character = character
        self.file = file
        self.line = line
        self.reason = reason
        self.rule_id = rule_id
        self.severity = severity
        self.type = type
    }
}
