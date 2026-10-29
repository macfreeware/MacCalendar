import Foundation
import Combine
import ServiceManagement

public struct WorldCityPreset: Identifiable, Equatable, Hashable {
    public var id: String { timeZoneID }
    public let name: String
    public let shortCode: String
    public let flag: String
    public let timeZoneID: String
}

public enum MenuBarDateFormat: String, CaseIterable, Identifiable {
    case dayMonthWeekday = "d_mmm_eee"
    case numeric = "dd_mm_yyyy"
    case dayMonth = "d_mmmm"
    case hidden = "hidden"

    public var id: String { rawValue }

    public func title(lang: AppLanguage) -> String {
        let isTr = lang.resolvedIsTurkish
        switch self {
        case .dayMonthWeekday: return isTr ? "29 Eki Per" : "29 Oct Thu"
        case .numeric: return "29.10.2026"
        case .dayMonth: return isTr ? "29 Ekim" : "29 October"
        case .hidden: return isTr ? "Sadece Saat" : "Time Only"
        }
    }

    @MainActor
    public var title: String {
        title(lang: AppSettings.shared.appLanguage)
    }
}

public enum MenuBarClockBadgeStyle: String, CaseIterable, Identifiable {
    case bothFlags = "both_flags"          // 29 Eki Per  🇹🇷 18:45   🇯🇵 00:45
    case timeThenFlag = "time_then_flag"   // 29 Eki Per  18:45 🇹🇷   00:45 🇯🇵
    case flagsInMiddle = "flags_middle"    // 29 Eki Per  18:45 🇹🇷 🇯🇵 00:45
    case secondFlagOnly = "second_flag"    // 29 Eki Per  18:45   🇯🇵 00:45
    case flagAndCode = "flag_and_code"     // 29 Eki Per  🇹🇷 18:45   🇯🇵 TYO 00:45

    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .bothFlags: return "🇹🇷 18:45   🇯🇵 00:45"
        case .timeThenFlag: return "18:45 🇹🇷   00:45 🇯🇵"
        case .flagsInMiddle: return "18:45 🇹🇷 🇯🇵 00:45"
        case .secondFlagOnly: return "18:45   🇯🇵 00:45"
        case .flagAndCode: return "🇹🇷 18:45   🇯🇵 TYO 00:45"
        }
    }
}

@MainActor
public final class AppSettings: ObservableObject {
    public static let shared = AppSettings()

    public static let presets: [WorldCityPreset] = [
        WorldCityPreset(name: "Tokyo", shortCode: "TYO", flag: "🇯🇵", timeZoneID: "Asia/Tokyo"),
        WorldCityPreset(name: "Londra", shortCode: "LON", flag: "🇬🇧", timeZoneID: "Europe/London"),
        WorldCityPreset(name: "New York", shortCode: "NYC", flag: "🇺🇸", timeZoneID: "America/New_York"),
        WorldCityPreset(name: "Berlin", shortCode: "BER", flag: "🇩🇪", timeZoneID: "Europe/Berlin"),
        WorldCityPreset(name: "Paris", shortCode: "PAR", flag: "🇫🇷", timeZoneID: "Europe/Paris"),
        WorldCityPreset(name: "Seul", shortCode: "SEL", flag: "🇰🇷", timeZoneID: "Asia/Seoul"),
        WorldCityPreset(name: "Dubai", shortCode: "DXB", flag: "🇦🇪", timeZoneID: "Asia/Dubai"),
        WorldCityPreset(name: "Singapur", shortCode: "SIN", flag: "🇸🇬", timeZoneID: "Asia/Singapore"),
        WorldCityPreset(name: "Los Angeles", shortCode: "LAX", flag: "🇺🇸", timeZoneID: "America/Los_Angeles"),
        WorldCityPreset(name: "Pekin / Şanghay", shortCode: "SHA", flag: "🇨🇳", timeZoneID: "Asia/Shanghai"),
        WorldCityPreset(name: "Sydney", shortCode: "SYD", flag: "🇦🇺", timeZoneID: "Australia/Sydney"),
        WorldCityPreset(name: "Moskova", shortCode: "MOW", flag: "🇷🇺", timeZoneID: "Europe/Moscow"),
        WorldCityPreset(name: "Bakü", shortCode: "BAK", flag: "🇦🇿", timeZoneID: "Asia/Baku"),
        WorldCityPreset(name: "İstanbul", shortCode: "IST", flag: "🇹🇷", timeZoneID: "Europe/Istanbul"),
        WorldCityPreset(name: "Amsterdam", shortCode: "AMS", flag: "🇳🇱", timeZoneID: "Europe/Amsterdam"),
        WorldCityPreset(name: "Roma", shortCode: "ROM", flag: "🇮🇹", timeZoneID: "Europe/Rome"),
        WorldCityPreset(name: "Madrid", shortCode: "MAD", flag: "🇪🇸", timeZoneID: "Europe/Madrid"),
        WorldCityPreset(name: "Viyana", shortCode: "VIE", flag: "🇦🇹", timeZoneID: "Europe/Vienna"),
        WorldCityPreset(name: "Zürih", shortCode: "ZRH", flag: "🇨🇭", timeZoneID: "Europe/Zurich"),
        WorldCityPreset(name: "Toronto", shortCode: "TOR", flag: "🇨🇦", timeZoneID: "America/Toronto"),
        WorldCityPreset(name: "UTC / GMT", shortCode: "UTC", flag: "🌐", timeZoneID: "UTC")
    ]

