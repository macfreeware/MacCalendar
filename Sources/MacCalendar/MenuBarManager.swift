import AppKit
import SwiftUI
import Combine

public extension Notification.Name {
    static let flyoutDidClose = Notification.Name("com.rafetsapanci.MacCalendar.flyoutDidClose")
    /// Görünüm, açılır pencerenin kapanmasını ister (örn. tarayıcıda bir bağlantı açıldığında)
    static let flyoutShouldClose = Notification.Name("com.rafetsapanci.MacCalendar.flyoutShouldClose")
}

public final class FlyoutPanel: NSPanel {
    public override var canBecomeKey: Bool { true }
    public override var canBecomeMain: Bool { true }
}

@MainActor
public final class MenuBarManager: NSObject, NSWindowDelegate {
    private var statusItem: NSStatusItem!
    public private(set) var panel: FlyoutPanel!
    public private(set) var hostingView: NSHostingView<CalendarFlyoutView>!
    private var timer: Timer?
    private var scheduledWithSeconds = false
    /// Son çizilen menü çubuğu metni; değişmediyse başlık yeniden kurulmaz
    private var lastStatusTitle: String?
    private var cancellables = Set<AnyCancellable>()
    private let settings = AppSettings.shared

    private var globalClickMonitor: Any?
    private var localKeyMonitor: Any?
    private var cachedIconDay: Int = -1
    private var cachedMenuBarIcon: NSImage?
    private var currentContentHeight: CGFloat = 516
    /// Pencerenin sağ kenar hizasını sabitleyerek 2. saat açılıp kapandığında sola/sağa kaymasını önler
    private var lockedRightEdgeX: CGFloat?

    public override init() {
        super.init()
        setupFlyoutPanel()
        setupStatusItem()
        setupBindings()
        startClockTimer()
    }

    private func setupFlyoutPanel() {
        let rootView = CalendarFlyoutView(
            settings: settings,
            onHeightChange: { [weak self] newHeight in
                guard let self = self else { return }
                self.currentContentHeight = newHeight
                self.repositionPanel(explicitHeight: newHeight)
            }
        )

        hostingView = NSHostingView(rootView: rootView)
        if #available(macOS 13.0, *) {
            hostingView.sizingOptions = []
        }
        hostingView.translatesAutoresizingMaskIntoConstraints = true
        hostingView.autoresizingMask = [.width, .height]

        let initialSize = hostingView.fittingSize
        let startWidth: CGFloat = 350
        let startHeight: CGFloat = max(ceil(initialSize.height), 480)
        currentContentHeight = startHeight

        let initialRect = NSRect(x: 0, y: 0, width: startWidth, height: startHeight)
        panel = FlyoutPanel(
            contentRect: initialRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .popUpMenu
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.delegate = self

        let container = NSView(frame: initialRect)
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor.clear.cgColor
        container.autoresizesSubviews = true

        hostingView.frame = container.bounds
        container.addSubview(hostingView)
        panel.contentView = container
    }

