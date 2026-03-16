import Foundation

struct AppUsageRecord: Identifiable, Hashable {
    var id: String { "\(bundleIdentifier)_\(date)" }
    let bundleIdentifier: String
    let appName: String
    let totalSeconds: Int64
    let date: String

    var formattedTime: String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60
        if hours > 0 {
            return String(format: "%dг %02dхв", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dхв %02dс", minutes, secs)
        } else {
            return String(format: "%dс", secs)
        }
    }
}
