import AppKit

/// GitLab'dan kendi kendini güncelleme. Son sürüm `freeware2/maccalendar` projesinin "en son sürüm" adresinden okunur.
/// Yeni sürüm varsa notları gösterilir; kabul edilirse `MacCalendar.zip` indirilir, SHA-256 özeti, kimliği, sürümü ve imzası
/// doğrulanır, uygulama yerine konur ve yeniden başlatılır. Uygulama günlerce açık kaldığı için otomatik denetleme yalnızca
/// açılışta değil, saatte bir tarih karşılaştırarak yapılır (GitLab'a günde en çok bir kez sorulur).
@MainActor
enum Updater {
    #if DEBUG
    // Yalnızca geliştirme derlemesinde (./build_app.sh --debug): yayımlanan uygulama bu ayarları okumaz.
    // MACCALENDAR_UPDATE_URL başka bir sürüm bilgisi (ör. file:// ile sahte sürüm).
    nonisolated static let testURL = ProcessInfo.processInfo.environment["MACCALENDAR_UPDATE_URL"].flatMap(URL.init(string:))
    #else
    nonisolated static let testURL: URL? = nil
    #endif

    nonisolated static var apiURL: URL {
        testURL ?? URL(string: "https://gitlab.com/api/v4/projects/freeware2%2Fmaccalendar/releases/permalink/latest")!
    }

    nonisolated static var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }

    private static let releasesPage = URL(string: "https://gitlab.com/freeware2/maccalendar/-/releases")!
    private static let lastCheckKey = "lastUpdateCheck"
    private static let skippedVersionKey = "skippedUpdateVersion"
    private static var settings: AppSettings { AppSettings.shared }
    private static var isBusy = false
    private static var hourlyTimer: Timer?

    enum Outcome {
        case upToDate, newer(UpdateRelease), failed(String)
    }

    // MARK: Denetleme

    /// Açılıştan kısa süre sonra ve saatte bir: ayar açıksa ve son başarılı denetlemeden bir gün geçtiyse sessizce bakar.
    /// Başarısız denetleme tarihi güncellemez, sonraki saatte yinelenir.
    static func startAutomaticChecks() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { checkIfDue() }
        let timer = Timer(timeInterval: 3600, repeats: true) { _ in
            Task { @MainActor in checkIfDue() }
        }
        timer.tolerance = 300
        RunLoop.main.add(timer, forMode: .common)
        hourlyTimer = timer
    }

    private static func checkIfDue() {
        guard settings.autoCheckUpdates, !isBusy else { return }
        let last = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: lastCheckKey))
        guard Date().timeIntervalSince(last) > 24 * 3600 else { return }
        Task {
            if case .newer(let release) = await checkNow(),
               UserDefaults.standard.string(forKey: skippedVersionKey) != release.version {
                offer(release)
            }
        }
    }

    /// Soru sormadan bakar (Hakkında bölümü sonucu kendi içinde yazar).
    static func checkNow() async -> Outcome {
        guard !isBusy else { return .upToDate }
        isBusy = true
        defer { isBusy = false }
        do {
            let release = try await UpdateCore.fetch(from: apiURL, allowAnyHost: testURL != nil)
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastCheckKey)
            return UpdateInfo.isNewer(release.version, than: currentVersion) ? .newer(release) : .upToDate
        } catch {
            return .failed(message(for: error))
        }
    }

    static func message(for error: Error) -> String {
        guard let failure = error as? UpdateFailure else { return error.localizedDescription }
        switch failure {
        case .notFound: return settings.tr(.updateErrorNotFound)
        case .http(let code): return settings.tr(.updateErrorHTTP(code))
        case .network(let text): return text
        case .missingFiles: return settings.tr(.updateErrorMissingFiles)
        case .badChecksumFile: return settings.tr(.updateErrorChecksumFile)
        case .checksumMismatch: return settings.tr(.updateErrorChecksum)
        case .unzipFailed: return settings.tr(.updateErrorUnzip)
        case .wrongApp: return settings.tr(.updateErrorWrongApp)
        case .badSignature: return settings.tr(.updateErrorSignature)
        case .notWritable(let folder): return settings.tr(.updateErrorNotWritable(folder))
        }
    }

    // MARK: Sorma

    static func offer(_ release: UpdateRelease) {
        guard !isBusy else { return }
        isBusy = true
        NotificationCenter.default.post(name: .flyoutShouldClose, object: nil)

        let current = Bundle.main.bundleURL
        let canInstall = release.archive != nil && release.checksum != nil && UpdateCore.canReplace(current)
        let alert = NSAlert()
        alert.messageText = settings.tr(.updateAvailableTitle(release.version))
        alert.informativeText = settings.tr(canInstall ? .updateAvailableDetail(currentVersion) : .updateManualDetail(currentVersion))
        let notes = UpdateInfo.whatsNew(in: release.notes, turkish: settings.appLanguage.resolvedIsTurkish)
        if !notes.isEmpty {
            let scroll = NSScrollView(frame: NSRect(x: 0, y: 0, width: 420, height: 180))
            scroll.hasVerticalScroller = true
            scroll.borderType = .bezelBorder
            let text = NSTextView(frame: scroll.contentView.bounds)
            text.isEditable = false
            text.autoresizingMask = [.width]
            text.textContainerInset = NSSize(width: 6, height: 6)
            text.font = .systemFont(ofSize: 12)
            text.string = notes
            scroll.documentView = text
            alert.accessoryView = scroll
        }
        alert.addButton(withTitle: settings.tr(canInstall ? .updateNow : .openDownloadPage))
        alert.addButton(withTitle: settings.tr(.updateLater))
        alert.addButton(withTitle: settings.tr(.updateSkipVersion))
        NSApp.activate(ignoringOtherApps: true)
        let answer = alert.runModal()
        isBusy = false
        switch answer {
        case .alertFirstButtonReturn:
            if canInstall {
                install(release)
            } else {
                NSWorkspace.shared.open(release.page ?? releasesPage)
            }
        case .alertThirdButtonReturn:
            UserDefaults.standard.set(release.version, forKey: skippedVersionKey)
        default:
            break
        }
    }

    // MARK: Kurma

    private static func install(_ release: UpdateRelease) {
        guard !isBusy else { return }
        isBusy = true
        let current = Bundle.main.bundleURL
        let bundleID = Bundle.main.bundleIdentifier
        let panel = UpdateProgressPanel(title: settings.tr(.updateInstallingTitle),
                                        message: settings.tr(.updateInstallingDetail(release.version)),
                                        cancelTitle: settings.tr(.cancel))
        let work = Task {
            defer { isBusy = false }
            do {
                let prepared = try await UpdateCore.prepare(release, replacing: current, bundleID: bundleID)
                defer { try? FileManager.default.removeItem(at: prepared.workFolder) }
                try Task.checkCancellation()
                try UpdateCore.replace(current, with: prepared.app)
                panel.close()
                relaunch(current)
            } catch is CancellationError {
                panel.close()
            } catch {
                panel.close()
                showFailure(error, page: release.page ?? releasesPage)
            }
        }
        panel.onCancel = { work.cancel() }
        panel.show()
    }

    private static func showFailure(_ error: Error, page: URL) {
        let alert = NSAlert()
        alert.messageText = settings.tr(.updateFailedTitle)
        alert.informativeText = message(for: error) + "\n\n" + settings.tr(.updateFailedDetail)
        alert.addButton(withTitle: settings.tr(.openDownloadPage))
        alert.addButton(withTitle: settings.tr(.updateLater))
        NSApp.activate(ignoringOtherApps: true)
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(page)
        }
    }

    /// Uygulama kapanınca yenisini açan küçük bir kabuk komutu bırakır, sonra kapanır.
    private static func relaunch(_ app: URL) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", "while kill -0 \(ProcessInfo.processInfo.processIdentifier) 2>/dev/null; do sleep 0.2; done; /usr/bin/open \"$0\"", app.path]
        try? process.run()
        NSApp.terminate(nil)
    }
}

