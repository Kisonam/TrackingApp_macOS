import Foundation

struct AppCategory: Identifiable, Hashable {
    let id: Int64
    var name: String
    var icon: String
    var bundleIdentifiers: [String]

    static func == (lhs: AppCategory, rhs: AppCategory) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
