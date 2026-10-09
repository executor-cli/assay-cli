import Foundation

public enum LinterType: String, Sendable {
    case json
    case codeQuality = "code-quality"
    case console
}

extension LinterType {
    var reporter: String {
        switch self {
        case .codeQuality: "codeclimate"
        case .console, .json: "json"
        }
    }
}
