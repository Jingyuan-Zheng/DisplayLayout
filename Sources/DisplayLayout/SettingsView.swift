import SwiftUI

struct SettingsView: View {
    @AppStorage("appLanguage") private var appLanguageRaw = AppLanguage.english.rawValue
    @AppStorage("quitAfterApply") private var quitAfterApply = true

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguageRaw) ?? .english
    }

    var body: some View {
        Form {
            Section {
                Picker(
                    L10n.string("settings.language.label", language: language),
                    selection: $appLanguageRaw
                ) {
                    ForEach(AppLanguage.allCases) { option in
                        Text(verbatim: option.nativeName)
                            .tag(option.rawValue)
                    }
                }
            } header: {
                Text(verbatim: L10n.string("settings.general.header", language: language))
            }

            Section {
                Toggle(
                    L10n.string("settings.quitAfterApply.label", language: language),
                    isOn: $quitAfterApply
                )

                Text(verbatim: L10n.string("settings.quitAfterApply.help", language: language))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text(verbatim: L10n.string("settings.behavior.header", language: language))
            }
        }
        .formStyle(.grouped)
        .padding(16)
        .frame(width: 430)
    }
}
