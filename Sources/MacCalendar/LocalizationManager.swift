import Foundation

public enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case turkish = "tr"
    case english = "en"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .system: return "🌐 Sistem Dili / System"
        case .turkish: return "🇹🇷 Türkçe"
        case .english: return "🇬🇧 English"
        }
    }

    public var locale: Locale {
        switch self {
        case .system:
            return Locale.autoupdatingCurrent
        case .turkish:
            return Locale(identifier: "tr_TR")
        case .english:
            return Locale(identifier: "en_US")
        }
    }

    public var resolvedIsTurkish: Bool {
        switch self {
        case .turkish:
            return true
        case .english:
            return false
        case .system:
            let lang = Locale.autoupdatingCurrent.language.languageCode?.identifier ?? "en"
            return lang.lowercased().hasPrefix("tr")
        }
    }
}

public struct L10n {
    public static func string(_ key: Key, lang: AppLanguage) -> String {
        let isTr = lang.resolvedIsTurkish
        return isTr ? key.tr : key.en
    }

    public enum Key {
        case settings
        case about
        case today
        case secondClock(String)
        case onlyLocal
        case localTime
        case addNotePlaceholder
        case notesCount(Int)
        case clickToSelectMonthYear
        case previousYear
        case nextYear
        case previousMonth
        case nextMonth
        case clickToGoToToday
        case searchWorldCityTitle
        case searchCityPlaceholder
        case settingsTitle
        case showSecondClock
        case secondClockCity
        case notInList
        case searchAllCities
        case closeSearch
        case otherCitySearchAction
        case customLabel
        case customLabelPlaceholder
        case flagStyle
        case dateFormat
        case secondsInMenuBar
        case startMonday
        case launchAtLogin
        case appLanguage
        case aboutTitle
        case aboutSubtitle
        case developer
        case aboutDescription
        case copyright
        case quit
        case quitConfirmTitle
        case quitConfirmMessage
        case quitAction
        case cancel
        case gitlabRepo
        case sameTime
        case hoursDiff(String)
        case todayWithDash
        case localClockOnRight
        case checkForUpdates
        case checkingForUpdates
        case updateUpToDate
        case autoCheckUpdates
        case updateNow
        case updateLater
        case updateSkipVersion
        case openDownloadPage
        case updateInstallingTitle
        case updateFailedTitle
        case updateFailedDetail
        case updateErrorNotFound
        case updateErrorMissingFiles
        case updateErrorChecksumFile
        case updateErrorChecksum
        case updateErrorUnzip
        case updateErrorWrongApp
        case updateErrorSignature
        case updateAvailableTitle(String)
        case updateAvailableDetail(String)
        case updateManualDetail(String)
        case updateInstallingDetail(String)
        case updateErrorHTTP(Int)
        case updateErrorNotWritable(String)

