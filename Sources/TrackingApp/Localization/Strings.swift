import Foundation

struct Strings {
    let language: String

    // MARK: - Helper

    private func t(_ en: String, _ ua: String, _ pl: String) -> String {
        switch language {
        case "en": return en
        case "pl": return pl
        default: return ua
        }
    }

    // MARK: - Sidebar

    var running: String { t("Running", "Запущені", "Uruchomione") }
    var statistics: String { t("Statistics", "Статистика", "Statystyki") }
    var settings: String { t("Settings", "Налаштування", "Ustawienia") }
    var selectSection: String { t("Select a section", "Оберіть розділ", "Wybierz sekcję") }

    // MARK: - Running Apps

    var runningAppsTitle: String { t("Running Apps", "Запущені додатки", "Uruchomione aplikacje") }
    func appsCount(_ n: Int) -> String { t("\(n) apps", "\(n) додатків", "\(n) aplikacji") }
    var active: String { t("ACTIVE", "АКТИВНИЙ", "AKTYWNY") }

    // MARK: - Statistics

    var statisticsTitle: String { t("Statistics", "Статистика", "Statystyki") }
    var today: String { t("Today", "Сьогодні", "Dziś") }
    var week: String { t("Week", "Тиждень", "Tydzień") }
    var month: String { t("Month", "Місяць", "Miesiąc") }
    var allTime: String { t("All time", "Весь час", "Cały czas") }
    var dateLabel: String { t("Date:", "Дата:", "Data:") }
    var noDataTitle: String { t("No data for selected period", "Немає даних за обраний період", "Brak danych za wybrany okres") }
    var noDataSubtitle: String { t("The app collects usage statistics automatically", "Додаток збирає статистику використання автоматично", "Aplikacja zbiera statystyki użytkowania automatycznie") }
    var totalTime: String { t("Total time:", "Загальний час:", "Łączny czas:") }
    func trackedApps(_ n: Int) -> String { t("\(n) apps", "\(n) додатків", "\(n) aplikacji") }

    // MARK: - Settings

    var settingsTitle: String { t("Settings", "Налаштування", "Ustawienia") }
    var appearance: String { t("Appearance", "Зовнішній вигляд", "Wygląd") }
    var themeLabel: String { t("Theme", "Тема", "Motyw") }
    var themeSystem: String { t("System", "Системна", "Systemowy") }
    var themeLight: String { t("Light", "Світла", "Jasny") }
    var themeDark: String { t("Dark", "Темна", "Ciemny") }
    var general: String { t("General", "Загальне", "Ogólne") }
    var launchAtLogin: String { t("Launch at login", "Запуск з системою", "Uruchom przy logowaniu") }
    var languageLabel: String { t("Language", "Мова", "Język") }
    var exportSection: String { t("Export", "Експорт", "Eksport") }
    var exportCSV: String { t("Export to CSV", "Експорт у CSV", "Eksportuj do CSV") }
    var saveDatabase: String { t("Save database", "Зберегти базу даних", "Zapisz bazę danych") }
    var exportSuccess: String { t("Exported successfully", "Експортовано успішно", "Wyeksportowano pomyślnie") }
    var close: String { t("Close", "Закрити", "Zamknij") }

    // MARK: - Library

    var library: String { t("Library", "Бібліотека", "Biblioteka") }
    var libraryTitle: String { t("App Library", "Бібліотека додатків", "Biblioteka aplikacji") }
    var launch: String { t("Launch", "Запустити", "Uruchom") }
    var search: String { t("Search…", "Пошук…", "Szukaj…") }
    var sortBy: String { t("Sort", "Сортування", "Sortuj") }
    var sortMostTime: String { t("Most time", "Найбільше часу", "Najwięcej czasu") }
    var sortLeastTime: String { t("Least time", "Найменше часу", "Najmniej czasu") }
    var sortByName: String { t("By name", "За назвою", "Według nazwy") }
    var emptyLibrary: String { t("Library is empty", "Бібліотека порожня", "Biblioteka jest pusta") }
    var emptyLibrarySubtitle: String { t("Apps will appear here as you use them", "Додатки з'являться тут у процесі використання", "Aplikacje pojawią się tutaj w trakcie użytkowania") }

    // MARK: - Categories

