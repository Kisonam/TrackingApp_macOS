import Foundation
import AppKit
import UniformTypeIdentifiers

enum ExportService {

    static func exportCSV(records: [AppUsageRecord], language: String) {
        let s = Strings(language: language)
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.commaSeparatedText]
        panel.nameFieldStringValue = "app_usage.csv"
        panel.title = s.exportCSV

        guard panel.runModal() == .OK, let url = panel.url else { return }

        var csv = "App Name,Bundle ID,Total Seconds,Time,Date\n"
        for r in records {
            let escaped = r.appName.replacingOccurrences(of: "\"", with: "\"\"")
            csv += "\"\(escaped)\",\"\(r.bundleIdentifier)\",\(r.totalSeconds),\"\(s.formatTime(r.totalSeconds))\",\"\(r.date)\"\n"
        }

        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("❌ CSV export: \(error.localizedDescription)")
        }
    }

    static func exportDatabase() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType(filenameExtension: "db") ?? .data]
        panel.nameFieldStringValue = "tracking.db"

        guard panel.runModal() == .OK, let dest = panel.url else { return }

        let source = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first!.appendingPathComponent("TrackingApp/tracking.db")

        do {
            if FileManager.default.fileExists(atPath: dest.path) {
                try FileManager.default.removeItem(at: dest)
            }
            try FileManager.default.copyItem(at: source, to: dest)
        } catch {
            print("❌ DB export: \(error.localizedDescription)")
        }
    }
}
