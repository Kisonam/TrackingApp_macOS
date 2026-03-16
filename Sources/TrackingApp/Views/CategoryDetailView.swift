import SwiftUI
import AppKit

struct CategoryDetailView: View {
    @EnvironmentObject var settings: AppSettings
    let category: AppCategory
    let onUpdate: () -> Void

    @State private var usageRecords: [AppUsageRecord] = []
    @State private var showAddApps = false
    @State private var showEditSheet = false
    @State private var showDeleteConfirm = false

    private let db = DatabaseManager.shared
    private var s: Strings { settings.strings }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundStyle(.tint)
                Text(category.name)
                    .font(.title2.bold())
                Spacer()

                Button {
                    showAddApps = true
                } label: {
                    Label(s.addApps, systemImage: "plus")
                }

                Menu {
                    Button {
                        showEditSheet = true
                    } label: {
                        Label(s.editCategory, systemImage: "pencil")
                    }
                    Divider()
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label(s.deleteCategory, systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            .padding()

            Divider()

            if usageRecords.isEmpty && category.bundleIdentifiers.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "folder")
                        .font(.system(size: 48))
                        .foregroundStyle(.tertiary)
                    Text(s.emptyCategoryTitle)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text(s.emptyCategorySubtitle)
                        .font(.callout)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach(usageRecords) { record in
                            CategoryAppRow(
                                record: record,
                                strings: s,
                                onRemove: {
                                    db.removeAppFromCategory(categoryId: category.id, bundleIdentifier: record.bundleIdentifier)
                                    loadUsage()
                                    onUpdate()
                                }
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .onAppear { loadUsage() }
        .sheet(isPresented: $showAddApps) {
            AddAppsToCategorySheet(category: category, onDone: {
                loadUsage()
                onUpdate()
            })
            .environmentObject(settings)
        }
        .sheet(isPresented: $showEditSheet) {
            EditCategorySheet(category: category, onSave: { onUpdate() })
                .environmentObject(settings)
        }
        .alert(s.deleteCategoryConfirm, isPresented: $showDeleteConfirm) {
            Button(s.cancel, role: .cancel) {}
            Button(s.deleteCategory, role: .destructive) {
                db.deleteCategory(id: category.id)
                onUpdate()
            }
        }
    }

    private func loadUsage() {
        usageRecords = db.categoryUsage(categoryId: category.id)
    }
}

// MARK: - Category App Row

struct CategoryAppRow: View {
    let record: AppUsageRecord
    let strings: Strings
    let onRemove: () -> Void
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 14) {
            let icon = AppMonitorService.iconForBundle(record.bundleIdentifier)
            Image(nsImage: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.appName)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                Text(record.bundleIdentifier)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(strings.formatTime(record.totalSeconds))
                .font(.callout.monospacedDigit())
                .foregroundStyle(.secondary)

            Button {
                launchApp(record.bundleIdentifier)
            } label: {
                Image(systemName: "play.fill")
            }
            .buttonStyle(.borderless)

            Button(role: .destructive) {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
            .opacity(isHovered ? 1 : 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isHovered ? Color.primary.opacity(0.04) : Color.clear)
        .onHover { isHovered = $0 }
    }

    private func launchApp(_ bundleId: String) {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
            NSWorkspace.shared.openApplication(at: url, configuration: .init())
        }
    }
}

// MARK: - Add Apps Sheet

struct AddAppsToCategorySheet: View {
    let category: AppCategory
    let onDone: () -> Void
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    @State private var allApps: [AppUsageRecord] = []
    @State private var selected: Set<String> = []
    @State private var searchText = ""

    private let db = DatabaseManager.shared
    private var s: Strings { settings.strings }

