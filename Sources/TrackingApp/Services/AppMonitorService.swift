import Foundation
import AppKit
import Combine

final class AppMonitorService: ObservableObject {
    @Published var runningApps: [RunningAppInfo] = []
    @Published var activeAppBundleId: String = ""
    @Published var todayUsage: [AppUsageRecord] = []

    private let db = DatabaseManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        updateRunningApps()
        refreshTodayUsage()

        // Track active (frontmost) app every second
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
            .store(in: &cancellables)

        // Refresh running apps list every 3 seconds
        Timer.publish(every: 3.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.updateRunningApps() }
            .store(in: &cancellables)

        // Refresh statistics every 10 seconds
        Timer.publish(every: 10.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.refreshTodayUsage() }
            .store(in: &cancellables)
    }

    // MARK: - Tracking

    private func tick() {
        guard let frontApp = NSWorkspace.shared.frontmostApplication,
              let bundleId = frontApp.bundleIdentifier,
              let name = frontApp.localizedName else { return }
        
        // Skip system apps
        guard !SystemAppFilter.shouldHide(bundleId) else { return }
        guard !SystemAppFilter.shouldHideProcess(name) else { return }

        activeAppBundleId = bundleId
        db.recordUsage(bundleIdentifier: bundleId, appName: name)
    }

    // MARK: - Running Apps

    func updateRunningApps() {
        let apps = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .compactMap { app -> RunningAppInfo? in
                guard let bundleId = app.bundleIdentifier,
                      let name = app.localizedName else { return nil }
                
                // Skip system apps
                guard !SystemAppFilter.shouldHide(bundleId) else { return nil }
                guard !SystemAppFilter.shouldHideProcess(name) else { return nil }
                
                return RunningAppInfo(
                    id: bundleId,
                    name: name,
                    bundleIdentifier: bundleId,
                    icon: app.icon,
                    launchDate: app.launchDate,
                    isActive: app.isActive,
                    pid: app.processIdentifier
                )
            }

        runningApps = apps.sorted {
            if $0.isActive != $1.isActive { return $0.isActive }
            return $0.name.localizedCompare($1.name) == .orderedAscending
        }
        activeAppBundleId = NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? ""
    }

    // MARK: - Statistics

    func refreshTodayUsage() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        todayUsage = db.usageForDate(formatter.string(from: Date()))
    }

    // MARK: - Helpers

    static func iconForBundle(_ bundleId: String) -> NSImage {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
            return NSWorkspace.shared.icon(forFile: url.path)
        }
        return NSImage(systemSymbolName: "app.fill", accessibilityDescription: nil)
            ?? NSImage()
    }
}
