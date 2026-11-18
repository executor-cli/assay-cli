import Foundation

public struct Codeclimate: Codable {
    public struct Location: Codable {
        public struct Line: Codable {
            public let begin: Int?
            public let end: Int?

            public init(begin: Int?, end: Int?) {
                self.begin = begin
                self.end = end
            }
        }

        public let lines: Line
        public let path: String?

        public init(lines: Line, path: String?) {
            self.lines = lines
            self.path = path
        }
    }

    public let check_name: String
    public let description: String
    public let engine_name: String
    public let fingerprint: String
    public let severity: String
    public let type: String
    public let location: Location

    public init(
        check_name: String,
        description: String,
        engine_name: String,
        fingerprint: String,
        severity: String,
        type: String,
        location: Location
    ) {
        self.check_name = check_name
        self.description = description
        self.engine_name = engine_name
        self.fingerprint = fingerprint
        self.severity = severity
        self.type = type
        self.location = location
    }
}
