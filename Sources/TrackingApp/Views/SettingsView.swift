import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @State private var syncStatus: SyncStatus = .idle

    private var s: Strings { settings.strings }

    enum SyncStatus: Equatable {
        case idle
        case syncing
        case success(Int)
        case error(String)
        case rateLimited(Int)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(s.settingsTitle)
                    .font(.title2.bold())
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            Form {
                // Appearance
                Section(s.appearance) {
                    Picker(s.themeLabel, selection: $settings.theme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.displayName(s)).tag(theme.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker(s.languageLabel, selection: $settings.language) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.displayName).tag(lang.rawValue)
                        }
                    }
                }

                // General
                Section(s.general) {
                    Toggle(s.launchAtLogin, isOn: $settings.launchAtLogin)
                }

                // Export
                Section(s.exportSection) {
                    HStack(spacing: 12) {
                        Button {
                            let db = DatabaseManager.shared
                            let records = db.allTimeUsage()
                            ExportService.exportCSV(records: records, language: settings.language)
                        } label: {
                            Label(s.exportCSV, systemImage: "tablecells")
                        }

                        Button {
                            ExportService.exportDatabase()
                        } label: {
                            Label(s.saveDatabase, systemImage: "externaldrive")
                        }
                    }
                }

                // Firebase
                Section(s.firebaseSection) {
                    Toggle(s.firebaseEnabled, isOn: $settings.firebaseEnabled)

                    if settings.firebaseEnabled {
                        TextField(s.firebaseProjectId, text: $settings.firebaseProjectId)
                            .textFieldStyle(.roundedBorder)

                        TextField(s.firebaseApiKey, text: $settings.firebaseApiKey)
                            .textFieldStyle(.roundedBorder)

                        TextField(s.firebaseCollection, text: $settings.firebaseCollection)
                            .textFieldStyle(.roundedBorder)

                        Text(s.firebaseHint)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            Button {
                                performSync()
                            } label: {
                                Label(
                                    syncStatus == .syncing ? s.firebaseSyncing : s.firebaseSyncNow,
                                    systemImage: syncStatus == .syncing ? "arrow.triangle.2.circlepath" : "arrow.up.circle.fill"
                                )
                            }
                            .disabled(syncStatus == .syncing || settings.firebaseProjectId.isEmpty)

                            switch syncStatus {
                            case .success(let n):
                                Text(s.firebaseSyncSuccess(n))
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            case .error(let msg):
                                Text("\(s.firebaseSyncError): \(msg)")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .lineLimit(2)
                            case .rateLimited(let seconds):
                                Text(s.firebaseRateLimited(seconds))
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            default:
                                EmptyView()
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 480, height: settings.firebaseEnabled ? 580 : 380)
        .animation(.easeInOut(duration: 0.2), value: settings.firebaseEnabled)
    }

    private func performSync() {
        syncStatus = .syncing
        FirebaseService.shared.syncUsageData(
            projectId: settings.firebaseProjectId,
            apiKey: settings.firebaseApiKey,
            collection: settings.firebaseCollection
        ) { result in
            switch result {
            case .success(let count):
                syncStatus = .success(count)
            case .failure(let error):
                if let firebaseError = error as? FirebaseError,
                   case .rateLimited(let seconds) = firebaseError {
                    syncStatus = .rateLimited(seconds)
                } else {
                    syncStatus = .error(error.localizedDescription)
                }
            }
        }
    }
}
