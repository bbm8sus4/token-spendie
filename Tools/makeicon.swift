// Tools/makeicon.swift — run with: swift Tools/makeicon.swift
// Draws Resources/AppIcon-1024.png: the 8-bit mascot on a rounded dark tile.
//
// The mascot drawing mirrors Sources/TokenSpendie/UI/MascotImage.swift (same
// 12×13 pixel grid). This is a standalone build script, so the layout is
// duplicated here rather than imported — keep the two in sync.
import AppKit

let size: CGFloat = 1024
let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()

// Rounded dark tile.
NSColor(calibratedRed: 0.12, green: 0.12, blue: 0.16, alpha: 1).setFill()
NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: size, height: size),
             xRadius: 180, yRadius: 180).fill()

// Mascot, fit inside a centered box covering ~60% of the tile.
let bodyColor = NSColor(calibratedRed: 0.82, green: 0.45, blue: 0.33, alpha: 1)
let eyeColor = NSColor.black.withAlphaComponent(0.85)
let box: CGFloat = 620
let rect = NSRect(x: (size - box) / 2, y: (size - box) / 2, width: box, height: box)

let cols: CGFloat = 12, rows: CGFloat = 13
let cell = min(rect.width / cols, rect.height / rows)
let ox = rect.minX + (rect.width - cell * cols) / 2
let oy = rect.minY + (rect.height - cell * rows) / 2

func cellRect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> NSRect {
    NSRect(x: ox + x * cell, y: oy + (rows - (y + h)) * cell, width: w * cell, height: h * cell)
}
func point(_ x: CGFloat, _ y: CGFloat) -> NSPoint {
    NSPoint(x: ox + x * cell, y: oy + (rows - y) * cell)
}

// Body + four legs + two ears as one filled silhouette.
let shape = NSBezierPath()
for b in [(1.0, 1.0, 10.0, 9.0),
          (1.5, 10.0, 1.6, 2.4), (4.0, 10.0, 1.6, 2.0),
          (6.4, 10.0, 1.6, 2.0), (8.9, 10.0, 1.6, 2.4)] {
    shape.appendRect(cellRect(b.0, b.1, b.2, b.3))
}
shape.appendRect(cellRect(0, 4, 1, 2))    // left ear
shape.appendRect(cellRect(11, 4, 1, 2))   // right ear

// Soft warm glow under the body, then a crisp fill.
NSGraphicsContext.current?.saveGraphicsState()
let glow = NSShadow()
glow.shadowColor = bodyColor.withAlphaComponent(0.6)
glow.shadowBlurRadius = cell * 1.4
glow.shadowOffset = .zero
glow.set()
bodyColor.setFill()
shape.fill()
NSGraphicsContext.current?.restoreGraphicsState()
bodyColor.setFill()
shape.fill()

// Eyes: `>` left, `<` right.
let eyes = NSBezierPath()
eyes.lineWidth = cell * 0.6
eyes.lineCapStyle = .round
eyes.lineJoinStyle = .round
eyes.move(to: point(2.8, 3.3)); eyes.line(to: point(4.4, 4.2)); eyes.line(to: point(2.8, 5.1))
eyes.move(to: point(9.2, 3.3)); eyes.line(to: point(7.6, 4.2)); eyes.line(to: point(9.2, 5.1))
eyeColor.setStroke()
eyes.stroke()

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else {
    FileHandle.standardError.write(Data("icon render failed\n".utf8))
    exit(1)
}
try! FileManager.default.createDirectory(atPath: "Resources", withIntermediateDirectories: true)
try! png.write(to: URL(fileURLWithPath: "Resources/AppIcon-1024.png"))
print("wrote Resources/AppIcon-1024.png")
