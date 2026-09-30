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
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button(L10n.string("menu.about", language: language)) {
                    appDelegate.showAboutPanel(language: language)
                }
            }
        }

        Settings {
            SettingsView()
                .environment(\.locale, language.locale)
        }

    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func showAboutPanel(language: AppLanguage) {
        NSApp.orderFrontStandardAboutPanel(options: [.credits: aboutCredits(language: language)])
        NSApp.activate(ignoringOtherApps: true)
    }

    private func aboutCredits(language: AppLanguage) -> NSAttributedString {
        let website = URL(string: "https://jingyuan.is-a.dev")!
        let repository = URL(string: "https://github.com/jingyuan-zheng/DisplayLayout")!
        let credits = NSMutableAttributedString(
            string: L10n.string("about.credits", language: language),
            attributes: [.font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize), .paragraphStyle: centeredParagraphStyle()]
        )
        let text = credits.string as NSString
        credits.addAttribute(.link, value: website, range: text.range(of: L10n.string("about.website", language: language)))
        credits.addAttribute(.link, value: repository, range: text.range(of: L10n.string("about.repository", language: language)))
        credits.addAttribute(.link, value: repository, range: text.range(of: L10n.string("about.license", language: language)))
        return credits
    }

    private func centeredParagraphStyle() -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
    }
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