/// İndirme sırasında görünen küçük pencere.
@MainActor
private final class UpdateProgressPanel: NSObject {
    var onCancel: (() -> Void)?
    private let panel: NSPanel

    init(title: String, message: String, cancelTitle: String) {
        panel = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 360, height: 120), styleMask: [.titled], backing: .buffered, defer: false)
        super.init()
        panel.title = title
        panel.isReleasedWhenClosed = false
        panel.level = .floating

        let label = NSTextField(wrappingLabelWithString: message)
        label.frame = NSRect(x: 20, y: 76, width: 320, height: 28)
        let bar = NSProgressIndicator(frame: NSRect(x: 20, y: 52, width: 320, height: 16))
        bar.style = .bar
        bar.isIndeterminate = true
        bar.startAnimation(nil)
        let cancel = NSButton(title: cancelTitle, target: self, action: #selector(cancelPressed))
        cancel.frame = NSRect(x: 250, y: 12, width: 90, height: 30)
        cancel.bezelStyle = .rounded
        panel.contentView?.addSubview(label)
        panel.contentView?.addSubview(bar)
        panel.contentView?.addSubview(cancel)
    }

    func show() {
        panel.center()
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
    }

    func close() {
        panel.close()
    }

    @objc private func cancelPressed() {
        onCancel?()
    }
}

#if DEBUG
/// Pencere açmadan, kullanıcı ayarlarına dokunmadan güncelleme denemesi: uygulama NSApplication başlamadan burada biter.
/// `MacCalendar --update-headless`: son sürümü okur, yeniyse kurar, sonucu yazar.
enum UpdateHeadless {
    static func run() -> Never {
        Task.detached {
            do {
                let current = Bundle.main.bundleURL
                let release = try await UpdateCore.fetch(from: Updater.apiURL, allowAnyHost: Updater.testURL != nil)
                print("son sürüm: \(release.version), çalışan: \(Updater.currentVersion)")
                guard UpdateInfo.isNewer(release.version, than: Updater.currentVersion) else {
                    print("sonuç: güncel")
                    exit(0)
                }
                guard UpdateCore.canReplace(current) else {
                    print("sonuç: yazma izni yok, indirme sayfası önerilir")
                    exit(3)
                }
                let prepared = try await UpdateCore.prepare(release, replacing: current, bundleID: Bundle.main.bundleIdentifier)
                try UpdateCore.replace(current, with: prepared.app)
                try? FileManager.default.removeItem(at: prepared.workFolder)
                print("sonuç: kuruldu \(release.version)")
                exit(0)
            } catch {
                print("sonuç: reddedildi \(error)")
                exit(2)
            }
        }
        dispatchMain()
    }
}
#endif
