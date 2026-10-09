import Foundation
import Path
@testable import LinterKit

final class CreateFileServiceMock: CreateFileService {
    // MARK: - createFile

    var createFileAtPathContentsAttributesCallsCount = 0
    var createFileAtPathContentsAttributesCalled: Bool {
        createFileAtPathContentsAttributesCallsCount > 0
    }

    var createFileAtPathContentsAttributesReceivedArguments: (
        path: String,
        data: Data?,
        attr: [FileAttributeKey: Any]?
    )?
    var createFileAtPathContentsAttributesReceivedInvocations: [(
        path: String,
        data: Data?,
        attr: [FileAttributeKey: Any]?
    )] = []
    var createFileAtPathContentsAttributesReturnValue: Bool = true
    var createFileAtPathContentsAttributesClosure: ((String, Data?, [FileAttributeKey: Any]?) -> Bool)?

    func createFile(
        atPath path: String,
        contents data: Data?,
        attributes attr: [FileAttributeKey: Any]?
    ) -> Bool {
        createFileAtPathContentsAttributesCallsCount += 1
        createFileAtPathContentsAttributesReceivedArguments = (path: path, data: data, attr: attr)
        createFileAtPathContentsAttributesReceivedInvocations.append((path: path, data: data, attr: attr))
        return createFileAtPathContentsAttributesClosure
            .map { $0(path, data, attr) } ?? createFileAtPathContentsAttributesReturnValue
    }

    // MARK: - createDirectory

    var createDirectoryAtPathWithIntermediateDirectoriesAttributesCallsCount = 0
    var createDirectoryAtPathWithIntermediateDirectoriesAttributesCalled: Bool {
        createDirectoryAtPathWithIntermediateDirectoriesAttributesCallsCount > 0
    }

    var createDirectoryAtPathWithIntermediateDirectoriesAttributesReceivedArguments: (
        patch: String,
        createIntermediates: Bool,
        attributes: [FileAttributeKey: Any]?
    )?
    var createDirectoryAtPathWithIntermediateDirectoriesAttributesThrowableError: Error?

    func createDirectory(
        atPath patch: String,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey: Any]?
    ) throws {
        createDirectoryAtPathWithIntermediateDirectoriesAttributesCallsCount += 1
        createDirectoryAtPathWithIntermediateDirectoriesAttributesReceivedArguments = (
            patch: patch,
            createIntermediates: createIntermediates,
            attributes: attributes
        )

        if let error = createDirectoryAtPathWithIntermediateDirectoriesAttributesThrowableError {
            throw error
        }
    }
}
