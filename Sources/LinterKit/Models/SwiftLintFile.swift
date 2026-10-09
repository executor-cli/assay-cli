import Foundation

struct SwiftLintFile: Codable {
    let character: Int?
    let file: String?
    let line: Int?
    let reason: String
    let rule_id: String
    let severity: String
    let type: String
}
