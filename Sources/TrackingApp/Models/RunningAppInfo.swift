import Foundation
import AppKit

struct RunningAppInfo: Identifiable {
    let id: String
    let name: String
    let bundleIdentifier: String
    let icon: NSImage?
    let launchDate: Date?
    let isActive: Bool
    let pid: pid_t

    var uptimeString: String {
        guard let launch = launchDate else { return "—" }
        let interval = Date().timeIntervalSince(launch)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let secs = Int(interval) % 60
        if hours > 0 {
            return String(format: "%dг %02dхв", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dхв %02dс", minutes, secs)
        } else {
            return String(format: "%dс", secs)
        }
    }
}
