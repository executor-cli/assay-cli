import Foundation
import Path

extension AbsolutePath {
    /// The process's current working directory.
    public static var currentWorkingDirectory: AbsolutePath {
        // swiftlint:disable:next force_try
        try! AbsolutePath(validating: FileManager.default.currentDirectoryPath)
    }

    public static var temporary: AbsolutePath {
        try! AbsolutePath(validating: FileManager.default.temporaryDirectory.path())
    }
}