    var categories: String { t("Categories", "Категорії", "Kategorie") }
    var newCategory: String { t("New Category", "Нова категорія", "Nowa kategoria") }
    var categoryName: String { t("Category name", "Назва категорії", "Nazwa kategorii") }
    var categoryIcon: String { t("Icon", "Іконка", "Ikona") }
    var addApps: String { t("Add Apps", "Додати додатки", "Dodaj aplikacje") }
    var removeFromCategory: String { t("Remove", "Видалити", "Usuń") }
    var editCategory: String { t("Edit", "Редагувати", "Edytuj") }
    var deleteCategory: String { t("Delete", "Видалити", "Usuń") }
    var cancel: String { t("Cancel", "Скасувати", "Anuluj") }
    var save: String { t("Save", "Зберегти", "Zapisz") }
    var create: String { t("Create", "Створити", "Utwórz") }
    var emptyCategoryTitle: String { t("No apps in this category", "Немає додатків у цій категорії", "Brak aplikacji w tej kategorii") }
    var emptyCategorySubtitle: String { t("Add apps using the button above", "Додайте додатки кнопкою вище", "Dodaj aplikacje przyciskiem powyżej") }
    var deleteCategoryConfirm: String { t("Delete this category?", "Видалити цю категорію?", "Usunąć tę kategorię?") }
    var totalTimeSpent: String { t("Total time spent", "Загальний час використання", "Łączny czas użytkowania") }

    // MARK: - Firebase

    var firebaseSection: String { t("Firebase", "Firebase", "Firebase") }
    var firebaseEnabled: String { t("Enable Firebase sync", "Увімкнути синхронізацію Firebase", "Włącz synchronizację Firebase") }
    var firebaseProjectId: String { t("Project ID", "ID проєкту", "ID projektu") }
    var firebaseApiKey: String { t("API Key (optional)", "API ключ (необов'язково)", "Klucz API (opcjonalnie)") }
    var firebaseCollection: String { t("Collection name", "Назва колекції", "Nazwa kolekcji") }
    var firebaseSyncNow: String { t("Sync now", "Синхронізувати зараз", "Synchronizuj teraz") }
    var firebaseSyncing: String { t("Syncing…", "Синхронізація…", "Synchronizacja…") }
    func firebaseSyncSuccess(_ n: Int) -> String { t("\(n) apps synced", "\(n) додатків синхронізовано", "\(n) aplikacji zsynchronizowanych") }
    var firebaseSyncError: String { t("Sync failed", "Помилка синхронізації", "Błąd synchronizacji") }
    var firebaseHint: String { t("Data will be sent to Firestore for display on your website", "Дані будуть надіслані до Firestore для відображення на сайті", "Dane zostaną wysłane do Firestore w celu wyświetlenia na stronie") }

    // MARK: - Time Formatting

    func formatTime(_ totalSeconds: Int64) -> String {
        let h = totalSeconds / 3600
        let m = (totalSeconds % 3600) / 60
        let s = totalSeconds % 60
        switch language {
        case "en":
            if h > 0 { return String(format: "%dh %02dm %02ds", h, m, s) }
            else if m > 0 { return String(format: "%dm %02ds", m, s) }
            else { return String(format: "%ds", s) }
        case "pl":
            if h > 0 { return String(format: "%dg %02dmin %02ds", h, m, s) }
            else if m > 0 { return String(format: "%dmin %02ds", m, s) }
            else { return String(format: "%ds", s) }
        default:
            if h > 0 { return String(format: "%dг %02dхв %02dс", h, m, s) }
            else if m > 0 { return String(format: "%dхв %02dс", m, s) }
            else { return String(format: "%dс", s) }
        }
    }

    func formatTimeShort(_ totalSeconds: Int64) -> String {
        let h = totalSeconds / 3600
        let m = (totalSeconds % 3600) / 60
        let s = totalSeconds % 60
        switch language {
        case "en":
            if h > 0 { return String(format: "%dh %02dm", h, m) }
            else if m > 0 { return String(format: "%dm %02ds", m, s) }
            else { return String(format: "%ds", s) }
        case "pl":
            if h > 0 { return String(format: "%dg %02dmin", h, m) }
            else if m > 0 { return String(format: "%dmin %02ds", m, s) }
            else { return String(format: "%ds", s) }
        default:
            if h > 0 { return String(format: "%dг %02dхв", h, m) }
            else if m > 0 { return String(format: "%dхв %02dс", m, s) }
            else { return String(format: "%dс", s) }
        }
    }

    func formatUptime(_ date: Date?) -> String {
        guard let launch = date else { return "—" }
        let interval = Int(Date().timeIntervalSince(launch))
        return formatTimeShort(Int64(interval))
    }
}
