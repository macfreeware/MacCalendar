import AppKit
import CoreGraphics

func drawAppIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    guard let ctx = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    ctx.setAllowsAntialiasing(true)
    ctx.setShouldAntialias(true)

    let s = size
    let pad = s * 0.085
    let bodyRect = CGRect(x: pad, y: pad, width: s - pad * 2, height: s - pad * 2)
    let cornerRadius = bodyRect.width * 0.225

    // 1. Dış gölge ve macOS Squircle Arka Planı (Zengin Gece Mavisi -> Safir Gradyan)
    ctx.saveGState()
    ctx.setShadow(
        offset: CGSize(width: 0, height: -s * 0.025),
        blur: s * 0.055,
        color: NSColor(calibratedWhite: 0, alpha: 0.42).cgColor
    )
    let bgPath = CGPath(roundedRect: bodyRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    ctx.addPath(bgPath)
    ctx.fillPath()
    ctx.restoreGState()

    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.clip()

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bgColors = [
        NSColor(calibratedRed: 0.09, green: 0.16, blue: 0.36, alpha: 1.0).cgColor,
        NSColor(calibratedRed: 0.14, green: 0.34, blue: 0.72, alpha: 1.0).cgColor,
        NSColor(calibratedRed: 0.22, green: 0.52, blue: 0.96, alpha: 1.0).cgColor
    ] as CFArray
    let bgLocations: [CGFloat] = [0.0, 0.55, 1.0]
    if let gradient = CGGradient(colorsSpace: colorSpace, colors: bgColors, locations: bgLocations) {
        ctx.drawLinearGradient(
            gradient,
            start: CGPoint(x: bodyRect.minX, y: bodyRect.minY),
            end: CGPoint(x: bodyRect.maxX, y: bodyRect.maxY),
            options: []
        )
    }

    // Arka plan zarif ışık yansıması
    let glowCenter = CGPoint(x: bodyRect.minX + bodyRect.width * 0.25, y: bodyRect.maxY - bodyRect.height * 0.15)
    let glowColors = [
        NSColor(calibratedRed: 0.45, green: 0.78, blue: 1.0, alpha: 0.38).cgColor,
        NSColor(calibratedRed: 0.45, green: 0.78, blue: 1.0, alpha: 0.0).cgColor
    ] as CFArray
    if let glowGrad = CGGradient(colorsSpace: colorSpace, colors: glowColors, locations: [0.0, 1.0]) {
        ctx.drawRadialGradient(
            glowGrad,
            startCenter: glowCenter,
            startRadius: 0,
            endCenter: glowCenter,
            endRadius: bodyRect.width * 0.75,
            options: []
        )
    }
    ctx.restoreGState()

    // Squircle İnce Parlak Çerçeve
    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.setStrokeColor(NSColor(calibratedWhite: 1.0, alpha: 0.22).cgColor)
    ctx.setLineWidth(s * 0.012)
    ctx.strokePath()
    ctx.restoreGState()

    // 2. Takvim Kartı (Modern Yuvarlatılmış Beyaz/Krem Kart)
    let cardW = bodyRect.width * 0.68
    let cardH = bodyRect.height * 0.68
    let cardX = bodyRect.minX + bodyRect.width * 0.12
    let cardY = bodyRect.minY + bodyRect.height * 0.19
    let cardRect = CGRect(x: cardX, y: cardY, width: cardW, height: cardH)
    let cardRadius = cardW * 0.17

    ctx.saveGState()
    ctx.setShadow(
        offset: CGSize(width: 0, height: -s * 0.018),
        blur: s * 0.04,
        color: NSColor(calibratedRed: 0.02, green: 0.06, blue: 0.18, alpha: 0.48).cgColor
    )
    let cardPath = CGPath(roundedRect: cardRect, cornerWidth: cardRadius, cornerHeight: cardRadius, transform: nil)
    ctx.addPath(cardPath)
    ctx.setFillColor(NSColor(calibratedRed: 0.97, green: 0.98, blue: 1.0, alpha: 1.0).cgColor)
    ctx.fillPath()
    ctx.restoreGState()

    // Takvim Üst Başlık Şeridi (Mercan Kırmızısı -> Turuncu Gradyan)
    ctx.saveGState()
    ctx.addPath(cardPath)
    ctx.clip()

    let headerH = cardH * 0.30
    let headerRect = CGRect(x: cardRect.minX, y: cardRect.maxY - headerH, width: cardW, height: headerH)
    ctx.saveGState()
    ctx.clip(to: headerRect)
    let headerColors = [
        NSColor(calibratedRed: 0.94, green: 0.24, blue: 0.30, alpha: 1.0).cgColor,
        NSColor(calibratedRed: 0.99, green: 0.42, blue: 0.24, alpha: 1.0).cgColor
    ] as CFArray
    if let headerGrad = CGGradient(colorsSpace: colorSpace, colors: headerColors, locations: [0.0, 1.0]) {
        ctx.drawLinearGradient(
            headerGrad,
            start: CGPoint(x: headerRect.minX, y: headerRect.minY),
            end: CGPoint(x: headerRect.maxX, y: headerRect.maxY),
            options: []
        )
    }
    ctx.restoreGState()

    // Üst başlıktaki iki metalik halka (takvim spirali)
    let ringW = cardW * 0.075
    let ringH = headerH * 0.52
    let ringY = headerRect.maxY - ringH * 0.85
    for factor in [0.27, 0.73] {
        let rx = cardRect.minX + cardW * CGFloat(factor) - ringW / 2
        let rRect = CGRect(x: rx, y: ringY, width: ringW, height: ringH)
        let rPath = CGPath(roundedRect: rRect, cornerWidth: ringW / 2, cornerHeight: ringW / 2, transform: nil)
        ctx.addPath(rPath)
        ctx.setFillColor(NSColor(calibratedWhite: 1.0, alpha: 0.92).cgColor)
        ctx.fillPath()
    }

    // Takvim Gövdesinde Büyük Gün Rakamı ("29")
    let numberStr = "29" as NSString
    let fontSize = cardW * 0.44
    let font = NSFont.systemFont(ofSize: fontSize, weight: .bold)
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center

    let textAttrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor(calibratedRed: 0.11, green: 0.20, blue: 0.40, alpha: 1.0),
        .paragraphStyle: paragraph
    ]
    let textSize = numberStr.size(withAttributes: textAttrs)
    let bodyAreaH = cardH - headerH
    let textRect = CGRect(
        x: cardRect.minX,
        y: cardRect.minY + (bodyAreaH - textSize.height) * 0.52,
        width: cardW,
        height: textSize.height
    )
    numberStr.draw(in: textRect, withAttributes: textAttrs)

    ctx.restoreGState()

    // 3. Sağ Alt Köşede Çift Saat (Dual Clock) Rozeti
    let clockDiameter = bodyRect.width * 0.42
    let clockX = bodyRect.maxX - clockDiameter - bodyRect.width * 0.07
    let clockY = bodyRect.minY + bodyRect.height * 0.08
    let clockRect = CGRect(x: clockX, y: clockY, width: clockDiameter, height: clockDiameter)

    ctx.saveGState()
    ctx.setShadow(
        offset: CGSize(width: 0, height: -s * 0.015),
        blur: s * 0.035,
        color: NSColor(calibratedWhite: 0, alpha: 0.45).cgColor
    )
    ctx.fillEllipse(in: clockRect)
    ctx.restoreGState()

    // Saat Dış Çemberi (Turkuaz -> Mavi Gradyan)
    ctx.saveGState()
    ctx.addEllipse(in: clockRect)
    ctx.clip()
    let clockRimColors = [
        NSColor(calibratedRed: 0.05, green: 0.58, blue: 0.88, alpha: 1.0).cgColor,
        NSColor(calibratedRed: 0.16, green: 0.80, blue: 0.92, alpha: 1.0).cgColor
    ] as CFArray
    if let rimGrad = CGGradient(colorsSpace: colorSpace, colors: clockRimColors, locations: [0.0, 1.0]) {
        ctx.drawLinearGradient(
            rimGrad,
            start: CGPoint(x: clockRect.minX, y: clockRect.minY),
            end: CGPoint(x: clockRect.maxX, y: clockRect.maxY),
            options: []
        )
    }
    ctx.restoreGState()

    // Saat İç Kadranı (Koyu Lacivert Kadran)
    let faceInset = clockDiameter * 0.095
    let faceRect = clockRect.insetBy(dx: faceInset, dy: faceInset)
    ctx.saveGState()
    ctx.setFillColor(NSColor(calibratedRed: 0.08, green: 0.13, blue: 0.26, alpha: 1.0).cgColor)
    ctx.fillEllipse(in: faceRect)

    // Saat İndeks Noktaları (12, 3, 6, 9)
    let center = CGPoint(x: faceRect.midX, y: faceRect.midY)
    let radius = faceRect.width * 0.39
    let dotR = faceRect.width * 0.038
    ctx.setFillColor(NSColor(calibratedWhite: 1.0, alpha: 0.75).cgColor)
    for angleDeg in stride(from: 0.0, to: 360.0, by: 30.0) {
        let rad = angleDeg * .pi / 180.0
        let dx = center.x + CGFloat(cos(rad)) * radius
        let dy = center.y + CGFloat(sin(rad)) * radius
        let isCardinal = Int(angleDeg) % 90 == 0
        let r = isCardinal ? dotR * 1.25 : dotR * 0.7
        ctx.fillEllipse(in: CGRect(x: dx - r, y: dy - r, width: r * 2, height: r * 2))
    }

    // 2. Saat (Tokyo) İkinci Akrep İbresi (Turuncu/Altın - Çift saati temsil eder)
    ctx.setStrokeColor(NSColor(calibratedRed: 1.0, green: 0.62, blue: 0.20, alpha: 0.95).cgColor)
    ctx.setLineWidth(faceRect.width * 0.055)
    ctx.setLineCap(.round)
    let secondZoneAngle = -35.0 * .pi / 180.0
    ctx.move(to: center)
    ctx.addLine(to: CGPoint(
        x: center.x + CGFloat(cos(secondZoneAngle)) * (faceRect.width * 0.25),
        y: center.y + CGFloat(sin(secondZoneAngle)) * (faceRect.width * 0.25)
    ))
    ctx.strokePath()

    // Ana Akrep (Beyaz - Saat 10 yönü)
    ctx.setStrokeColor(NSColor.white.cgColor)
    ctx.setLineWidth(faceRect.width * 0.068)
    let hourAngle = 145.0 * .pi / 180.0
    ctx.move(to: center)
    ctx.addLine(to: CGPoint(
        x: center.x + CGFloat(cos(hourAngle)) * (faceRect.width * 0.24),
        y: center.y + CGFloat(sin(hourAngle)) * (faceRect.width * 0.24)
    ))
    ctx.strokePath()

    // Ana Yelkovan (Beyaz - Saat 2 yönü)
    ctx.setLineWidth(faceRect.width * 0.055)
    let minuteAngle = 55.0 * .pi / 180.0
    ctx.move(to: center)
    ctx.addLine(to: CGPoint(
        x: center.x + CGFloat(cos(minuteAngle)) * (faceRect.width * 0.34),
        y: center.y + CGFloat(sin(minuteAngle)) * (faceRect.width * 0.34)
    ))
    ctx.strokePath()

    // Merkez Pim
    let pinR = faceRect.width * 0.055
    ctx.setFillColor(NSColor(calibratedRed: 0.99, green: 0.42, blue: 0.24, alpha: 1.0).cgColor)
    ctx.fillEllipse(in: CGRect(x: center.x - pinR, y: center.y - pinR, width: pinR * 2, height: pinR * 2))
    ctx.restoreGState()

    image.unlockFocus()
    return image
}

