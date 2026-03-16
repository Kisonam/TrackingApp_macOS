import SwiftUI
import ServiceManagement

final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var language: String {
        didSet { UserDefaults.standard.set(language, forKey: "appLanguage") }
    }
    @Published var theme: String {
        didSet { UserDefaults.standard.set(theme, forKey: "appTheme") }
    }
    @Published var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin")
            updateLoginItem()
        }
    }
    @Published var sidebarWidth: CGFloat {
        didSet { UserDefaults.standard.set(Double(sidebarWidth), forKey: "sidebarWidth") }
    }

    // Firebase
    @Published var firebaseEnabled: Bool {
        didSet { UserDefaults.standard.set(firebaseEnabled, forKey: "firebaseEnabled") }
    }
    @Published var firebaseProjectId: String {
        didSet { UserDefaults.standard.set(firebaseProjectId, forKey: "firebaseProjectId") }
    }
    @Published var firebaseApiKey: String {
        didSet { UserDefaults.standard.set(firebaseApiKey, forKey: "firebaseApiKey") }
    }
    @Published var firebaseCollection: String {
        didSet { UserDefaults.standard.set(firebaseCollection, forKey: "firebaseCollection") }
    }

    var strings: Strings { Strings(language: language) }

    var colorScheme: ColorScheme? {
        switch theme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    private init() {
        self.language = UserDefaults.standard.string(forKey: "appLanguage") ?? "ua"
        self.theme = UserDefaults.standard.string(forKey: "appTheme") ?? "system"
        self.launchAtLogin = UserDefaults.standard.bool(forKey: "launchAtLogin")
        let stored = UserDefaults.standard.double(forKey: "sidebarWidth")
        self.sidebarWidth = stored > 0 ? CGFloat(stored) : 190

        self.firebaseEnabled = UserDefaults.standard.bool(forKey: "firebaseEnabled")
        self.firebaseProjectId = UserDefaults.standard.string(forKey: "firebaseProjectId") ?? ""
        self.firebaseApiKey = UserDefaults.standard.string(forKey: "firebaseApiKey") ?? ""
        self.firebaseCollection = UserDefaults.standard.string(forKey: "firebaseCollection") ?? "app_usage"
    }

    private func updateLoginItem() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("⚠️ Login item: \(error.localizedDescription)")
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case ukrainian = "ua"
    case polish = "pl"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .ukrainian: return "Українська"
        case .polish: return "Polski"
        }
    }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    func displayName(_ s: Strings) -> String {
        switch self {
        case .system: return s.themeSystem
        case .light: return s.themeLight
        case .dark: return s.themeDark
        }
    }
}
