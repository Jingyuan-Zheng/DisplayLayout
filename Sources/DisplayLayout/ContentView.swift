import AppKit
import SwiftUI

struct ContentView: View {
    @StateObject private var controller = DisplayController()
    @AppStorage("quitAfterApply") private var quitAfterApply = true
    @AppStorage("appLanguage") private var appLanguageRaw = AppLanguage.english.rawValue

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguageRaw) ?? .english
    }

    var body: some View {
        VStack(spacing: 16) {
            header

            directionButton(.above)

            HStack(spacing: 14) {
                directionButton(.left)

                DisplayCanvas(displays: controller.displays, language: language)
                    .frame(width: 420, height: 250)

                directionButton(.right)
            }

            directionButton(.below)

            Text(verbatim: L10n.string("main.footer", language: language))
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(22)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            controller.refresh()
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "display.2")
                .font(.system(size: 30, weight: .medium))
                .symbolRenderingMode(.hierarchical)

            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: L10n.string("main.title", language: language))
                    .font(.title2.weight(.semibold))
                Text(verbatim: controller.status.localized(language: language))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Button {
                controller.refresh()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .help(L10n.string("action.refresh.help", language: language))
        }
    }

    private func directionButton(_ direction: LayoutDirection) -> some View {
        Button {
            controller.apply(direction, quitAfterApply: quitAfterApply)
        } label: {
            Image(systemName: direction.symbol)
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 34, height: 34)
        }
        .buttonStyle(.bordered)
        .clipShape(Circle())
        .disabled(!controller.canArrange || controller.isApplying)
        .help(
            L10n.string(
                "action.move.help",
                language: language,
                direction.sideName(language: language)
            )
        )
        .keyboardShortcut(shortcutKey(for: direction), modifiers: [.command, .option])
    }

    private func shortcutKey(for direction: LayoutDirection) -> KeyEquivalent {
        switch direction {
        case .above: return .upArrow
        case .below: return .downArrow
        case .left: return .leftArrow
        case .right: return .rightArrow
        }
    }
}
