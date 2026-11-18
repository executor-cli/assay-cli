import Foundation

public enum DeadCodeInput {
    public static func checkPackage(at path: String) throws {
        let manifest = URL(fileURLWithPath: path).appendingPathComponent("Package.swift").path
        guard FileManager.default.fileExists(atPath: manifest) else {
            throw DeadCodeError.packageNotFound(path: path)
        }
    }

    public static func excludeGlobs(_ excludes: [String]) -> [String] {
        excludes.map { exclude in
            var entry = Substring(exclude)
            if entry.hasPrefix("./") { entry = entry.dropFirst(2) }
            if entry.hasSuffix("/") { entry = entry.dropLast() }
            return "**/\(entry)/**"
        }
    }
}