    private var filteredApps: [AppUsageRecord] {
        let notInCategory = allApps.filter { !category.bundleIdentifiers.contains($0.bundleIdentifier) }
        if searchText.isEmpty { return notInCategory }
        return notInCategory.filter {
            $0.appName.localizedCaseInsensitiveContains(searchText) ||
            $0.bundleIdentifier.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(s.addApps)
                    .font(.title3.bold())
                Spacer()
                Button(s.cancel) { dismiss() }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                Button(s.save) {
                    for bundleId in selected {
                        db.addAppToCategory(categoryId: category.id, bundleIdentifier: bundleId)
                    }
                    onDone()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(selected.isEmpty)
            }
            .padding()

            // Search
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                AutoFocusTextField(placeholder: s.search, text: $searchText, autoFocus: true)
                    .frame(height: 20)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
            .padding(.bottom, 8)

            Divider()

            List(filteredApps, selection: $selected) { record in
                HStack(spacing: 10) {
                    let icon = AppMonitorService.iconForBundle(record.bundleIdentifier)
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(record.appName)
                            .font(.body.weight(.medium))
                        Text(record.bundleIdentifier)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(s.formatTimeShort(record.totalSeconds))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                .tag(record.bundleIdentifier)
            }
            .listStyle(.inset)
        }
        .frame(width: 480, height: 420)
        .onAppear {
            allApps = db.allTimeUsage()
        }
    }
}

// MARK: - Edit Category Sheet

struct EditCategorySheet: View {
    let category: AppCategory
    let onSave: () -> Void
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var icon: String = ""

    private let db = DatabaseManager.shared
    private var s: Strings { settings.strings }

    private let iconOptions = [
        "folder.fill", "gamecontroller.fill", "desktopcomputer",
        "hammer.fill", "paintbrush.fill", "music.note",
        "video.fill", "book.fill", "globe", "briefcase.fill",
        "message.fill", "cart.fill", "heart.fill", "star.fill"
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text(s.editCategory)
                .font(.title3.bold())

            AutoFocusTextField(placeholder: s.categoryName, text: $name)
                .frame(height: 24)

            VStack(alignment: .leading, spacing: 6) {
                Text(s.categoryIcon)
                    .font(.callout.weight(.medium))
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(36)), count: 7), spacing: 8) {
                    ForEach(iconOptions, id: \.self) { opt in
                        Image(systemName: opt)
                            .font(.title3)
                            .frame(width: 32, height: 32)
                            .background(icon == opt ? Color.accentColor.opacity(0.2) : Color.clear, in: RoundedRectangle(cornerRadius: 6))
                            .onTapGesture { icon = opt }
                    }
                }
            }

            HStack {
                Button(s.cancel) { dismiss() }
                    .buttonStyle(.plain)
                Spacer()
                Button(s.save) {
                    db.updateCategory(id: category.id, name: name, icon: icon)
                    onSave()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 320)
        .onAppear {
            name = category.name
            icon = category.icon
        }
    }
}

// MARK: - New Category Sheet

struct NewCategorySheet: View {
    let onCreated: () -> Void
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var icon: String = "folder.fill"

    private let db = DatabaseManager.shared
    private var s: Strings { settings.strings }

    private let iconOptions = [
        "folder.fill", "gamecontroller.fill", "desktopcomputer",
        "hammer.fill", "paintbrush.fill", "music.note",
        "video.fill", "book.fill", "globe", "briefcase.fill",
        "message.fill", "cart.fill", "heart.fill", "star.fill"
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text(s.newCategory)
                .font(.title3.bold())

            AutoFocusTextField(placeholder: s.categoryName, text: $name)
                .frame(height: 24)

            VStack(alignment: .leading, spacing: 6) {
                Text(s.categoryIcon)
                    .font(.callout.weight(.medium))
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(36)), count: 7), spacing: 8) {
                    ForEach(iconOptions, id: \.self) { opt in
                        Image(systemName: opt)
                            .font(.title3)
                            .frame(width: 32, height: 32)
                            .background(icon == opt ? Color.accentColor.opacity(0.2) : Color.clear, in: RoundedRectangle(cornerRadius: 6))
                            .onTapGesture { icon = opt }
                    }
                }
            }

            HStack {
                Button(s.cancel) { dismiss() }
                    .buttonStyle(.plain)
                Spacer()
                Button(s.create) {
                    db.createCategory(name: name, icon: icon)
                    onCreated()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 320)
    }
}