    private static let timeZoneFlagMap: [String: String] = [
        "Europe/Istanbul": "🇹🇷", "Asia/Istanbul": "🇹🇷",
        "Asia/Tokyo": "🇯🇵",
        "Europe/London": "🇬🇧",
        "America/New_York": "🇺🇸", "America/Los_Angeles": "🇺🇸", "America/Chicago": "🇺🇸", "America/Denver": "🇺🇸", "America/Phoenix": "🇺🇸", "Pacific/Honolulu": "🇺🇸",
        "Europe/Berlin": "🇩🇪", "Europe/Busingen": "🇩🇪",
        "Europe/Paris": "🇫🇷",
        "Asia/Seoul": "🇰🇷",
        "Asia/Dubai": "🇦🇪",
        "Asia/Singapore": "🇸🇬",
        "Asia/Shanghai": "🇨🇳", "Asia/Urumqi": "🇨🇳", "Asia/Hong_Kong": "🇭🇰", "Asia/Taipei": "🇹🇼",
        "Australia/Sydney": "🇦🇺", "Australia/Melbourne": "🇦🇺", "Australia/Perth": "🇦🇺", "Australia/Brisbane": "🇦🇺",
        "Europe/Moscow": "🇷🇺", "Europe/Kaliningrad": "🇷🇺", "Asia/Yekaterinburg": "🇷🇺", "Asia/Novosibirsk": "🇷🇺", "Asia/Vladivostok": "🇷🇺",
        "Asia/Baku": "🇦🇿",
        "Europe/Amsterdam": "🇳🇱",
        "Europe/Brussels": "🇧🇪",
        "Europe/Rome": "🇮🇹",
        "Europe/Madrid": "🇪🇸", "Atlantic/Canary": "🇪🇸",
        "Europe/Lisbon": "🇵🇹",
        "Europe/Vienna": "🇦🇹",
        "Europe/Zurich": "🇨🇭",
        "Europe/Stockholm": "🇸🇪",
        "Europe/Oslo": "🇳🇴",
        "Europe/Copenhagen": "🇩🇰",
        "Europe/Helsinki": "🇫🇮",
        "Europe/Warsaw": "🇵🇱",
        "Europe/Prague": "🇨🇿",
        "Europe/Budapest": "🇭🇺",
        "Europe/Athens": "🇬🇷",
        "Europe/Bucharest": "🇷🇴",
        "Europe/Sofia": "🇧🇬",
        "Europe/Kyiv": "🇺🇦", "Europe/Kiev": "🇺🇦",
        "Europe/Dublin": "🇮🇪",
        "America/Toronto": "🇨🇦", "America/Vancouver": "🇨🇦", "America/Montreal": "🇨🇦", "America/Edmonton": "🇨🇦",
        "America/Mexico_City": "🇲🇽",
        "America/Sao_Paulo": "🇧🇷",
        "America/Argentina/Buenos_Aires": "🇦🇷", "America/Buenos_Aires": "🇦🇷",
        "America/Santiago": "🇨🇱",
        "America/Bogota": "🇨🇴",
        "Asia/Almaty": "🇰🇿", "Asia/Qyzylorda": "🇰🇿",
        "Asia/Tashkent": "🇺🇿", "Asia/Samarkand": "🇺🇿",
        "Asia/Bishkek": "🇰🇬",
        "Asia/Ashgabat": "🇹🇲",
        "Asia/Tbilisi": "🇬🇪",
        "Asia/Tehran": "🇮🇷",
        "Asia/Baghdad": "🇮🇶",
        "Asia/Riyadh": "🇸🇦",
        "Asia/Qatar": "🇶🇦",
        "Asia/Kuwait": "🇰🇼",
        "Asia/Jerusalem": "🇮🇱",
        "Asia/Beirut": "🇱🇧",
        "Asia/Amman": "🇯🇴",
        "Africa/Cairo": "🇪🇬",
        "Africa/Johannesburg": "🇿🇦",
        "Africa/Casablanca": "🇲🇦",
        "Africa/Lagos": "🇳🇬",
        "Asia/Kolkata": "🇮🇳", "Asia/Calcutta": "🇮🇳",
        "Asia/Karachi": "🇵🇰",
        "Asia/Dhaka": "🇧🇩",
        "Asia/Bangkok": "🇹🇭",
        "Asia/Jakarta": "🇮🇩",
        "Asia/Manila": "🇵🇭",
        "Asia/Kuala_Lumpur": "🇲🇾",
        "Asia/Ho_Chi_Minh": "🇻🇳", "Asia/Saigon": "🇻🇳",
        "Pacific/Auckland": "🇳🇿",
        "Europe/Nicosia": "🇨🇾", "Asia/Nicosia": "🇨🇾"
    ]

