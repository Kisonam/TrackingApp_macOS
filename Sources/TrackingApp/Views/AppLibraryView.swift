import SwiftUI
import AppKit

enum SortOrder: String, CaseIterable {
    case mostTime
    case leastTime
    case byName

    func title(_ s: Strings) -> String {
        switch self {
        case .mostTime: return s.sortMostTime
        case .leastTime: return s.sortLeastTime
        case .byName: return s.sortByName
        }
    }
}

struct AppLibraryView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var allApps: [AppUsageRecord] = []
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .mostTime

    private let db = DatabaseManager.shared
    private var s: Strings { settings.strings }

    private var filteredApps: [AppUsageRecord] {
        var list = allApps
        if !searchText.isEmpty {
            list = list.filter {
                $0.appName.localizedCaseInsensitiveContains(searchText) ||
                $0.bundleIdentifier.localizedCaseInsensitiveContains(searchText)
            }
        }
        switch sortOrder {
        case .mostTime:
            list.sort { $0.totalSeconds > $1.totalSeconds }
        case .leastTime:
            list.sort { $0.totalSeconds < $1.totalSeconds }
        case .byName:
            list.sort { $0.appName.localizedCompare($1.appName) == .orderedAscending }
        }
        return list
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Text(s.libraryTitle)
                    .font(.title2.bold())
                Spacer()

                // Search
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField(s.search, text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                .frame(width: 200)

                // Sort
                Menu {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Button {
                            sortOrder = order
                        } label: {
                            HStack {
                                Text(order.title(s))
                                if sortOrder == order {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Label(s.sortBy, systemImage: "arrow.up.arrow.down")
                }
            }
            .padding()

            Divider()

            if filteredApps.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 48))
                        .foregroundStyle(.tertiary)
                    Text(searchText.isEmpty ? s.emptyLibrary : s.noDataTitle)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    if searchText.isEmpty {
                        Text(s.emptyLibrarySubtitle)
                            .font(.callout)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach(filteredApps) { record in
                            LibraryAppRow(record: record, strings: s)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .onAppear { loadData() }
        .onReceive(Timer.publish(every: 15, on: .main, in: .common).autoconnect()) { _ in
            loadData()
        }
    }

    private func loadData() {
        allApps = db.allTimeUsage()
    }
}

// MARK: - Library App Row

struct LibraryAppRow: View {
    let record: AppUsageRecord
    let strings: Strings
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 14) {
            // App icon
            let icon = AppMonitorService.iconForBundle(record.bundleIdentifier)
            Image(nsImage: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 42, height: 42)

            // Name & bundle
            VStack(alignment: .leading, spacing: 3) {
                Text(record.appName)
                    .font(.body.weight(.semibold))
                    .lineLimit(1)
                Text(record.bundleIdentifier)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Time
            VStack(alignment: .trailing, spacing: 3) {
                Text(strings.formatTime(record.totalSeconds))
                    .font(.callout.monospacedDigit().weight(.medium))
                Text(strings.totalTimeSpent)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            // Launch button
            Button {
                launchApp(record.bundleIdentifier)
            } label: {
                Label(strings.launch, systemImage: "play.fill")
                    .font(.callout.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(isHovered ? Color.primary.opacity(0.04) : Color.clear)
        .onHover { isHovered = $0 }
    }

    private func launchApp(_ bundleId: String) {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
            NSWorkspace.shared.openApplication(at: url, configuration: .init())
        }
    }
}
