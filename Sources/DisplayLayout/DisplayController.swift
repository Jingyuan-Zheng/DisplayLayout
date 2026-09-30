import AppKit
import Combine
import CoreGraphics
import Foundation

struct DisplayInfo: Identifiable, Equatable {
    let id: CGDirectDisplayID
    let name: String
    let bounds: CGRect
    let isMain: Bool
    let isBuiltIn: Bool

    func roleName(language: AppLanguage) -> String {
        if isMain {
            return L10n.string("display.role.main", language: language)
        }
        if isBuiltIn {
            return L10n.string("display.role.builtin", language: language)
        }
        return L10n.string("display.role.external", language: language)
    }
}

enum LayoutDirection: String, CaseIterable, Identifiable, Equatable {
    case above
    case below
    case left
    case right

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .above: return "arrow.up"
        case .below: return "arrow.down"
        case .left: return "arrow.left"
        case .right: return "arrow.right"
        }
    }

    func sideName(language: AppLanguage) -> String {
        L10n.string("direction.\(rawValue)", language: language)
    }
}

enum DisplayStatus: Equatable {
    case reading
    case readError(Int32)
    case mirroring
    case ready
    case needsTwoDisplays
    case tooManyDisplays(Int)
    case invalidLayout
    case beginError(Int32)
    case moveError(Int32)
    case saveError(Int32)
    case applied(LayoutDirection)

    func localized(language: AppLanguage) -> String {
        switch self {
        case .reading:
            return L10n.string("status.reading", language: language)
        case .readError(let code):
            return L10n.string("status.readError", language: language, code)
        case .mirroring:
            return L10n.string("status.mirroring", language: language)
        case .ready:
            return L10n.string("status.ready", language: language)
        case .needsTwoDisplays:
            return L10n.string("status.needsTwoDisplays", language: language)
        case .tooManyDisplays(let count):
            return L10n.string("status.tooManyDisplays", language: language, count)
        case .invalidLayout:
            return L10n.string("status.invalidLayout", language: language)
        case .beginError(let code):
            return L10n.string("status.beginError", language: language, code)
        case .moveError(let code):
            return L10n.string("status.moveError", language: language, code)
        case .saveError(let code):
            return L10n.string("status.saveError", language: language, code)
        case .applied(let direction):
            return L10n.string(
                "status.applied",
                language: language,
                direction.sideName(language: language)
            )
        }
    }
}

@MainActor
final class DisplayController: ObservableObject {
    @Published private(set) var displays: [DisplayInfo] = []
    @Published private(set) var status: DisplayStatus = .reading
    @Published private(set) var isApplying = false
    private var hasMirroring = false

    var canArrange: Bool {
        displays.count == 2 && !hasMirroring && displays.contains(where: { $0.isMain })
    }

    init() {
        refresh()
    }

    func refresh() {
        var ids = [CGDirectDisplayID](repeating: 0, count: 16)
        var count: UInt32 = 0

        let error: CGError = ids.withUnsafeMutableBufferPointer { buffer in
            CGGetActiveDisplayList(UInt32(buffer.count), buffer.baseAddress, &count)
        }

        guard error == .success else {
            displays = []
            status = .readError(error.rawValue)
            return
        }

        let mainID = CGMainDisplayID()
        let activeIDs = Array(ids.prefix(Int(count)))
        hasMirroring = activeIDs.contains { CGDisplayIsInMirrorSet($0) != 0 }

        displays = activeIDs.map { id in
            DisplayInfo(
                id: id,
                name: displayName(for: id),
                bounds: CGDisplayBounds(id),
                isMain: id == mainID,
                isBuiltIn: CGDisplayIsBuiltin(id) != 0
            )
        }
        .sorted { lhs, rhs in
            if lhs.isMain != rhs.isMain { return lhs.isMain }
            return lhs.id < rhs.id
        }

        if hasMirroring {
            status = .mirroring
            return
        }

        switch displays.count {
        case 2:
            status = .ready
        case 0...1:
            status = .needsTwoDisplays
        default:
            status = .tooManyDisplays(displays.count)
        }
    }

    func apply(_ direction: LayoutDirection, quitAfterApply: Bool) {
        guard !isApplying else { return }
        guard displays.count == 2,
              let main = displays.first(where: { $0.isMain }),
              let secondary = displays.first(where: { !$0.isMain })
        else {
            status = .invalidLayout
            return
        }

        let target = targetOrigin(
            for: secondary.bounds,
            relativeTo: main.bounds,
            direction: direction
        )

        var configuration: CGDisplayConfigRef?
        let beginError = CGBeginDisplayConfiguration(&configuration)
        guard beginError == .success, let configuration else {
            status = .beginError(beginError.rawValue)
            return
        }

        isApplying = true

        let moveError = CGConfigureDisplayOrigin(
            configuration,
            secondary.id,
            target.x,
            target.y
        )

        guard moveError == .success else {
            CGCancelDisplayConfiguration(configuration)
            isApplying = false
            status = .moveError(moveError.rawValue)
            return
        }

        let completeError = CGCompleteDisplayConfiguration(configuration, .permanently)
        guard completeError == .success else {
            isApplying = false
            status = .saveError(completeError.rawValue)
            return
        }

        status = .applied(direction)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
            guard let self else { return }
            self.refresh()
            self.isApplying = false

            if quitAfterApply {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    NSApp.terminate(nil)
                }
            }
        }
    }

    private func targetOrigin(
        for secondary: CGRect,
        relativeTo main: CGRect,
        direction: LayoutDirection
    ) -> (x: Int32, y: Int32) {
        let x: CGFloat
        let y: CGFloat

        switch direction {
        case .left:
            x = main.minX - secondary.width
            y = main.minY + (main.height - secondary.height) / 2
        case .right:
            x = main.maxX
            y = main.minY + (main.height - secondary.height) / 2
        case .above:
            x = main.minX + (main.width - secondary.width) / 2
            y = main.minY - secondary.height
        case .below:
            x = main.minX + (main.width - secondary.width) / 2
            y = main.maxY
        }

        return (Int32(x.rounded()), Int32(y.rounded()))
    }

    private func displayName(for id: CGDirectDisplayID) -> String {
        let screenNumberKey = NSDeviceDescriptionKey("NSScreenNumber")

        if let screen = NSScreen.screens.first(where: { screen in
            guard let number = screen.deviceDescription[screenNumberKey] as? NSNumber else {
                return false
            }
            return number.uint32Value == id
        }) {
            return screen.localizedName
        }

        if CGDisplayIsBuiltin(id) != 0 {
            return "Built-in Display"
        }

        return "Display \(id)"
    }
}