        var tr: String {
            switch self {
            case .settings: return "Ayarlar"
            case .about: return "Hakkında"
            case .today: return "Bugün"
            case .secondClock(let label): return "2. Saat (\(label))"
            case .onlyLocal: return "Sadece Yerel"
            case .localTime: return "Yerel Saat"
            case .addNotePlaceholder: return "Seçili güne hızlı not ekle..."
            case .notesCount(let count): return "\(count) not"
            case .clickToSelectMonthYear: return "Ay ve yıl seçmek için tıklayın"
            case .previousYear: return "Önceki Yıl"
            case .nextYear: return "Sonraki Yıl"
            case .previousMonth: return "Önceki Ay"
            case .nextMonth: return "Sonraki Ay"
            case .clickToGoToToday: return "Bugüne gitmek için tıklayın"
            case .searchWorldCityTitle: return "Dünya Saat Dilimi Ara (400+ Şehir)"
            case .searchCityPlaceholder: return "Şehir veya bölge yazın (ör: Toronto, Amsterdam, Almaty)..."
            case .settingsTitle: return "Saat ve Takvim Ayarları"
            case .showSecondClock: return "İkinci Saati Göster (Menü Çubuğu & Takvim)"
            case .secondClockCity: return "2. Saat Şehri:"
            case .notInList: return "Listede Yok mu?"
            case .searchAllCities: return "Tüm Şehirlerde Ara..."
            case .closeSearch: return "Aramayı Kapat"
            case .otherCitySearchAction: return "Diğer Şehir / Saat Dilimi Ara..."
            case .customLabel: return "Özel Etiket (İsteğe Bağlı):"
            case .customLabelPlaceholder: return "Boş = Sadece Bayrak"
            case .flagStyle: return "Bayrak Stili:"
            case .dateFormat: return "Tarih Formatı:"
            case .secondsInMenuBar: return "Menü Çubuğunda Saniye"
            case .startMonday: return "Pazartesi Başla"
            case .launchAtLogin: return "Mac Açıldığında Otomatik Başlat"
            case .appLanguage: return "Uygulama Dili:"
            case .aboutTitle: return "MacCalendar"
            case .aboutSubtitle: return "macOS Menü Çubuğu Takvim & Dünya Saati"
            case .developer: return "Geliştirici: Rafet Sapancı"
            case .aboutDescription: return "macOS menü çubuğunda yerel ülke bayrağınızla birlikte tarih, saat ve seçtiğiniz ikinci dünya saatini aynı anda gösteren hızlı takvim ve not uygulaması."
            case .copyright: return "© 2026 Rafet Sapancı • Native Swift & SwiftUI"
            case .quit: return "Takvim Uygulamasını Kapat"
            case .quitConfirmTitle: return "Uygulamadan çıkılsın mı?"
            case .quitConfirmMessage: return "MacCalendar menü çubuğundan kaldırılacak ve kapatılacaktır."
            case .quitAction: return "Çıkış Yap"
            case .cancel: return "Vazgeç"
            case .gitlabRepo: return "GitLab Deposu"
            case .sameTime: return "Aynı saat"
            case .hoursDiff(let diff): return "\(diff) sa"
            case .todayWithDash: return "Bugün • "
            case .localClockOnRight: return "Yerel Saat En Sağda"
            case .checkForUpdates: return "Güncellemeleri Denetle…"
            case .checkingForUpdates: return "Denetleniyor…"
            case .updateUpToDate: return "MacCalendar güncel."
            case .autoCheckUpdates: return "Güncellemeleri Otomatik Denetle"
            case .updateNow: return "Şimdi Güncelle"
            case .updateLater: return "Sonra"
            case .updateSkipVersion: return "Bu Sürümü Atla"
            case .openDownloadPage: return "İndirme Sayfasını Aç"
            case .updateInstallingTitle: return "MacCalendar güncelleniyor"
            case .updateFailedTitle: return "Güncelleme kurulamadı."
            case .updateFailedDetail: return "İsterseniz yeni sürümü indirme sayfasından elle kurabilirsiniz."
            case .updateErrorNotFound: return "Sürüm bilgisine ulaşılamadı."
            case .updateErrorMissingFiles: return "Sürümde güncelleme dosyaları yok."
            case .updateErrorChecksumFile: return "Özet dosyası okunamadı."
            case .updateErrorChecksum: return "İndirilen dosyanın özeti tutmuyor; dosya bozuk ya da değiştirilmiş olabilir."
            case .updateErrorUnzip: return "Arşiv açılamadı."
            case .updateErrorWrongApp: return "Arşivdeki uygulama beklenen MacCalendar sürümü değil."
            case .updateErrorSignature: return "Uygulamanın imzası doğrulanamadı."
            case .updateAvailableTitle(let version): return "MacCalendar \(version) hazır"
            case .updateAvailableDetail(let current): return "Kullandığınız sürüm: \(current). Güncelleme indirilir, doğrulanır ve MacCalendar yeniden başlatılır."
            case .updateManualDetail(let current): return "Kullandığınız sürüm: \(current). Bu kopya kendini güncelleyemiyor (başka kullanıcıya ait); yeni sürümü indirme sayfasından kurabilirsiniz."
            case .updateInstallingDetail(let version): return "Sürüm \(version) indiriliyor ve doğrulanıyor…"
            case .updateErrorHTTP(let code): return "GitLab yanıtı: HTTP \(code)"
            case .updateErrorNotWritable(let folder): return "“\(folder)” klasörüne yazılamadı."
            }
        }

