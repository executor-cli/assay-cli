import Foundation

public enum DeadCodeError: Error, Equatable, Sendable {
    case deadCodeFound(count: Int)
    case packageNotFound(path: String)
}

extension DeadCodeError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .deadCodeFound(count):
            "Found \(count) unused declaration(s)."
        case let .packageNotFound(path):
            "No Package.swift found at \(path)."
        }
    }
}
