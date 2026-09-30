import AppKit
import SwiftUI

@main
struct DisplayLayoutApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage("appLanguage") private var appLanguageRaw = AppLanguage.english.rawValue

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguageRaw) ?? .english
    }

    var body: some Scene {
        WindowGroup(L10n.string("window.title", language: language)) {
            ContentView()
                .environment(\.locale, language.locale)
                .frame(width: 620, height: 500)
        }
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environment(\.locale, language.locale)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Keep this a normal macOS application so it appears in the Dock,
        // owns the standard menu bar while active, and participates in Mission Control.
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        DispatchQueue.main.async {
            guard let window = NSApp.windows.first(where: { $0.canBecomeKey }) ?? NSApp.windows.first else {
                return
            }

            window.center()
            window.collectionBehavior.insert(.managed)

            // Make launch discoverable without making the app permanently always-on-top.
            // The brief floating level is immediately returned to normal afterwards.
            window.level = .floating
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak window] in
                guard let window else { return }
                window.level = .normal
                window.collectionBehavior.insert(.managed)
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