    private func setupStatusItem() {
        // İlk açılışta simgeyi diğer uygulama simgelerinin en sağına (sistem saatinin hemen soluna) yerleştir.
        // macOS konumu "NSStatusItem Preferred Position <autosaveName>" anahtarında, ekranın sağ kenarına
        // uzaklık olarak saklar; anahtar yoksa küçük bir değer yazılır. Kullanıcı simgeyi ⌘ ile sürükleyip
        // taşırsa macOS yeni konumu aynı anahtara yazar ve o konum korunur.
        let autosaveName = "MacCalendarStatusItem"
        let positionKey = "NSStatusItem Preferred Position \(autosaveName)"
        if UserDefaults.standard.object(forKey: positionKey) == nil {
            UserDefaults.standard.set(1, forKey: positionKey)
        }

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.autosaveName = autosaveName
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(toggleFlyout(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.focusRingType = .none
        }
        updateStatusBarTitle()
    }

    private func setupBindings() {
        NotificationCenter.default.publisher(for: .flyoutShouldClose)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.closeFlyout()
            }
            .store(in: &cancellables)

        settings.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.updateStatusBarTitle()
                    if self.scheduledWithSeconds != self.settings.showSecondsInMenuBar {
                        self.scheduleNextClockTick()
                    }
                    if self.panel.isVisible {
                        self.repositionPanel()
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func startClockTimer() {
        scheduleNextClockTick()
        // Uykudan uyanınca ya da saat/saat dilimi değişince menü çubuğu hemen güncellenir ve zamanlama yeniden kurulur
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(resyncClock), name: NSWorkspace.didWakeNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(resyncClock), name: .NSSystemClockDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(resyncClock), name: .NSSystemTimeZoneDidChange, object: nil)
    }

    @objc private func resyncClock() {
        NSTimeZone.resetSystemTimeZone()
        updateStatusBarTitle()
        scheduleNextClockTick()
    }

    /// Menü çubuğu yalnızca gösterilen metnin değişebileceği anda güncellenir: saniyeler açıksa her saniye başında,
    /// kapalıysa her dakika başında. (Saat dilimi farkları 15 dakikanın katı olduğundan dakika sınırı her yerde aynıdır.)
    private func scheduleNextClockTick() {
        timer?.invalidate()
        scheduledWithSeconds = settings.showSecondsInMenuBar
        let step: TimeInterval = scheduledWithSeconds ? 1 : 60
        let nowRef = Date().timeIntervalSinceReferenceDate
        let fireDate = Date(timeIntervalSinceReferenceDate: (floor(nowRef / step) + 1) * step + 0.01)
        let t = Timer(fire: fireDate, interval: 0, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.updateStatusBarTitle()
                self?.scheduleNextClockTick()
            }
        }
        t.tolerance = settings.showSecondsInMenuBar ? 0.05 : 0.5
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    @objc public func toggleFlyout(_ sender: AnyObject?) {
        if panel.isVisible {
            closeFlyout()
        } else {
            showFlyout()
        }
    }

    public func showFlyout() {
        FlyoutClock.shared.start()
        settings.refreshLaunchAtLoginStatus()
        // Açılış anında menü çubuğu öğesinin gerçek sağ kenarını yakala
        if let btnFrame = statusItem.button?.window?.frame, btnFrame.origin.x > 50 {
            lockedRightEdgeX = btnFrame.maxX
        }

        repositionPanel()
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        // İlk öğenin mavi odak çerçevesi (focus ring) almasını engelle
        panel.makeFirstResponder(nil)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.repositionPanel()
            self.panel.makeFirstResponder(nil)
        }

        if globalClickMonitor == nil {
            globalClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
                Task { @MainActor in
                    self?.closeFlyout()
                }
            }
        }

