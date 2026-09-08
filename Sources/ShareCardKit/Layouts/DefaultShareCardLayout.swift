//
//  DefaultShareCardLayout.swift
//
//  Copyright © 2026 ShareCardKit. All rights reserved.
//

// Android: excluded — SwiftUI layout consumed by ShareCardRenderer's Darwin render path.
// Successor: server-side render adapter (primary) / Compose bitmap bridge (fallback) behind
// ShareCardRendering, W5.6.
#if !os(Android)

import SwiftUI

// MARK: - DefaultShareCardLayout

/// Aspect-adaptive layout that dispatches on `ShareCardSize.layoutAxis`:
/// `.wide` → 16:9 / OG layout, `.square` → stacked, `.tall` → 9:16 story.
///
/// Apps that need brand-specific styling should provide their own `View`
/// and call `ShareCardRenderer.render(_:size:)` directly — this layout is
/// the opinionated default, not the only option.
public struct DefaultShareCardLayout<Content: ShareableContent>: View {

    public let content: Content
    public let size: ShareCardSize
    public let appearance: ShareCardRenderOptions.Appearance

    public init(
        content: Content,
        size: ShareCardSize,
        appearance: ShareCardRenderOptions.Appearance = .light
    ) {
        self.content = content
        self.size = size
        self.appearance = appearance
    }

    public var body: some View {
        let style = ShareCardStyle.tokens(for: size, appearance: appearance)

        Group {
            switch size.layoutAxis {
            case .wide:
                WideShareCardLayout(content: content, style: style)
            case .square:
                SquareShareCardLayout(content: content, style: style)
            case .tall:
                TallShareCardLayout(content: content, style: style)
            }
        }
        .frame(width: size.dimensions.width, height: size.dimensions.height)
        .background(style.background)
        .environment(\.colorScheme, appearance == .dark ? .dark : .light)
    }
}

// MARK: - ShareCardStyle

/// Internal token bundle. Layouts read padding / type / color from here so
/// the kit stays independent of any host app's theme. Sizes scale tokens
/// proportionally — a 1080×1080 card uses smaller paddings than a 1200×675
/// because they're drawn into less canvas.
struct ShareCardStyle {

    let background: Color
    let titleColor: Color
    let bodyColor: Color
    let mutedColor: Color
    let badgeFill: Color
    let badgeText: Color
    let divider: Color
    let accent: Color

    let outerPadding: CGFloat
    let segmentSpacing: CGFloat
    let titleSize: CGFloat
    let subtitleSize: CGFloat
    let badgeSize: CGFloat
    let statusSize: CGFloat
    let footerSize: CGFloat
    let breakdownBarHeight: CGFloat
    let chipHeight: CGFloat

    static func tokens(
        for size: ShareCardSize,
        appearance: ShareCardRenderOptions.Appearance
    ) -> ShareCardStyle {
        let isDark = appearance == .dark

        let bg: Color    = isDark ? Color(red: 0.06, green: 0.07, blue: 0.09) : Color(red: 0.99, green: 0.99, blue: 1.0)
        let title: Color = isDark ? Color(red: 0.96, green: 0.97, blue: 0.99) : Color(red: 0.08, green: 0.09, blue: 0.11)
        let body: Color  = isDark ? Color(red: 0.85, green: 0.87, blue: 0.91) : Color(red: 0.18, green: 0.20, blue: 0.24)
        let muted: Color = isDark ? Color(red: 0.62, green: 0.66, blue: 0.71) : Color(red: 0.42, green: 0.46, blue: 0.52)
        let divider: Color = isDark ? Color(red: 0.18, green: 0.20, blue: 0.24) : Color(red: 0.88, green: 0.90, blue: 0.93)
        let badgeFill: Color = isDark ? Color(red: 0.18, green: 0.20, blue: 0.24) : Color(red: 0.92, green: 0.94, blue: 0.97)
        let badgeText: Color = title
        let accent: Color = isDark ? Color(red: 0.55, green: 0.78, blue: 1.0) : Color(red: 0.12, green: 0.35, blue: 0.75)

        let minDim = min(size.dimensions.width, size.dimensions.height)

        return ShareCardStyle(
            background: bg,
            titleColor: title,
            bodyColor: body,
            mutedColor: muted,
            badgeFill: badgeFill,
            badgeText: badgeText,
            divider: divider,
            accent: accent,
            outerPadding: minDim * 0.06,
            segmentSpacing: minDim * 0.025,
            titleSize: minDim * (size.layoutAxis == .tall ? 0.075 : 0.07),
            subtitleSize: minDim * 0.035,
            badgeSize: minDim * 0.028,
            statusSize: minDim * 0.030,
            footerSize: minDim * 0.025,
            breakdownBarHeight: minDim * 0.045,
            chipHeight: minDim * 0.055
        )
    }
}

// MARK: - Shared subcomponents

struct ShareCardBadge: View {
    let text: String
    let style: ShareCardStyle
    var body: some View {
        Text(text)
            .font(.system(size: style.badgeSize, weight: .semibold, design: .monospaced))
            .foregroundStyle(style.badgeText)
            .padding(.horizontal, style.badgeSize * 0.7)
            .padding(.vertical, style.badgeSize * 0.35)
            .background(
                Capsule(style: .continuous)
                    .fill(style.badgeFill)
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(style.accent.opacity(0.35), lineWidth: 1)
            )
    }
}

struct ShareCardBreakdownBar: View {
    let segments: [ShareableBreakdownSegment]
    let height: CGFloat
    let cornerRadius: CGFloat
    let backgroundDivider: Color

    var body: some View {
        let total = max(1, segments.reduce(0) { $0 + $1.count })
        return GeometryReader { proxy in
            HStack(spacing: 0) {
                ForEach(segments) { segment in
                    Rectangle()
                        .fill(segment.color)
                        .frame(width: proxy.size.width * CGFloat(segment.count) / CGFloat(total))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(backgroundDivider, lineWidth: 1)
            )
        }
        .frame(height: height)
    }
}

struct ShareCardBreakdownChips: View {
    let segments: [ShareableBreakdownSegment]
    let height: CGFloat
    let style: ShareCardStyle

    var body: some View {
        HStack(spacing: style.segmentSpacing) {
            ForEach(segments) { segment in
                HStack(spacing: height * 0.15) {
                    Text(segment.label)
                        .font(.system(size: height * 0.42, weight: .bold, design: .monospaced))
                        .foregroundStyle(segment.color)
                    Text("\(segment.count)")
                        .font(.system(size: height * 0.42, weight: .semibold, design: .monospaced))
                        .foregroundStyle(style.titleColor)
                }
                .padding(.horizontal, height * 0.35)
                .frame(height: height)
                .background(
                    Capsule(style: .continuous)
                        .fill(segment.color.opacity(0.12))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .strokeBorder(segment.color.opacity(0.45), lineWidth: 1)
                )
            }
        }
    }
}

struct ShareCardFooter: View {
    let url: URL?
    let wordmark: String?
    let style: ShareCardStyle
    let alignment: HorizontalAlignment

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            if alignment == .trailing { Spacer(minLength: 0) }
            if let url {
                Text(url.absoluteString)
                    .font(.system(size: style.footerSize, weight: .regular, design: .monospaced))
                    .foregroundStyle(style.mutedColor)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer(minLength: style.segmentSpacing)
            if let wordmark {
                Text(wordmark)
                    .font(.system(size: style.footerSize, weight: .bold))
                    .foregroundStyle(style.accent)
                    .tracking(style.footerSize * 0.05)
            }
            if alignment == .leading { Spacer(minLength: 0) }
        }
    }
}

#endif // !os(Android)
