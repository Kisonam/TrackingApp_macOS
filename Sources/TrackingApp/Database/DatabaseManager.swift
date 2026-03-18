import Foundation
import SQLite3

final class DatabaseManager {
    static let shared = DatabaseManager()

    private var db: OpaquePointer?
    private let sqliteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    private init() {
        openDatabase()
        createTables()
    }

    deinit {
        sqlite3_close(db)
    }

    // MARK: - Setup

    private func openDatabase() {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first!.appendingPathComponent("TrackingApp")

        try? FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
        let dbPath = appSupport.appendingPathComponent("tracking.db").path

        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("📂 DB: \(dbPath)")
        } else {
            print("❌ DB open error: \(errorMessage)")
        }
    }

    private func createTables() {
        let sql = """
        CREATE TABLE IF NOT EXISTS app_usage (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bundle_identifier TEXT NOT NULL,
            app_name TEXT NOT NULL,
            total_seconds INTEGER NOT NULL DEFAULT 0,
            date TEXT NOT NULL,
            UNIQUE(bundle_identifier, date)
        );
        CREATE INDEX IF NOT EXISTS idx_usage_date ON app_usage(date);
        CREATE INDEX IF NOT EXISTS idx_usage_bundle ON app_usage(bundle_identifier);

        CREATE TABLE IF NOT EXISTS categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            icon TEXT NOT NULL DEFAULT 'folder.fill'
        );

        CREATE TABLE IF NOT EXISTS category_apps (
            category_id INTEGER NOT NULL,
            bundle_identifier TEXT NOT NULL,
            PRIMARY KEY(category_id, bundle_identifier),
            FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE CASCADE
        );
        """
        if sqlite3_exec(db, sql, nil, nil, nil) != SQLITE_OK {
            print("❌ Create tables: \(errorMessage)")
        }
        sqlite3_exec(db, "PRAGMA foreign_keys = ON;", nil, nil, nil)
    }

    private var errorMessage: String {
        String(cString: sqlite3_errmsg(db))
    }

    // MARK: - Record Usage

    func recordUsage(bundleIdentifier: String, appName: String, seconds: Int64 = 1) {
        // Skip system apps
        guard !SystemAppFilter.shouldHide(bundleIdentifier) else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())

        let sql = """
        INSERT INTO app_usage (bundle_identifier, app_name, total_seconds, date)
        VALUES (?, ?, ?, ?)
        ON CONFLICT(bundle_identifier, date) DO UPDATE SET
            total_seconds = total_seconds + excluded.total_seconds,
            app_name = excluded.app_name;
        """

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return }
        defer { sqlite3_finalize(stmt) }

        bindText(stmt, 1, bundleIdentifier)
        bindText(stmt, 2, appName)
        sqlite3_bind_int64(stmt, 3, seconds)
        bindText(stmt, 4, today)

        if sqlite3_step(stmt) != SQLITE_DONE {
            print("❌ Record usage: \(errorMessage)")
        }
    }

    // MARK: - Queries

    func usageForDate(_ date: String) -> [AppUsageRecord] {
        let sql = """
        SELECT bundle_identifier, app_name, total_seconds, date
        FROM app_usage WHERE date = ? ORDER BY total_seconds DESC;
        """
        return query(sql: sql, params: [date])
    }

    func usageForPeriod(from startDate: String, to endDate: String) -> [AppUsageRecord] {
        let sql = """
        SELECT bundle_identifier, app_name, SUM(total_seconds) as total_seconds, ? as date
        FROM app_usage WHERE date BETWEEN ? AND ?
        GROUP BY bundle_identifier ORDER BY total_seconds DESC;
        """
        return query(sql: sql, params: [startDate, startDate, endDate])
    }

    func allTimeUsage() -> [AppUsageRecord] {
        let sql = """
        SELECT bundle_identifier, app_name, SUM(total_seconds) as total_seconds, '' as date
        FROM app_usage GROUP BY bundle_identifier ORDER BY total_seconds DESC;
        """
        return query(sql: sql, params: [])
    }

    // MARK: - Categories

    @discardableResult
    func createCategory(name: String, icon: String = "folder.fill") -> Int64 {
        let sql = "INSERT INTO categories (name, icon) VALUES (?, ?);"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return -1 }
        defer { sqlite3_finalize(stmt) }
        bindText(stmt, 1, name)
        bindText(stmt, 2, icon)
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("❌ Create category: \(errorMessage)")
            return -1
        }
        return sqlite3_last_insert_rowid(db)
    }

    func updateCategory(id: Int64, name: String, icon: String) {
        let sql = "UPDATE categories SET name = ?, icon = ? WHERE id = ?;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return }
        defer { sqlite3_finalize(stmt) }
        bindText(stmt, 1, name)
        bindText(stmt, 2, icon)
        sqlite3_bind_int64(stmt, 3, id)
        sqlite3_step(stmt)
    }

    func deleteCategory(id: Int64) {
        let sql1 = "DELETE FROM category_apps WHERE category_id = ?;"
        var stmt1: OpaquePointer?
        if sqlite3_prepare_v2(db, sql1, -1, &stmt1, nil) == SQLITE_OK {
            sqlite3_bind_int64(stmt1, 1, id)
            sqlite3_step(stmt1)
        }
        sqlite3_finalize(stmt1)

        let sql2 = "DELETE FROM categories WHERE id = ?;"
        var stmt2: OpaquePointer?
        if sqlite3_prepare_v2(db, sql2, -1, &stmt2, nil) == SQLITE_OK {
            sqlite3_bind_int64(stmt2, 1, id)
            sqlite3_step(stmt2)
        }
        sqlite3_finalize(stmt2)
    }

    func addAppToCategory(categoryId: Int64, bundleIdentifier: String) {
        let sql = "INSERT OR IGNORE INTO category_apps (category_id, bundle_identifier) VALUES (?, ?);"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return }
        defer { sqlite3_finalize(stmt) }
        sqlite3_bind_int64(stmt, 1, categoryId)
        bindText(stmt, 2, bundleIdentifier)
        sqlite3_step(stmt)
    }

    func removeAppFromCategory(categoryId: Int64, bundleIdentifier: String) {
        let sql = "DELETE FROM category_apps WHERE category_id = ? AND bundle_identifier = ?;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return }
        defer { sqlite3_finalize(stmt) }
        sqlite3_bind_int64(stmt, 1, categoryId)
        bindText(stmt, 2, bundleIdentifier)
        sqlite3_step(stmt)
    }

    func getAllCategories() -> [AppCategory] {
        var categories: [AppCategory] = []
        let sql = "SELECT id, name, icon FROM categories ORDER BY name;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return categories }
        defer { sqlite3_finalize(stmt) }

        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = sqlite3_column_int64(stmt, 0)
            let name = columnText(stmt, 1)
            let icon = columnText(stmt, 2)
            let bundleIds = getBundleIdsForCategory(id)
            categories.append(AppCategory(id: id, name: name, icon: icon, bundleIdentifiers: bundleIds))
        }
        return categories
    }

    private func getBundleIdsForCategory(_ categoryId: Int64) -> [String] {
        var ids: [String] = []
        let sql = "SELECT bundle_identifier FROM category_apps WHERE category_id = ?;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return ids }
        defer { sqlite3_finalize(stmt) }
        sqlite3_bind_int64(stmt, 1, categoryId)
        while sqlite3_step(stmt) == SQLITE_ROW {
            ids.append(columnText(stmt, 0))
        }
        return ids
    }

    func categoryUsage(categoryId: Int64) -> [AppUsageRecord] {
        let bundleIds = getBundleIdsForCategory(categoryId)
        guard !bundleIds.isEmpty else { return [] }
        let placeholders = bundleIds.map { _ in "?" }.joined(separator: ",")
        let sql = """
        SELECT bundle_identifier, app_name, SUM(total_seconds) as total_seconds, '' as date
        FROM app_usage WHERE bundle_identifier IN (\(placeholders))
        GROUP BY bundle_identifier ORDER BY total_seconds DESC;
        """
        var results: [AppUsageRecord] = []
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return results }
        defer { sqlite3_finalize(stmt) }
        for (i, bid) in bundleIds.enumerated() {
            bindText(stmt, Int32(i + 1), bid)
        }
        while sqlite3_step(stmt) == SQLITE_ROW {
            results.append(AppUsageRecord(
                bundleIdentifier: columnText(stmt, 0),
                appName: columnText(stmt, 1),
                totalSeconds: sqlite3_column_int64(stmt, 2),
                date: columnText(stmt, 3)
            ))
        }
        return results
    }

    // MARK: - Helpers

    private func query(sql: String, params: [String]) -> [AppUsageRecord] {
        var results: [AppUsageRecord] = []
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            print("❌ Query: \(errorMessage)")
            return results
        }
        defer { sqlite3_finalize(stmt) }

        for (i, param) in params.enumerated() {
            bindText(stmt, Int32(i + 1), param)
        }

        while sqlite3_step(stmt) == SQLITE_ROW {
            let bundleId = columnText(stmt, 0)
            let appName = columnText(stmt, 1)
            let totalSeconds = sqlite3_column_int64(stmt, 2)
            let date = columnText(stmt, 3)

            results.append(AppUsageRecord(
                bundleIdentifier: bundleId,
                appName: appName,
                totalSeconds: totalSeconds,
                date: date
            ))
        }
        return results
    }

    private func bindText(_ stmt: OpaquePointer?, _ index: Int32, _ value: String) {
        value.withCString { ptr in
            _ = sqlite3_bind_text(stmt, index, ptr, -1, sqliteTransient)
        }
    }

    private func columnText(_ stmt: OpaquePointer?, _ index: Int32) -> String {
        sqlite3_column_text(stmt, index).map { String(cString: $0) } ?? ""
    }
}
