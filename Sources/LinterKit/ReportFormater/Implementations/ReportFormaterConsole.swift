import Foundation
import Path

struct ReportFormaterConsole: ReportFormater {
    private let printer: any Printer

    init(printer: any Printer) {
        self.printer = printer
    }

    func report(from data: Data, verbose: Bool) throws {
        let json = try JSONDecoder().decode([SwiftLintFile].self, from: data)

        guard !json.isEmpty else { return printer.print("✅ no issues found") }

        printer.print("❌ some issues was found")

        let dict = Dictionary(grouping: json, by: { $0.severity })

        for key in dict.keys {
            printer.print("Type: \(key)")
            for value in dict[key]! {
                var message = value.reason
                if let file = value.file {
                    message += " at: \(file)"
                }
                if let line = value.line {
                    message += " on line: \(line)"
                }
                printer.print(message)
            }
        }
    }
}
