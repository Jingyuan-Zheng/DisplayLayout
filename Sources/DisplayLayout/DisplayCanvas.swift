import SwiftUI

struct DisplayCanvas: View {
    let displays: [DisplayInfo]
    let language: AppLanguage

    var body: some View {
        GeometryReader { proxy in
            let rect = unionRect
            let padding: CGFloat = 24
            let usableWidth = max(1, proxy.size.width - padding * 2)
            let usableHeight = max(1, proxy.size.height - padding * 2)
            let scaleX = usableWidth / max(1, rect.width)
            let scaleY = usableHeight / max(1, rect.height)
            let scale = min(scaleX, scaleY)
            let contentWidth = rect.width * scale
            let contentHeight = rect.height * scale
            let offsetX = (proxy.size.width - contentWidth) / 2
            let offsetY = (proxy.size.height - contentHeight) / 2

            ZStack(alignment: .topLeading) {
                ForEach(displays) { display in
                    let x = offsetX + (display.bounds.minX - rect.minX) * scale
                    let y = offsetY + (display.bounds.minY - rect.minY) * scale
                    let width = max(42, display.bounds.width * scale)
                    let height = max(30, display.bounds.height * scale)

                    ZStack {
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(display.isMain ? Color.accentColor.opacity(0.18) : Color.secondary.opacity(0.12))

                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .strokeBorder(
                                display.isMain ? Color.accentColor : Color.secondary.opacity(0.65),
                                lineWidth: display.isMain ? 2 : 1.5
                            )

                        VStack(spacing: 3) {
                            Text(display.isMain ? "1" : "2")
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                            Text(verbatim: display.roleName(language: language))
                                .font(.caption.weight(.medium))
                            Text(verbatim: display.name)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        .padding(6)
                    }
                    .frame(width: width, height: height)
                    .position(x: x + width / 2, y: y + height / 2)
                }
            }
        }
        .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color(nsColor: .separatorColor).opacity(0.55), lineWidth: 1)
        }
    }

    private var unionRect: CGRect {
        guard let first = displays.first?.bounds else {
            return CGRect(x: 0, y: 0, width: 1, height: 1)
        }

        return displays.dropFirst().reduce(first) { partial, display in
            partial.union(display.bounds)
        }
    }
}
