import AppKit
import SwiftUI

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarManager: MenuBarManager?
    private let instanceID = UUID().uuidString
    // Bundle id'ye bağlı: ayrı kimlikli deneme kopyası gerçek uygulamayı kapatmaz
    private static let quitNotification = Notification.Name("\(Bundle.main.bundleIdentifier ?? "MacCalendar").quitOldInstance")

    public func applicationDidFinishLaunching(_ notification: Notification) {
        DistributedNotificationCenter.default().postNotificationName(
            Self.quitNotification,
            object: instanceID,
            userInfo: nil,
            deliverImmediately: true
        )

        DistributedNotificationCenter.default().addObserver(
            forName: Self.quitNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let self = self else { return }
            if let senderID = note.object as? String, senderID != self.instanceID {
                NSApp.terminate(nil)
            }
        }

        NSApp.setActivationPolicy(.accessory)
        let manager = MenuBarManager()
        self.menuBarManager = manager

        if CommandLine.arguments.contains("--self-test") {
            runVisualAndGeometrySelfTest(manager: manager)
        } else {
            Updater.startAutomaticChecks()
        }
    }

    private func runVisualAndGeometrySelfTest(manager: MenuBarManager) {
        let currentDir = FileManager.default.currentDirectoryPath
        let docsDir = (currentDir as NSString).appendingPathComponent("docs/screenshots")
        try? FileManager.default.createDirectory(atPath: docsDir, withIntermediateDirectories: true)

        let initialSecondClockState = AppSettings.shared.showSecondClock
        AppSettings.shared.showSecondClock = true
        manager.updateStatusBarTitle()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // 0. Menü Çubuğu Görünümünü Yakala
            if let button = manager.statusItemButton {
                button.layoutSubtreeIfNeeded()
                if let rep = button.bitmapImageRepForCachingDisplay(in: button.bounds) {
                    button.cacheDisplay(in: button.bounds, to: rep)
                    if let pngData = rep.representation(using: .png, properties: [:]) {
                        let path = "\(docsDir)/menu_bar_preview.png"
                        try? FileManager.default.removeItem(atPath: path)
                        try? pngData.write(to: URL(fileURLWithPath: path))
                        print("Saved live menu bar snapshot (\(Int(button.bounds.width))x\(Int(button.bounds.height))) -> \(path)")
                    }
                }
            }

            manager.showFlyout()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                manager.hostingView.layoutSubtreeIfNeeded()
                let fitH1 = ceil(manager.hostingView.fittingSize.height)
                manager.repositionPanel(explicitHeight: fitH1 > 100 ? fitH1 : nil)
                Self.logAndCapturePanel(manager: manager, label: "1_DUAL_CLOCK_MODE", path: "\(docsDir)/calendar_dual_clock.png")

                // 2. Ayarlar Görünümü
                let settingsView = CalendarFlyoutView(
                    settings: AppSettings.shared,
                    showSettingsInitially: true,
                    onHeightChange: { newH in
                        manager.repositionPanel(explicitHeight: newH)
                    }
                )
                manager.setFlyoutRootView(settingsView)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    manager.hostingView.layoutSubtreeIfNeeded()
                    let fitH2 = ceil(manager.hostingView.fittingSize.height)
                    if fitH2 > 100 {
                        manager.repositionPanel(explicitHeight: fitH2)
                    }
                    Self.logAndCapturePanel(manager: manager, label: "2_SETTINGS_PANEL", path: "\(docsDir)/settings_panel.png")

                    // 3. Hakkında Görünümü
                    let aboutView = CalendarFlyoutView(
                        settings: AppSettings.shared,
                        showAboutInitially: true,
                        onHeightChange: { newH in
                            manager.repositionPanel(explicitHeight: newH)
                        }
                    )
                    manager.setFlyoutRootView(aboutView)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        manager.hostingView.layoutSubtreeIfNeeded()
                        let fitH3 = ceil(manager.hostingView.fittingSize.height)
                        if fitH3 > 100 {
                            manager.repositionPanel(explicitHeight: fitH3)
                        }
                        Self.logAndCapturePanel(manager: manager, label: "3_ABOUT_PANEL", path: "\(docsDir)/about_panel.png")

                        // 4. Çıkış Onayı Görünümü
                        let quitConfirmView = CalendarFlyoutView(
                            settings: AppSettings.shared,
                            showQuitInitially: true,
                            onHeightChange: { newH in
                                manager.repositionPanel(explicitHeight: newH)
                            }
                        )
                        manager.setFlyoutRootView(quitConfirmView)

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            manager.hostingView.layoutSubtreeIfNeeded()
                            let fitH4 = ceil(manager.hostingView.fittingSize.height)
                            if fitH4 > 100 {
                                manager.repositionPanel(explicitHeight: fitH4)
                            }
                            let scratchPath = (NSTemporaryDirectory() as NSString).appendingPathComponent("Snap_4_QuitConfirm.png")
                            Self.logAndCapturePanel(manager: manager, label: "4_QUIT_CONFIRMATION", path: scratchPath)

                            AppSettings.shared.showSecondClock = initialSecondClockState
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                NSApp.terminate(nil)
                            }
                        }
                    }
                }
            }
        }
    }

    private static func logAndCapturePanel(manager: MenuBarManager, label: String, path: String) {
        let screen = NSScreen.main ?? NSScreen.screens.first!
        let visible = screen.visibleFrame
        let pFrame = manager.currentPanelFrame

        print("=== [\(label)] ===")
        print("Panel Frame    : \(pFrame)")
        print("Top Check      : panel.maxY(\(pFrame.maxY)) <= visible.maxY(\(visible.maxY)) -> \(pFrame.maxY <= visible.maxY ? "PASS ✅" : "FAIL ❌")")

        guard let contentView = manager.panel.contentView,
              let rep = contentView.bitmapImageRepForCachingDisplay(in: contentView.bounds) else {
            return
        }
        contentView.cacheDisplay(in: contentView.bounds, to: rep)
        if let pngData = rep.representation(using: .png, properties: [:]) {
            try? FileManager.default.removeItem(atPath: path)
            try? pngData.write(to: URL(fileURLWithPath: path))
            print("Saved live panel snapshot (\(Int(contentView.bounds.width))x\(Int(contentView.bounds.height))) -> \(path)")
        }
    }
}

@main
public struct MacCalendarApp {
    public static func main() {
        #if DEBUG
        if CommandLine.arguments.contains("--update-headless") {
            UpdateHeadless.run()
        }
        #endif
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}
