import Foundation

protocol ReportFormater {
    func report(from data: Data, verbose: Bool) throws
}