func savePNG(_ image: NSImage, to path: String, pixelSize: Int) throws {
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixelSize,
        pixelsHigh: pixelSize,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        return
    }
    rep.size = NSSize(width: pixelSize, height: pixelSize)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    image.draw(
        in: NSRect(x: 0, y: 0, width: pixelSize, height: pixelSize),
        from: .zero,
        operation: .copy,
        fraction: 1.0
    )
    NSGraphicsContext.restoreGraphicsState()

    if let data = rep.representation(using: .png, properties: [:]) {
        try data.write(to: URL(fileURLWithPath: path))
    }
}

let iconsetDir = "/tmp/AppIcon.iconset"
try? FileManager.default.removeItem(atPath: iconsetDir)
try FileManager.default.createDirectory(atPath: iconsetDir, withIntermediateDirectories: true)

let specs: [(name: String, size: Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

let masterImage = drawAppIcon(size: 1024)
for spec in specs {
    let outPath = "\(iconsetDir)/\(spec.name)"
    try savePNG(masterImage, to: outPath, pixelSize: spec.size)
}

// Ayrıca önizleme için 512x512 PNG kaydet
let previewPath = (FileManager.default.currentDirectoryPath as NSString).appendingPathComponent("AppIconPreview.png")
try savePNG(masterImage, to: previewPath, pixelSize: 512)
print("Iconset generated successfully!")
