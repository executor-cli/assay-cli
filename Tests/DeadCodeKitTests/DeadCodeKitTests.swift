import DeadCodeKit
import Foundation
import LinterKit
import Testing

private let peripheryJSON = Data("""
[
  {
    "kind": "function.free",
    "name": "neverCalled()",
    "hints": ["unused"],
    "ids": ["s:5Probe11neverCalledyyF", "s:other"],
    "location": "Sources/Probe/main.swift:2:6",
    "modules": ["Probe"],
    "accessibility": "internal",
    "attributes": [],
    "modifiers": []
  },
  {
    "kind": "var.instance",
    "name": "value",
    "hints": [],
    "ids": [],
    "location": "C:/odd:path/File.swift:10:3"
  }
]
""".utf8)

@Test(arguments: [LinterType.console, .json])
func mapsToSwiftLintFiles(reporter: LinterType) throws {
    let mock = ReportFormaterMock()

    #expect(throws: DeadCodeError.deadCodeFound(count: 2)) {
        try DeadCodeReporter(reporter: reporter, reportFormater: mock).report(
            from: peripheryJSON,
            verbose: true
        )
    }

    #expect(mock.reportReceivedInvocations.count == 1)
    #expect(mock.reportReceivedInvocations.first?.verbose == true)
    let files = try JSONDecoder().decode(
        [SwiftLintFile].self,
        from: #require(mock.reportReceivedInvocations.first?.data)
    )
    #expect(files.count == 2)
    #expect(files[0].file == "Sources/Probe/main.swift")
    #expect(files[0].line == 2)
    #expect(files[0].character == 6)
    #expect(files[0].rule_id == "unused")
    #expect(files[0].reason == "unused function.free 'neverCalled()'")
    #expect(files[0].severity == "warning")
    #expect(files[0].type == "Dead Code")
    #expect(files[1].file == "C:/odd:path/File.swift")
    #expect(files[1].line == 10)
    #expect(files[1].character == 3)
    #expect(files[1].rule_id == "unused")
}

@Test
func mapsToCodeclimate() throws {
    let mock = ReportFormaterMock()

    #expect(throws: DeadCodeError.deadCodeFound(count: 2)) {
        try DeadCodeReporter(reporter: .codeQuality, reportFormater: mock).report(
            from: peripheryJSON,
            verbose: false
        )
    }

    #expect(mock.reportReceivedInvocations.count == 1)
    let issues = try JSONDecoder().decode(
        [Codeclimate].self,
        from: #require(mock.reportReceivedInvocations.first?.data)
    )
    #expect(issues.count == 2)
    #expect(issues[0].check_name == "unused")
    #expect(issues[0].description == "unused function.free 'neverCalled()'")
    #expect(issues[0].engine_name == "periphery")
    #expect(issues[0].fingerprint == "s:5Probe11neverCalledyyF,s:other")
    #expect(issues[0].severity == "minor")
    #expect(issues[0].type == "issue")
    #expect(issues[0].location.path == "Sources/Probe/main.swift")
    #expect(issues[0].location.lines.begin == 2)
    #expect(issues[0].location.lines.end == 2)
    #expect(issues[1].fingerprint == "C:/odd:path/File.swift:10:value")
    #expect(issues[1].location.path == "C:/odd:path/File.swift")
    #expect(issues[1].location.lines.begin == 10)
}

@Test(arguments: [LinterType.console, .json, .codeQuality])
func emptyResultsReportOnceWithoutThrowing(reporter: LinterType) throws {
    let mock = ReportFormaterMock()

    try DeadCodeReporter(reporter: reporter, reportFormater: mock).report(
        from: Data("[]".utf8),
        verbose: false
    )

    #expect(mock.reportReceivedInvocations.count == 1)
    #expect(mock.reportReceivedInvocations.first?.data == Data("[]".utf8))
}

@Test
func excludesMapToGlobs() {
    #expect(
        DeadCodeInput.excludeGlobs([".build", "./Sources/Generated/", "Pods/", "a/b"])
            == ["**/.build/**", "**/Sources/Generated/**", "**/Pods/**", "**/a/b/**"]
    )
}

@Test
func packageCheck() throws {
    let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: folder) }

    #expect(throws: DeadCodeError.packageNotFound(path: folder.path)) {
        try DeadCodeInput.checkPackage(at: folder.path)
    }

    try Data().write(to: folder.appendingPathComponent("Package.swift"))
    try DeadCodeInput.checkPackage(at: folder.path)
}