    public static func flag(forTimeZoneID tzID: String) -> String {
        if let mapped = timeZoneFlagMap[tzID] {
            return mapped
        }
        if let preset = presets.first(where: { $0.timeZoneID == tzID }) {
            return preset.flag
        }
        return "🌍"
    }

    public static func isoCountryCodeToFlag(_ countryCode: String) -> String? {
        let upper = countryCode.uppercased()
        guard upper.count == 2 else { return nil }
        let base: UInt32 = 127397
        var scalars = String.UnicodeScalarView()
        for scalar in upper.unicodeScalars {
            guard scalar.value >= 65 && scalar.value <= 90,
                  let flagScalar = UnicodeScalar(base + scalar.value) else {
                return nil
            }
            scalars.append(flagScalar)
        }
        return String(scalars)
    }

    /// Sistemdeki tüm saat dilimlerinin ülke bayraklarıyla eşleştirilmiş listesi
    public static let allSystemTimeZones: [WorldCityPreset] = {
        TimeZone.knownTimeZoneIdentifiers.sorted().map { tzID in
            if let existing = presets.first(where: { $0.timeZoneID == tzID }) {
                return existing
            }
            let parts = tzID.split(separator: "/")
            let cityRaw = String(parts.last ?? Substring(tzID)).replacingOccurrences(of: "_", with: " ")
            let regionRaw = parts.count > 1 ? String(parts.first!) : ""
            let display = regionRaw.isEmpty ? cityRaw : "\(cityRaw) (\(regionRaw))"
            let cleanLetters = cityRaw.uppercased().filter { $0.isLetter }
            let code = String(cleanLetters.prefix(3)).isEmpty ? "2.S" : String(cleanLetters.prefix(3))
            let resolvedFlag = flag(forTimeZoneID: tzID)
            return WorldCityPreset(name: display, shortCode: code, flag: resolvedFlag, timeZoneID: tzID)
        }
    }()

    @Published public var showSecondClock: Bool {
        didSet { UserDefaults.standard.set(showSecondClock, forKey: "showSecondClock") }
    }

    @Published public var secondClockTimeZoneID: String {
        didSet { UserDefaults.standard.set(secondClockTimeZoneID, forKey: "secondClockTimeZoneID") }
    }