        var en: String {
            switch self {
            case .settings: return "Settings"
            case .about: return "About"
            case .today: return "Today"
            case .secondClock(let label): return "2nd Clock (\(label))"
            case .onlyLocal: return "Local Only"
            case .localTime: return "Local Time"
            case .addNotePlaceholder: return "Add quick note for selected day..."
            case .notesCount(let count): return count == 1 ? "1 note" : "\(count) notes"
            case .clickToSelectMonthYear: return "Click to select month and year"
            case .previousYear: return "Previous Year"
            case .nextYear: return "Next Year"
            case .previousMonth: return "Previous Month"
            case .nextMonth: return "Next Month"
            case .clickToGoToToday: return "Click to jump to today"
            case .searchWorldCityTitle: return "Search World Time Zone (400+ Cities)"
            case .searchCityPlaceholder: return "Type city or region (e.g. Toronto, Amsterdam, Tokyo)..."
            case .settingsTitle: return "Clock & Calendar Settings"
            case .showSecondClock: return "Show 2nd Clock (Menu Bar & Calendar)"
            case .secondClockCity: return "2nd Clock City:"
            case .notInList: return "Not in List?"
            case .searchAllCities: return "Search All Cities..."
            case .closeSearch: return "Close Search"
            case .otherCitySearchAction: return "Search Other City / Time Zone..."
            case .customLabel: return "Custom Label (Optional):"
            case .customLabelPlaceholder: return "Empty = Flag Only"
            case .flagStyle: return "Flag Style:"
            case .dateFormat: return "Date Format:"
            case .secondsInMenuBar: return "Seconds in Menu Bar"
            case .startMonday: return "Start on Monday"
            case .launchAtLogin: return "Launch Automatically at Login"
            case .appLanguage: return "Language:"
            case .aboutTitle: return "MacCalendar"
            case .aboutSubtitle: return "macOS Menu Bar Calendar & World Clock"
            case .developer: return "Developer: Rafet Sapancı"
            case .aboutDescription: return "A fast menu bar calendar and notes app that displays date, time, and your chosen world clock alongside country flags in macOS."
            case .copyright: return "© 2026 Rafet Sapancı • Native Swift & SwiftUI"
            case .quit: return "Quit Calendar App"
            case .quitConfirmTitle: return "Quit MacCalendar?"
            case .quitConfirmMessage: return "MacCalendar will be removed from the menu bar and closed."
            case .quitAction: return "Quit"
            case .cancel: return "Cancel"
            case .gitlabRepo: return "GitLab Repository"
            case .sameTime: return "Same time"
            case .hoursDiff(let diff): return "\(diff) hrs"
            case .todayWithDash: return "Today • "
            case .localClockOnRight: return "Local Time on the Right"
            case .checkForUpdates: return "Check for Updates…"
            case .checkingForUpdates: return "Checking…"
            case .updateUpToDate: return "MacCalendar is up to date."
            case .autoCheckUpdates: return "Check for Updates Automatically"
            case .updateNow: return "Update Now"
            case .updateLater: return "Later"
            case .updateSkipVersion: return "Skip This Version"
            case .openDownloadPage: return "Open Download Page"
            case .updateInstallingTitle: return "Updating MacCalendar"
            case .updateFailedTitle: return "The update could not be installed."
            case .updateFailedDetail: return "You can install the new version by hand from the download page."
            case .updateErrorNotFound: return "The release information could not be reached."
            case .updateErrorMissingFiles: return "The release has no update files."
            case .updateErrorChecksumFile: return "The checksum file could not be read."
            case .updateErrorChecksum: return "The download does not match its checksum; it may be damaged or altered."
            case .updateErrorUnzip: return "The archive could not be opened."
            case .updateErrorWrongApp: return "The archive does not contain the expected MacCalendar version."
            case .updateErrorSignature: return "The app signature could not be verified."
            case .updateAvailableTitle(let version): return "MacCalendar \(version) is available"
            case .updateAvailableDetail(let current): return "You have version \(current). The update is downloaded, verified, and MacCalendar restarts."
            case .updateManualDetail(let current): return "You have version \(current). This copy cannot update itself (it belongs to another user); install the new version from the download page."
            case .updateInstallingDetail(let version): return "Downloading and verifying version \(version)…"
            case .updateErrorHTTP(let code): return "GitLab answered: HTTP \(code)"
            case .updateErrorNotWritable(let folder): return "Could not write to “\(folder)”."
            }
        }
    }

    public static func shortMonths(for lang: AppLanguage) -> [String] {
        if lang.resolvedIsTurkish {
            return ["Oca", "Şub", "Mar", "Nis", "May", "Haz", "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara"]
        } else {
            return ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        }
    }

    public static func weekdayHeaders(startMonday: Bool, lang: AppLanguage) -> [(title: String, isWeekend: Bool)] {
        let isTr = lang.resolvedIsTurkish
        let allDays: [(title: String, isWeekend: Bool)] = [
            (isTr ? "Pz" : "Sun", true),
            (isTr ? "Pt" : "Mon", false),
            (isTr ? "Sa" : "Tue", false),
            (isTr ? "Ça" : "Wed", false),
            (isTr ? "Pe" : "Thu", false),
            (isTr ? "Cu" : "Fri", false),
            (isTr ? "Ct" : "Sat", true)
        ]
        if startMonday {
            return Array(allDays[1...6]) + [allDays[0]]
        } else {
            return allDays
        }
    }
}
