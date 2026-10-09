import Foundation

extension Array where Element: Equatable {
    public func merging(_ other: [Element]) -> [Element] {
        var result = self
        for element in other where !result.contains(element) {
            result.append(element)
        }
        return result
    }
}
