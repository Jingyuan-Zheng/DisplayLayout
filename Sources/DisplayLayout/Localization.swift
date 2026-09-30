import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case simplifiedChinese = "zh-Hans"

    var id: String { rawValue }

    var locale: Locale {
        Locale(identifier: rawValue)
    }

    var nativeName: String {
        switch self {
        case .english:
            return "English"
        case .simplifiedChinese:
            return "简体中文"
        }
    }
}

enum L10n {
    static func string(
        _ key: String,
        language: AppLanguage,
        _ arguments: CVarArg...
    ) -> String {
        let bundle = bundle(for: language)
        let format = bundle.localizedString(forKey: key, value: key, table: "Localizable")

        guard !arguments.isEmpty else {
            return format
        }

        return String(
            format: format,
            locale: language.locale,
            arguments: arguments
        )
    }

    private static func bundle(for language: AppLanguage) -> Bundle {
        guard
            let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
            let localizedBundle = Bundle(path: path)
        else {
            return .main
        }

        return localizedBundle
    }
}
