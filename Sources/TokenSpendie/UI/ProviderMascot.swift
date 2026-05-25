import SwiftUI

/// An original 8-bit robot mascot, drawn procedurally so it stays crisp at any
/// size and recolors to match the theme/tier. A blocky head with `>` `<` eyes,
/// two side ears, and four little legs.
///
/// Animations, all opt-in via the flags below:
///   • blink   — the `>` `<` eyes squish shut on a gentle cycle.
///   • bounce  — the whole body floats up and down continuously.
///   • shaking — a quick horizontal jitter, driven while a refresh runs.
///   • hot     — the ears wiggle when usage is high (passed in by the caller).
///
/// The body is laid out on a fixed pixel grid (see `Pixel`), measured to match
/// the reference sticker: wide head, ears poking out at mid-height, four legs.
struct ProviderMascot: View {
    /// Fill color for the body (calm/warn/hot under the active theme).
    var color: Color
    /// True while a usage fetch is running — drives the shake.
    var shaking: Bool = false
    /// True when usage is in the hot tier — drives the ear wiggle.
    var hot: Bool = false

    @State private var blink = false        // eyes shut
    @State private var bouncePhase = false  // toggled to animate the float
    @State private var earPhase = false     // toggled to animate ear wiggle
    @State private var shakePhase = false   // toggled to animate the jitter

    var body: some View {
        TimelineView(.animation) { _ in
            Canvas { context, size in
                draw(into: &context, size: size)
            }
        }
        .aspectRatio(Pixel.aspect, contentMode: .fit)
        // Continuous gentle float.
        .offset(y: bounceOffset)
        // Quick jitter while refreshing.
        .offset(x: shakeOffset)
        .onAppear { startLoops() }
        .onChange(of: shaking) { _ in withAnimation(.default) { shakePhase.toggle() } }
    }

    // MARK: Drawing

    private func draw(into context: inout GraphicsContext, size: CGSize) {
        let cell = min(size.width / Pixel.cols, size.height / Pixel.rows)
        let ox = (size.width - cell * Pixel.cols) / 2
        let oy = (size.height - cell * Pixel.rows) / 2

        func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
            CGRect(x: ox + x * cell, y: oy + y * cell, width: w * cell, height: h * cell)
        }

        // Body + legs path.
        var body = Path()
        for block in Pixel.body { body.addRect(rect(block.0, block.1, block.2, block.3)) }

        // Ears wiggle: nudge the two ear blocks out/in when hot.
        let earShift: CGFloat = hot ? (earPhase ? 0.5 : -0.2) : 0
        var ears = Path()
        ears.addRect(rect(Pixel.leftEar.0 - earShift, Pixel.leftEar.1, Pixel.leftEar.2, Pixel.leftEar.3))
        ears.addRect(rect(Pixel.rightEar.0 + earShift, Pixel.rightEar.1, Pixel.rightEar.2, Pixel.rightEar.3))

        // Soft glow under the body, then crisp fills.
        context.drawLayer { glow in
            glow.addFilter(.blur(radius: cell * 0.6))
            glow.fill(body, with: .color(color.opacity(0.45)))
        }
        context.fill(body, with: .color(color))
        context.fill(ears, with: .color(color))

        // Eyes: `>` on the left, `<` on the right, drawn as thick strokes.
        // When blinking, collapse them to flat dashes.
        let eyeColor = GraphicsContext.Shading.color(.black.opacity(0.85))
        let lw = cell * 0.6
        var eyes = Path()
        if blink {
            // Two short flat lines — eyes shut.
            eyes.move(to: CGPoint(x: rect(2.8, 4.3, 0, 0).minX, y: rect(0, 4.3, 0, 0).minY))
            eyes.addLine(to: CGPoint(x: rect(4.4, 4.3, 0, 0).minX, y: rect(0, 4.3, 0, 0).minY))
            eyes.move(to: CGPoint(x: rect(7.6, 4.3, 0, 0).minX, y: rect(0, 4.3, 0, 0).minY))
            eyes.addLine(to: CGPoint(x: rect(9.2, 4.3, 0, 0).minX, y: rect(0, 4.3, 0, 0).minY))
        } else {
            // `>` left eye.
            eyes.move(to: CGPoint(x: rect(2.8, 3.3, 0, 0).minX, y: rect(0, 3.3, 0, 0).minY))
            eyes.addLine(to: CGPoint(x: rect(4.4, 4.2, 0, 0).minX, y: rect(0, 4.2, 0, 0).minY))
            eyes.addLine(to: CGPoint(x: rect(2.8, 5.1, 0, 0).minX, y: rect(0, 5.1, 0, 0).minY))
            // `<` right eye.
            eyes.move(to: CGPoint(x: rect(9.2, 3.3, 0, 0).minX, y: rect(0, 3.3, 0, 0).minY))
            eyes.addLine(to: CGPoint(x: rect(7.6, 4.2, 0, 0).minX, y: rect(0, 4.2, 0, 0).minY))
            eyes.addLine(to: CGPoint(x: rect(9.2, 5.1, 0, 0).minX, y: rect(0, 5.1, 0, 0).minY))
        }
        context.stroke(eyes, with: eyeColor,
                       style: StrokeStyle(lineWidth: lw, lineCap: .round, lineJoin: .round))
    }

    // MARK: Animation values

    private var bounceOffset: CGFloat { bouncePhase ? -2.5 : 2.5 }
    private var shakeOffset: CGFloat { shaking ? (shakePhase ? 2.0 : -2.0) : 0 }

    /// Kick off the looping animations. Blink and bounce run forever; the ear
    /// wiggle loop also runs forever but only shows when `hot` gates it on.
    private func startLoops() {
        withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
            bouncePhase = true
        }
        withAnimation(.easeInOut(duration: 0.18).repeatForever(autoreverses: true)) {
            earPhase = true
        }
        scheduleBlink()
    }

    /// One blink (~120 ms shut) every 3–5 s, re-scheduling itself.
    private func scheduleBlink() {
        let delay = Double.random(in: 3...5)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            blink = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                blink = false
                scheduleBlink()
            }
        }
    }
}

/// The mascot's pixel layout, on a 12-wide × 13-tall grid. Tuples are
/// `(x, y, width, height)` in cells. Measured from the reference sticker.
private enum Pixel {
    static let cols: CGFloat = 12
    static let rows: CGFloat = 13
    static let aspect: CGFloat = cols / rows

    /// Head + torso + four legs (ears are separate so they can wiggle).
    static let body: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
        (1, 1, 10, 9),     // big head/torso block
        // four legs hanging off the bottom
        (1.5, 10, 1.6, 2.4),
        (4.0, 10, 1.6, 2.0),
        (6.4, 10, 1.6, 2.0),
        (8.9, 10, 1.6, 2.4),
    ]
    /// Ears poke out at mid-height on each side.
    static let leftEar: (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 4, 1, 2)
    static let rightEar: (CGFloat, CGFloat, CGFloat, CGFloat) = (11, 4, 1, 2)
}

#if DEBUG
#Preview {
    HStack(spacing: 20) {
        ProviderMascot(color: Color(red: 0.82, green: 0.45, blue: 0.33))
            .frame(width: 60, height: 65)
        ProviderMascot(color: .orange, shaking: true).frame(width: 40, height: 43)
        ProviderMascot(color: .red, hot: true).frame(width: 30, height: 33)
    }
    .padding(50)
    .background(Color(white: 0.1))
}
#endif
