import Foundation

struct Codeclimate: Codable {
    struct Location: Codable {
        struct Line: Codable {
            let begin: Int?
            let end: Int?
        }

        let lines: Line
        let path: String?
    }

    let check_name: String
    let description: String
    let engine_name: String
    let fingerprint: String
    let severity: String
    let type: String
    let location: Location
}
