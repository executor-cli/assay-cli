import Foundation

// MARK: Input Protocol

/// Protocol for creating files in the file system.
public protocol CreateFileService {
    /// Creates a file at the specified path with optional contents and file attributes.
    ///
    /// This method allows you to create a new file at the provided path, optionally specifying the file's
    /// contents
    /// and attributes such as permissions, creation date, etc.
    ///
    /// - Parameters:
    ///   - path: The file system path where the file will be created.
    ///   - data: The optional data to be written to the file. If `nil`, an empty file is created.
    ///   - attributes: An optional dictionary of file attributes to apply to the new file (e.g.,
    /// `.posixPermissions`).
    /// - Returns: A `Bool` indicating whether the file was successfully created.
    /// - Note: The result is discardable, meaning it is optional to use the return value.
    @discardableResult
    func createFile(
        atPath path: String,
        contents data: Data?,
        attributes attr: [FileAttributeKey: Any]?
    ) -> Bool

    /// Creates a directory at the specified path with optional intermediate directories.
    ///
    /// This method allows you to create a new directory at the provided path, optionally creating
    /// intermediate directories along the path.
    ///
    /// - Parameters:
    ///   - patch: The file system path where the directory will be created.
    ///   - withIntermediateDirectories: A Boolean value indicating whether to create intermediate
    /// directories.
    ///   - attributes: An optional dictionary of file attributes to apply to the new directory.
    /// - Throws: An error if the directory cannot be created.
    func createDirectory(
        atPath patch: String,
        withIntermediateDirectories: Bool,
        attributes: [FileAttributeKey: Any]?
    ) throws
}

// MARK: Conformance to CreateFolderService

extension FileManager: CreateFileService {}
