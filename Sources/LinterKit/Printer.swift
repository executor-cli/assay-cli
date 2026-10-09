import CascadeKit
import Foundation

// MARK: - Protocol

/// Protocol for printing output to various destinations.
public protocol Printer: Sendable {
    /// Prints a string to the output destination.
    /// - Parameter string: The string to print.
    func print(_ string: String)
}

// MARK: - Default Implementation

/// Default implementation of Printer that outputs to the standard output (console).
struct ConsolePrinter: Printer {
    /// Creates a new console printer instance.
    init() {}

    /// Prints a string to the standard output.
    /// - Parameter string: The string to print to the console.
    func print(_ string: String) {
        Swift.print(string)
    }
}

struct ConsolePrinterKey: DependencyKey {
    static var liveValue: Printer {
        ConsolePrinter()
    }
}

extension DependencyValues {
    var printer: Printer {
        get { self[ConsolePrinterKey.self] }
        set { self[ConsolePrinterKey.self] = newValue }
    }
}
