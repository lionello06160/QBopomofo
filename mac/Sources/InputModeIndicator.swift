import AppKit
import InputMethodKit

private final class InputModeIndicatorRequest: @unchecked Sendable {
    let isEnglish: Bool
    let client: IMKTextInput

    init(isEnglish: Bool, client: IMKTextInput) {
        self.isEnglish = isEnglish
        self.client = client
    }
}

/// A non-activating, transient badge for Q Bopomofo's internal language mode.
/// All calls are scheduled after key handling so this UI never blocks typing.
@MainActor
final class InputModeIndicator {
    static let shared = InputModeIndicator()

    nonisolated static func schedule(isEnglish: Bool, client: IMKTextInput) {
        let request = InputModeIndicatorRequest(isEnglish: isEnglish, client: client)
        DispatchQueue.main.async {
            var lineRect = NSRect.zero
            request.client.attributes(forCharacterIndex: 0, lineHeightRectangle: &lineRect)
            shared.show(
                isEnglish: request.isEnglish,
                near: NSPoint(x: lineRect.origin.x, y: lineRect.origin.y)
            )
        }
    }

    private let size = NSSize(width: 44, height: 34)
    private let panel: NSPanel
    private let badgeView: NSView
    private let label: NSTextField
    private var hideWorkItem: DispatchWorkItem?
    private var presentationID = 0

    private init() {
        panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .popUpMenu
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.ignoresMouseEvents = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient, .ignoresCycle]

        badgeView = NSView(frame: NSRect(origin: .zero, size: size))
        badgeView.wantsLayer = true
        badgeView.layer?.cornerRadius = size.height / 2
        badgeView.layer?.borderWidth = 0.5
        badgeView.layer?.borderColor = NSColor.white.withAlphaComponent(0.35).cgColor

        label = NSTextField(labelWithString: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alignment = .center
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.maximumNumberOfLines = 1
        badgeView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: badgeView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: badgeView.trailingAnchor),
            label.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor, constant: -0.5),
        ])

        panel.contentView = badgeView
        panel.alphaValue = 0
    }

    func show(isEnglish: Bool, near cursorPoint: NSPoint) {
        precondition(Thread.isMainThread)

        presentationID += 1
        let currentPresentationID = presentationID
        hideWorkItem?.cancel()

        label.stringValue = isEnglish ? "A" : "中"
        label.setAccessibilityLabel(isEnglish ? "英文輸入模式" : "中文輸入模式")
        badgeView.layer?.backgroundColor = badgeColor(isEnglish: isEnglish).cgColor
        panel.setFrameOrigin(origin(near: cursorPoint))
        panel.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.08
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
        }

        let hide = DispatchWorkItem { [weak self] in
            guard let self, self.presentationID == currentPresentationID else { return }
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.18
                context.timingFunction = CAMediaTimingFunction(name: .easeIn)
                self.panel.animator().alphaValue = 0
            }, completionHandler: { [weak self] in
                guard let self, self.presentationID == currentPresentationID else { return }
                self.panel.orderOut(nil)
            })
        }
        hideWorkItem = hide
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: hide)
    }

    private func badgeColor(isEnglish: Bool) -> NSColor {
        if isEnglish {
            return NSColor(calibratedRed: 0.20, green: 0.22, blue: 0.26, alpha: 0.96)
        }
        return NSColor.controlAccentColor.withAlphaComponent(0.96)
    }

    private func origin(near cursorPoint: NSPoint) -> NSPoint {
        let fallbackFrame = NSScreen.main?.visibleFrame ?? .zero
        let screenFrame = NSScreen.screens.first(where: {
            NSMouseInRect(cursorPoint, $0.frame, false)
        })?.visibleFrame ?? fallbackFrame

        let horizontalPadding: CGFloat = 4
        let verticalPadding: CGFloat = 6
        var x = cursorPoint.x - size.width / 2
        var y = cursorPoint.y - size.height - verticalPadding

        x = min(max(x, screenFrame.minX + horizontalPadding), screenFrame.maxX - size.width - horizontalPadding)
        if y < screenFrame.minY + horizontalPadding {
            y = cursorPoint.y + verticalPadding
        }
        y = min(y, screenFrame.maxY - size.height - horizontalPadding)

        return NSPoint(x: x.rounded(), y: y.rounded())
    }
}
