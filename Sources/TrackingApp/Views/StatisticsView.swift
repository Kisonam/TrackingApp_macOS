import SwiftUI

enum StatsPeriod: String, CaseIterable {
    case today
    case week
    case month
    case allTime

    func title(_ s: Strings) -> String {
        switch self {
        case .today: return s.today
        case .week: return s.week
        case .month: return s.month
        case .allTime: return s.allTime
        }
    }
}

struct StatisticsView: View {
    @EnvironmentObject var monitor: AppMonitorService
    @EnvironmentObject var settings: AppSettings
    @State private var selectedPeriod: StatsPeriod = .today
    @State private var records: [AppUsageRecord] = []
    @State private var selectedDate = Date()

    private let db = DatabaseManager.shared
    private var s: Strings { settings.strings }

    private var totalSeconds: Int64 {
        records.reduce(0) { $0 + $1.totalSeconds }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text(s.statisticsTitle)
                    .font(.title2.bold())
                Spacer()

                Picker("", selection: $selectedPeriod) {
                    ForEach(StatsPeriod.allCases, id: \.self) { period in
                        Text(period.title(s)).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 350)
            }
            .padding()

            if selectedPeriod == .today {
                HStack {
                    DatePicker(s.dateLabel, selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.field)
                        .frame(width: 220)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }

            Divider()

            if records.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 48))
                        .foregroundStyle(.tertiary)
                    Text(s.noDataTitle)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text(s.noDataSubtitle)
                        .font(.callout)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else {
                // Summary bar
                HStack {
                    Label(s.totalTime, systemImage: "clock.fill")
                        .font(.headline)
                    Text(s.formatTime(totalSeconds))
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(.blue)
                    Spacer()
                    Text(s.trackedApps(records.count))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)

                Divider()

                // Usage bars
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(Array(records.enumerated()), id: \.element.id) { index, record in
                            UsageBarRow(
                                record: record,
                                maxSeconds: records.first?.totalSeconds ?? 1,
                                rank: index + 1,
                                totalSeconds: totalSeconds,
                                strings: s
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear { loadData() }
        .onChange(of: selectedPeriod) { _, _ in loadData() }
        .onChange(of: selectedDate) { _, _ in loadData() }
    }

    private func loadData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        switch selectedPeriod {
        case .today:
            let dateStr = formatter.string(from: selectedDate)
            records = db.usageForDate(dateStr).filter { !SystemAppFilter.shouldHide($0.bundleIdentifier) }
        case .week:
            let to = formatter.string(from: Date())
            let from = formatter.string(from: Calendar.current.date(byAdding: .day, value: -7, to: Date())!)
            records = db.usageForPeriod(from: from, to: to).filter { !SystemAppFilter.shouldHide($0.bundleIdentifier) }
        case .month:
            let to = formatter.string(from: Date())
            let from = formatter.string(from: Calendar.current.date(byAdding: .month, value: -1, to: Date())!)
            records = db.usageForPeriod(from: from, to: to).filter { !SystemAppFilter.shouldHide($0.bundleIdentifier) }
        case .allTime:
            records = db.allTimeUsage().filter { !SystemAppFilter.shouldHide($0.bundleIdentifier) }
        }
    }
}

// MARK: - Usage Bar Row

struct UsageBarRow: View {
    let record: AppUsageRecord
    let maxSeconds: Int64
    let rank: Int
    let totalSeconds: Int64
    let strings: Strings

    private var fraction: Double {
        guard maxSeconds > 0 else { return 0 }
        return Double(record.totalSeconds) / Double(maxSeconds)
    }

    private var percentage: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(record.totalSeconds) / Double(totalSeconds) * 100
    }

    private var barColor: Color {
        let colors: [Color] = [
            .blue, .purple, .orange, .green, .pink,
            .cyan, .indigo, .mint, .teal, .yellow
        ]
        return colors[rank % colors.count]
    }

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("\(rank)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 20, alignment: .trailing)

            // App icon
            let icon = AppMonitorService.iconForBundle(record.bundleIdentifier)
            Image(nsImage: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)

            // Name + bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(record.appName)
                        .font(.body.weight(.medium))
                        .lineLimit(1)
                    Spacer()
                    Text(String(format: "%.1f%%", percentage))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                    Text(strings.formatTimeShort(record.totalSeconds))
                        .font(.callout.monospacedDigit())
                        .foregroundStyle(.primary)
                }

                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(barColor.gradient)
                        .frame(width: max(4, geo.size.width * fraction))
                }
                .frame(height: 6)
            }
        }
        .padding(.vertical, 2)
    }
}
