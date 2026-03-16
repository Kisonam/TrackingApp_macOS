import SwiftUI

struct RunningAppsView: View {
    @EnvironmentObject var monitor: AppMonitorService
    @EnvironmentObject var settings: AppSettings

    private var s: Strings { settings.strings }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text(s.runningAppsTitle)
                    .font(.title2.bold())
                Spacer()
                Text(s.appsCount(monitor.runningApps.count))
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }
            .padding()

            Divider()

            // App list
            List(monitor.runningApps) { app in
                HStack(spacing: 12) {
                    // Icon
                    if let icon = app.icon {
                        Image(nsImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: "app.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(.secondary)
                    }

                    // Name & bundle ID
                    VStack(alignment: .leading, spacing: 2) {
                        Text(app.name)
                            .font(.body.weight(.medium))
                        Text(app.bundleIdentifier)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Uptime & active badge
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(s.formatUptime(app.launchDate))
                            .font(.callout.monospacedDigit())
                            .foregroundStyle(.secondary)
                        if app.bundleIdentifier == monitor.activeAppBundleId {
                            Text(s.active)
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.green, in: RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .listStyle(.inset)
        }
    }
}
