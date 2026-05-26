import AppKit

/// AppKit twin of `ProviderMascot`, for places that need an `NSImage` rather
/// than a SwiftUI view — the menu bar status button and the generated app icon.
///
/// The pixel layout mirrors `ProviderMascot.Pixel` exactly (12×13 grid), so the
/// little robot looks identical everywhere. Drawing is static (no animation):
/// just the body, ears, four legs and the `>` `<` eyes.
enum MascotImage {
    static let cols: CGFloat = 12
    static let rows: CGFloat = 13
    static let aspect: CGFloat = cols / rows

    /// Head + torso + four legs (ears are separate, matching the SwiftUI view).
    private static let body: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
        (1, 1, 10, 9),          // big head/torso block
        (1.5, 10, 1.6, 2.4),    // four legs
        (4.0, 10, 1.6, 2.0),
        (6.4, 10, 1.6, 2.0),
        (8.9, 10, 1.6, 2.4),
    ]
    private static let leftEar: (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 4, 1, 2)
    private static let rightEar: (CGFloat, CGFloat, CGFloat, CGFloat) = (11, 4, 1, 2)

    /// Renders the mascot into a new `NSImage` of the given point size.
    ///
    /// - Parameters:
    ///   - size: target size in points; the grid is fit (aspect-preserved) inside.
    ///   - bodyColor: fill for body/ears/legs (the theme tier color).
    ///   - eyeColor: stroke for the `>` `<` eyes.
    ///   - glow: soft colored halo under the body (off for tiny menu-bar sizes).
    ///   - eyeWidthScale: eye stroke width as a fraction of one grid cell.
    static func image(size: NSSize,
                      bodyColor: NSColor,
                      eyeColor: NSColor = NSColor.black.withAlphaComponent(0.85),
                      glow: Bool = false,
                      eyeWidthScale: CGFloat = 0.6) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        draw(in: NSRect(origin: .zero, size: size),
             bodyColor: bodyColor, eyeColor: eyeColor,
             glow: glow, eyeWidthScale: eyeWidthScale)
        image.unlockFocus()
        image.isTemplate = false
        return image
    }

    /// Draws the mascot into the current graphics context, fit inside `rect`.
    /// Shared so the standalone icon generator can mirror it.
    static func draw(in rect: NSRect,
                     bodyColor: NSColor,
                     eyeColor: NSColor = NSColor.black.withAlphaComponent(0.85),
                     glow: Bool = false,
                     eyeWidthScale: CGFloat = 0.6) {
        let cell = min(rect.width / cols, rect.height / rows)
        let ox = rect.minX + (rect.width - cell * cols) / 2
        let oy = rect.minY + (rect.height - cell * rows) / 2

        // Map a top-left grid cell (matching the SwiftUI layout, y growing down)
        // to an AppKit rect (y growing up) by flipping within the grid block.
        func cellRect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> NSRect {
            NSRect(x: ox + x * cell,
                   y: oy + (rows - (y + h)) * cell,
                   width: w * cell, height: h * cell)
        }
        func point(_ x: CGFloat, _ y: CGFloat) -> NSPoint {
            NSPoint(x: ox + x * cell, y: oy + (rows - y) * cell)
        }

        // Body + ears + legs as one filled path.
        let shape = NSBezierPath()
        for b in body { shape.appendRect(cellRect(b.0, b.1, b.2, b.3)) }
        shape.appendRect(cellRect(leftEar.0, leftEar.1, leftEar.2, leftEar.3))
        shape.appendRect(cellRect(rightEar.0, rightEar.1, rightEar.2, rightEar.3))

        if glow, let ctx = NSGraphicsContext.current {
            ctx.saveGraphicsState()
            let shadow = NSShadow()
            shadow.shadowColor = bodyColor.withAlphaComponent(0.55)
            shadow.shadowBlurRadius = cell * 1.4
            shadow.shadowOffset = .zero
            shadow.set()
            bodyColor.setFill()
            shape.fill()
            ctx.restoreGraphicsState()
        }
        bodyColor.setFill()
        shape.fill()

        // Eyes: `>` on the left, `<` on the right, thick round strokes.
        let eyes = NSBezierPath()
        eyes.lineWidth = cell * eyeWidthScale
        eyes.lineCapStyle = .round
        eyes.lineJoinStyle = .round
        eyes.move(to: point(2.8, 3.3))      // `>`
        eyes.line(to: point(4.4, 4.2))
        eyes.line(to: point(2.8, 5.1))
        eyes.move(to: point(9.2, 3.3))      // `<`
        eyes.line(to: point(7.6, 4.2))
        eyes.line(to: point(9.2, 5.1))
        eyeColor.setStroke()
        eyes.stroke()
    }
}