    @Published public var secondClockCustomLabel: String {
        didSet { UserDefaults.standard.set(secondClockCustomLabel, forKey: "secondClockCustomLabel") }
    }

    @Published public var menuBarDateFormat: MenuBarDateFormat {
        didSet { UserDefaults.standard.set(menuBarDateFormat.rawValue, forKey: "menuBarDateFormat") }
    }

    @Published public var menuBarClockBadgeStyle: MenuBarClockBadgeStyle {
        didSet { UserDefaults.standard.set(menuBarClockBadgeStyle.rawValue, forKey: "menuBarClockBadgeStyle") }
    }

    @Published public var showSecondsInMenuBar: Bool {
        didSet { UserDefaults.standard.set(showSecondsInMenuBar, forKey: "showSecondsInMenuBar") }
    }

    @Published public var startWeekOnMonday: Bool {
        didSet { UserDefaults.standard.set(startWeekOnMonday, forKey: "startWeekOnMonday") }
    }

    @Published public var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin")
            updateLaunchAtLoginRegistration()
        }
    }

    @Published public var appLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(appLanguage.rawValue, forKey: "appLanguage")
        }
    }

    @Published public var dayNotes: [String: [String]] {
        didSet {
            if let data = try? JSONEncoder().encode(dayNotes) {
                UserDefaults.standard.set(data, forKey: "dayNotes")
            }
        }
    }

    private init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "showSecondClock") == nil {
            self.showSecondClock = true
        } else {
            self.showSecondClock = defaults.bool(forKey: "showSecondClock")
        }

        self.secondClockTimeZoneID = defaults.string(forKey: "secondClockTimeZoneID") ?? "Asia/Tokyo"
        self.secondClockCustomLabel = defaults.string(forKey: "secondClockCustomLabel") ?? ""

        if let rawFormat = defaults.string(forKey: "menuBarDateFormat"),
           let fmt = MenuBarDateFormat(rawValue: rawFormat) {
            self.menuBarDateFormat = fmt
        } else {
            self.menuBarDateFormat = .dayMonthWeekday
        }

        if let rawBadge = defaults.string(forKey: "menuBarClockBadgeStyle"),
           let badge = MenuBarClockBadgeStyle(rawValue: rawBadge) {
            self.menuBarClockBadgeStyle = badge
        } else {
            self.menuBarClockBadgeStyle = .bothFlags
        }

        self.showSecondsInMenuBar = defaults.bool(forKey: "showSecondsInMenuBar")

        if defaults.object(forKey: "startWeekOnMonday") == nil {
            self.startWeekOnMonday = true
        } else {
            self.startWeekOnMonday = defaults.bool(forKey: "startWeekOnMonday")
        }

        // Varsayılan: Mac açıldığında otomatik başlat. Uygulama İndirilenler'den taşınmadan açıldıysa macOS onu
        // geçici bir konumdan (App Translocation) çalıştırır; o yol oturum açılış öğesi olarak kaydedilmez,
        // varsayılan uygulama kalıcı yerinden (örn. Uygulamalar) ilk açıldığında uygulanır.
        let isTranslocated = Bundle.main.bundlePath.contains("/AppTranslocation/")
        let applyLoginDefault = defaults.object(forKey: "launchAtLogin") == nil && !isTranslocated
        if applyLoginDefault {
            self.launchAtLogin = true
        } else if defaults.object(forKey: "launchAtLogin") == nil {
            self.launchAtLogin = (SMAppService.mainApp.status == .enabled)
        } else {
            self.launchAtLogin = defaults.bool(forKey: "launchAtLogin")
        }

        if let rawLang = defaults.string(forKey: "appLanguage"),
           let lang = AppLanguage(rawValue: rawLang) {
            self.appLanguage = lang
        } else {
            self.appLanguage = .system
        }

        if let data = defaults.data(forKey: "dayNotes"),
           let decoded = try? JSONDecoder().decode([String: [String]].self, from: data) {
            self.dayNotes = decoded
        } else {
            self.dayNotes = [:]
        }

        // init içinde didSet çalışmadığından varsayılan açık ayar burada kaydedilir ve uygulanır
        if applyLoginDefault {
            defaults.set(true, forKey: "launchAtLogin")
            updateLaunchAtLoginRegistration()
        }
    }

    public var effectiveLocale: Locale {
        appLanguage.locale
    }

    public func tr(_ key: L10n.Key) -> String {
        L10n.string(key, lang: appLanguage)
    }

    /// Yerel ülkenin bayrağını saat diliminden veya macOS bölge ayarından otomatik bulur
    public var localFlag: String {
        let localTZ = TimeZone.current.identifier
        let tzFlag = Self.flag(forTimeZoneID: localTZ)
        if tzFlag != "🌍" {
            return tzFlag
        }
        if let regionCode = Locale.current.region?.identifier,
           let flag = Self.isoCountryCodeToFlag(regionCode) {
            return flag
        }
        return "🇹🇷"
    }

    public var currentPreset: WorldCityPreset? {
        if let p = Self.presets.first(where: { $0.timeZoneID == secondClockTimeZoneID }) {
            return p
        }
        return Self.allSystemTimeZones.first(where: { $0.timeZoneID == secondClockTimeZoneID })
    }

    public var secondClockFlag: String {
        if let preset = currentPreset {
            return preset.flag
        }
        return Self.flag(forTimeZoneID: secondClockTimeZoneID)
    }

    public var activePresetsWithSelection: [WorldCityPreset] {
        if Self.presets.contains(where: { $0.timeZoneID == secondClockTimeZoneID }) {
            return Self.presets
        }
        if let custom = currentPreset {
            return [custom] + Self.presets
        }
        return Self.presets
    }

    public var secondClockShortLabel: String {
        let trimmed = secondClockCustomLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            return trimmed
        }
        if let preset = currentPreset {
            return preset.shortCode
        }
        let parts = secondClockTimeZoneID.split(separator: "/")
        return String(parts.last ?? Substring(secondClockTimeZoneID)).replacingOccurrences(of: "_", with: " ")
    }

    public var secondClockCityOnlyName: String {
        let trimmed = secondClockCustomLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            return trimmed
        }
        if let preset = currentPreset {
            return preset.name
        }
        let parts = secondClockTimeZoneID.split(separator: "/")
        return String(parts.last ?? Substring(secondClockTimeZoneID)).replacingOccurrences(of: "_", with: " ")
    }

    public var secondClockFullDisplayName: String {
        let trimmed = secondClockCustomLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            return "\(secondClockFlag) \(trimmed)"
        }
        if let preset = currentPreset {
            return "\(preset.flag) \(preset.name)"
        }
        let parts = secondClockTimeZoneID.split(separator: "/")
        let city = String(parts.last ?? Substring(secondClockTimeZoneID)).replacingOccurrences(of: "_", with: " ")
        return "\(secondClockFlag) \(city)"
    }

    public var secondTimeZone: TimeZone {
        TimeZone(identifier: secondClockTimeZoneID) ?? TimeZone(identifier: "Asia/Tokyo") ?? .current
    }

    public func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    public func notes(for date: Date) -> [String] {
        dayNotes[dateKey(for: date)] ?? []
    }

    public func addNote(_ text: String, for date: Date) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let key = dateKey(for: date)
        var list = dayNotes[key] ?? []
        list.append(trimmed)
        dayNotes[key] = list
    }

    public func removeNote(at index: Int, for date: Date) {
        let key = dateKey(for: date)
        guard var list = dayNotes[key], list.indices.contains(index) else { return }
        list.remove(at: index)
        if list.isEmpty {
            dayNotes.removeValue(forKey: key)
        } else {
            dayNotes[key] = list
        }
    }

    public func updateLaunchAtLoginRegistration() {
        if #available(macOS 13.0, *) {
            do {
                if launchAtLogin {
                    if SMAppService.mainApp.status != .enabled {
                        try SMAppService.mainApp.register()
                    }
                } else {
                    if SMAppService.mainApp.status == .enabled {
                        try SMAppService.mainApp.unregister()
                    }
                }
            } catch {
                // Paket dışından veya izin kısıtlı ortamdan çalıştırıldığında sessizce geç
            }
        }
    }
}