        if localKeyMonitor == nil {
            localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                if event.keyCode == 53 { // ESC
                    Task { @MainActor in
                        self?.closeFlyout()
                    }
                    return nil
                }
                return event
            }
        }
    }

    public func closeFlyout() {
        panel.orderOut(nil)
        FlyoutClock.shared.stop()
        NotificationCenter.default.post(name: .flyoutDidClose, object: nil)
        if let monitor = globalClickMonitor {
            NSEvent.removeMonitor(monitor)
            globalClickMonitor = nil
        }
        if let keyMonitor = localKeyMonitor {
            NSEvent.removeMonitor(keyMonitor)
            localKeyMonitor = nil
        }
    }

    public func windowDidResignKey(_ notification: Notification) {
        closeFlyout()
    }

    /// Pencerenin üst kenarını menü çubuğunun hemen altına ve yatay konumunu sabit sağ referans noktasına kilitler
    public func repositionPanel(explicitHeight: CGFloat? = nil) {
        hostingView.layoutSubtreeIfNeeded()
        let fitting = hostingView.fittingSize
        let panelWidth: CGFloat = 350
        let measuredHeight = explicitHeight ?? max(ceil(fitting.height), currentContentHeight)
        let panelHeight: CGFloat = max(ceil(fitting.height), measuredHeight)

        let buttonWindow = statusItem.button?.window
        let targetScreen = buttonWindow?.screen ?? NSScreen.main ?? NSScreen.screens.first
        guard let screen = targetScreen else { return }

        let safeFrame = screen.visibleFrame
        let topGap: CGFloat = 6.0

        let maxTopY: CGFloat
        if let btnFrame = buttonWindow?.frame, btnFrame.minY > safeFrame.minY {
            maxTopY = min(safeFrame.maxY - topGap, btnFrame.minY - topGap)
        } else {
            maxTopY = safeFrame.maxY - topGap
        }

        var originY = maxTopY - panelHeight
        if originY < safeFrame.minY + 8 {
            originY = safeFrame.minY + 8
        }

        // Yatay konum: Pencere açıkken X konumunu sabit tut; açılışta menü çubuğu öğesinin sağ kenarına hizala
        var originX: CGFloat
        if panel.isVisible && panel.frame.origin.x > 100 {
            originX = panel.frame.origin.x
        } else if let lockedRight = lockedRightEdgeX, lockedRight > 100 {
            originX = lockedRight - panelWidth
        } else if let btnFrame = buttonWindow?.frame, btnFrame.origin.x > 50 {
            lockedRightEdgeX = btnFrame.maxX
            originX = btnFrame.maxX - panelWidth
        } else {
            originX = safeFrame.maxX - panelWidth - 12
        }

        originX = min(max(originX, safeFrame.minX + 8), safeFrame.maxX - panelWidth - 8)

        let exactRect = NSRect(
            x: round(originX),
            y: round(originY),
            width: panelWidth,
            height: panelHeight
        )

        panel.setFrame(exactRect, display: true)
        if let contentView = panel.contentView {
            contentView.frame = NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight)
            hostingView.frame = contentView.bounds
            hostingView.needsLayout = true
            hostingView.layoutSubtreeIfNeeded()
        }
    }

    public func setFlyoutRootView(_ view: CalendarFlyoutView) {
        let newHostingView = NSHostingView(rootView: view)
        if #available(macOS 13.0, *) {
            newHostingView.sizingOptions = []
        }
        newHostingView.translatesAutoresizingMaskIntoConstraints = true
        newHostingView.autoresizingMask = [.width, .height]
        self.hostingView = newHostingView

        let container = NSView(frame: NSRect(x: 0, y: 0, width: 350, height: currentContentHeight))
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor.clear.cgColor
        container.autoresizesSubviews = true
        newHostingView.frame = container.bounds
        container.addSubview(newHostingView)
        panel.contentView = container
    }

    public var currentPanelFrame: NSRect {
        panel.frame
    }

    public var statusItemButton: NSStatusBarButton? {
        statusItem?.button
    }

    private func menuBarCalendarIcon(for date: Date) -> NSImage {
        let day = Calendar.current.component(.day, from: date)
        if day == cachedIconDay, let existing = cachedMenuBarIcon {
            return existing
        }

        let size = NSSize(width: 18, height: 18)
        let img = NSImage(size: size, flipped: false) { rect in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            ctx.setAllowsAntialiasing(true)

            let cardRect = rect.insetBy(dx: 1.0, dy: 1.0)
            let radius: CGFloat = 4.0
            let path = CGPath(roundedRect: cardRect, cornerWidth: radius, cornerHeight: radius, transform: nil)

            ctx.saveGState()
            ctx.addPath(path)
            ctx.clip()

            ctx.setFillColor(NSColor.white.withAlphaComponent(0.95).cgColor)
            ctx.fill(cardRect)

            let headerH: CGFloat = 5.0
            let headerRect = CGRect(x: cardRect.minX, y: cardRect.maxY - headerH, width: cardRect.width, height: headerH)
            ctx.setFillColor(NSColor(calibratedRed: 0.94, green: 0.25, blue: 0.28, alpha: 1.0).cgColor)
            ctx.fill(headerRect)

            let dayStr = "\(day)" as NSString
            let font = NSFont.monospacedDigitSystemFont(ofSize: 9.5, weight: .bold)
            let pStyle = NSMutableParagraphStyle()
            pStyle.alignment = .center
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: NSColor(calibratedRed: 0.12, green: 0.18, blue: 0.32, alpha: 1.0),
                .paragraphStyle: pStyle
            ]
            let strSize = dayStr.size(withAttributes: attrs)
            let bodyH = cardRect.height - headerH
            let textRect = CGRect(
                x: cardRect.minX,
                y: cardRect.minY + (bodyH - strSize.height) * 0.5,
                width: cardRect.width,
                height: strSize.height
            )
            dayStr.draw(in: textRect, withAttributes: attrs)
            ctx.restoreGState()

            return true
        }
        img.isTemplate = false
        cachedIconDay = day
        cachedMenuBarIcon = img
        return img
    }

    public func updateStatusBarTitle() {
        guard let button = statusItem.button else { return }
        let now = Date()

        let localTimeStr = formatTime(now, timeZone: .current, showSeconds: settings.showSecondsInMenuBar)
        let dateStr = formatDate(now, style: settings.menuBarDateFormat)
        let secondTime = settings.showSecondClock
            ? formatTime(now, timeZone: settings.secondTimeZone, showSeconds: settings.showSecondsInMenuBar)
            : nil
        let clocks = settings.clockLine(style: settings.menuBarClockBadgeStyle, localTime: localTimeStr, secondTime: secondTime)

        // Takvim simgesi yalnızca tarih yazısı yokken ("Gün Simgesi + Saat") gösterilir
        let icon = settings.menuBarDateFormat.showsDayIcon ? menuBarCalendarIcon(for: now) : nil
        if button.image !== icon {
            button.image = icon
            button.imagePosition = .imageLeading
        }

        let fullText = dateStr.isEmpty ? clocks : dateStr + "  " + clocks
        // Simgeyle yazı arasında boşluk; simge yoksa gerekmez
        let fullString = (icon == nil ? "" : " ") + fullText
        guard fullString != lastStatusTitle else { return }
        lastStatusTitle = fullString

        let textFont = NSFont.monospacedDigitSystemFont(ofSize: 12.5, weight: .medium)
        let flagFont = NSFont.systemFont(ofSize: 16.5)
        let baseAttrs: [NSAttributedString.Key: Any] = [
            .font: textFont,
            .foregroundColor: NSColor.labelColor
        ]

        let attrString = NSMutableAttributedString(string: fullString, attributes: baseAttrs)

        // Bayrak emojilerini daha büyük fontla ve dikey ortalanmış olarak biçimlendir
        let nsStr = fullString as NSString
        var searchIndex = 0
        while searchIndex < nsStr.length {
            let range = nsStr.rangeOfComposedCharacterSequence(at: searchIndex)
            let sub = nsStr.substring(with: range)
            if sub.unicodeScalars.contains(where: { ($0.value >= 0x1F1E6 && $0.value <= 0x1F1FF) || $0.value == 0x1F30D || $0.value == 0x1F310 }) {
                attrString.addAttributes([
                    .font: flagFont,
                    .baselineOffset: -1.8
                ], range: range)
            }
            searchIndex = range.location + range.length
        }

        button.attributedTitle = attrString
    }

    /// DateFormatter oluşturmak pahalıdır; saniyeli gösterimde her saniye yenisi kurulmasın diye önbelleğe alınır
    private var formatterCache: [String: DateFormatter] = [:]

    private func formatter(_ format: String, timeZone: TimeZone) -> DateFormatter {
        let locale = settings.effectiveLocale
        let key = "\(locale.identifier)|\(timeZone.identifier)|\(format)"
        if let cached = formatterCache[key] { return cached }
        let f = DateFormatter()
        f.locale = locale
        f.timeZone = timeZone
        f.dateFormat = format
        formatterCache[key] = f
        return f
    }

    private func formatTime(_ date: Date, timeZone: TimeZone, showSeconds: Bool) -> String {
        formatter(showSeconds ? "HH:mm:ss" : "HH:mm", timeZone: timeZone).string(from: date)
    }

    private func formatDate(_ date: Date, style: MenuBarDateFormat) -> String {
        switch style {
        case .dayMonthWeekday:
            return formatter("d MMM EEE", timeZone: .current).string(from: date)
        case .numeric:
            return formatter("dd.MM.yyyy", timeZone: .current).string(from: date)
        case .dayMonth:
            return formatter("d MMMM", timeZone: .current).string(from: date)
        case .hidden, .timeOnly:
            return ""
        }
    }
}
