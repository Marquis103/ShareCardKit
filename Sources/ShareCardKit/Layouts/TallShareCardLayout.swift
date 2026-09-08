//
//  TallShareCardLayout.swift
//
//  Copyright © 2026 ShareCardKit. All rights reserved.
//

// Android: excluded — SwiftUI layout consumed by ShareCardRenderer's Darwin render path.
// Successor: server-side render adapter (primary) / Compose bitmap bridge (fallback) behind
// ShareCardRendering, W5.6.
#if !os(Android)

import SwiftUI

// MARK: - TallShareCardLayout

/// 9:16 story layout. Top third anchors badge + title for thumb-stop legibility.
/// Middle third holds the breakdown bar with generous negative space.
/// Bottom third carries status + URL + wordmark so the call to action lands
/// where Instagram / TikTok render their UI chrome anyway.
struct TallShareCardLayout<Content: ShareableContent>: View {

    let content: Content
    let style: ShareCardStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: top — badge + title + subtitle
            VStack(alignment: .leading, spacing: style.segmentSpacing) {
                if let badge = content.badge, !badge.isEmpty {
                    ShareCardBadge(text: badge, style: style)
                }

                Text(content.title)
                    .font(.system(size: style.titleSize, weight: .bold))
                    .foregroundStyle(style.titleColor)
                    .lineSpacing(style.titleSize * 0.06)
                    .lineLimit(5)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                if let subtitle = content.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: style.subtitleSize, weight: .medium))
                        .foregroundStyle(style.bodyColor)
                        .lineLimit(3)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: style.outerPadding)

            // MARK: middle — breakdown
            if !content.breakdownSegments.isEmpty {
                VStack(alignment: .leading, spacing: style.segmentSpacing) {
                    ShareCardBreakdownBar(
                        segments: content.breakdownSegments,
                        height: style.breakdownBarHeight * 1.4,
                        cornerRadius: style.breakdownBarHeight * 0.5,
                        backgroundDivider: style.divider
                    )

                    HStack(spacing: style.segmentSpacing) {
                        ForEach(content.breakdownSegments) { segment in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(segment.color)
                                    .frame(width: style.subtitleSize * 0.6, height: style.subtitleSize * 0.6)
                                Text("\(segment.count) \(segment.label)")
                                    .font(.system(size: style.subtitleSize * 0.9, weight: .semibold, design: .monospaced))
                                    .foregroundStyle(style.bodyColor)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer(minLength: style.outerPadding)

            // MARK: bottom — status, footer, wordmark
            VStack(alignment: .leading, spacing: style.segmentSpacing) {
                if let statusLine = content.statusLine, !statusLine.isEmpty {
                    Text(statusLine)
                        .font(.system(size: style.statusSize, weight: .regular))
                        .foregroundStyle(style.mutedColor)
                        .lineLimit(3)
                }

                Rectangle()
                    .fill(style.divider)
                    .frame(height: 1)

                ShareCardFooter(
                    url: content.footerURL,
                    wordmark: content.wordmark,
                    style: style,
                    alignment: .leading
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(style.outerPadding)
    }
}

#endif // !os(Android)
