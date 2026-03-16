import SwiftUI
import AppKit

// MARK: - Sidebar Selection

enum SidebarSelection: Hashable {
    case running
    case library
    case statistics
    case category(Int64)
}

// MARK: - Content View

struct ContentView: View {
    @State private var selection: SidebarSelection? = .running
    @State private var showSettings = false
    @State private var showNewCategory = false
    @State private var categories: [AppCategory] = []
    @GestureState private var dragOffset: CGFloat = 0

    @EnvironmentObject var monitorService: AppMonitorService
    @EnvironmentObject var settings: AppSettings

    private var s: Strings { settings.strings }

    private var effectiveWidth: CGFloat {
        max(150, min(300, settings.sidebarWidth + dragOffset))
    }

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            sidebar
                .frame(width: effectiveWidth)

            // Drag handle
            dragDivider

            // Detail
            detailView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 750, minHeight: 480)
        .onAppear { reloadCategories() }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(settings)
        }
        .sheet(isPresented: $showNewCategory) {
            NewCategorySheet(onCreated: { reloadCategories() })
                .environmentObject(settings)
        }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        VStack(spacing: 0) {
            List(selection: $selection) {
                Section {
                    Label(s.running, systemImage: "play.circle.fill")
                        .tag(SidebarSelection.running)
                    Label(s.library, systemImage: "square.grid.2x2")
                        .tag(SidebarSelection.library)
                    Label(s.statistics, systemImage: "chart.bar.fill")
                        .tag(SidebarSelection.statistics)
                }

                Section(s.categories) {
                    ForEach(categories) { cat in
                        Label(cat.name, systemImage: cat.icon)
                            .tag(SidebarSelection.category(cat.id))
                    }

                    Button {
                        showNewCategory = true
                    } label: {
                        Label(s.newCategory, systemImage: "plus.circle")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.sidebar)

            Divider()

            Button {
                showSettings = true
            } label: {
                Label(s.settings, systemImage: "gearshape.fill")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Drag Divider

    private var dragDivider: some View {
        Rectangle()
            .fill(Color(nsColor: .separatorColor))
            .frame(width: 1)
            .overlay(alignment: .center) {
                Capsule()
                    .fill(dragOffset != 0 ? Color.accentColor : Color.secondary.opacity(0.45))
                    .frame(width: 4, height: 32)
            }
            .contentShape(Rectangle().inset(by: -5))
            .onHover { hovering in
                if hovering {
                    NSCursor.resizeLeftRight.push()
                } else {
                    NSCursor.pop()
                }
            }
            .gesture(
                DragGesture(minimumDistance: 1)
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        settings.sidebarWidth = max(150, min(300, settings.sidebarWidth + value.translation.width))
                    }
            )
    }

    // MARK: - Detail

    @ViewBuilder
    private var detailView: some View {
        switch selection {
        case .running:
            RunningAppsView()
        case .library:
            AppLibraryView()
        case .statistics:
            StatisticsView()
        case .category(let id):
            if let cat = categories.first(where: { $0.id == id }) {
                CategoryDetailView(category: cat, onUpdate: {
                    reloadCategories()
                })
            } else {
                Text(s.selectSection)
                    .foregroundStyle(.secondary)
            }
        case nil:
            Text(s.selectSection)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Data

    private func reloadCategories() {
        categories = DatabaseManager.shared.getAllCategories()
    }
}
