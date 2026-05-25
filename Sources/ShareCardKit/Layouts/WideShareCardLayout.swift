//
//  WideShareCardLayout.swift
//
//  Copyright © 2026 ShareCardKit. All rights reserved.
//

import SwiftUI

// MARK: - WideShareCardLayout

/// 16:9 / OG layout. Title + subtitle dominate the left ~⅔. Breakdown bar
/// and wordmark anchor the right ~⅓ so the card stays scannable in feed
/// previews where only the leading edge is visible above the fold.
struct WideShareCardLayout<Content: ShareableContent>: View {

    let content: Content
    let style: ShareCardStyle

    var body: some View {
        HStack(alignment: .top, spacing: style.outerPadding) {
            VStack(alignment: .leading, spacing: style.segmentSpacing) {

                if let badge = content.badge, !badge.isEmpty {
                    ShareCardBadge(text: badge, style: style)
                }

                Text(content.title)
                    .font(.system(size: style.titleSize, weight: .bold, design: .default))
                    .foregroundStyle(style.titleColor)
                    .lineSpacing(style.titleSize * 0.06)
                    .lineLimit(3)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                if let subtitle = content.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: style.subtitleSize, weight: .medium))
                        .foregroundStyle(style.bodyColor)
                        .lineLimit(2)
                }

                if let statusLine = content.statusLine, !statusLine.isEmpty {
                    Text(statusLine)
                        .font(.system(size: style.statusSize, weight: .regular))
                        .foregroundStyle(style.mutedColor)
                        .lineLimit(2)
                        .padding(.top, style.segmentSpacing * 0.5)
                }

                Spacer(minLength: 0)

                if content.footerURL != nil || content.wordmark != nil {
                    ShareCardFooter(
                        url: content.footerURL,
                        wordmark: nil,
                        style: style,
                        alignment: .leading
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: style.segmentSpacing) {
                if let wordmark = content.wordmark, !wordmark.isEmpty {
                    Text(wordmark)
                        .font(.system(size: style.titleSize * 0.45, weight: .black))
                        .foregroundStyle(style.accent)
                        .tracking(style.titleSize * 0.02)
                }

                Spacer(minLength: 0)

                if !content.breakdownSegments.isEmpty {
                    ShareCardBreakdownBar(
                        segments: content.breakdownSegments,
                        height: style.breakdownBarHeight,
                        cornerRadius: style.breakdownBarHeight * 0.35,
                        backgroundDivider: style.divider
                    )

                    VStack(alignment: .trailing, spacing: 2) {
                        ForEach(content.breakdownSegments) { segment in
                            HStack(spacing: style.segmentSpacing * 0.4) {
                                Text("\(segment.count)")
                                    .font(.system(size: style.subtitleSize * 0.85, weight: .semibold, design: .monospaced))
                                    .foregroundStyle(style.titleColor)
                                Text(segment.label)
                                    .font(.system(size: style.subtitleSize * 0.85, weight: .bold, design: .monospaced))
                                    .foregroundStyle(segment.color)
                            }
                        }
                    }
                }
            }
            .frame(width: 240 + style.outerPadding * 1.5)
        }
        .padding(style.outerPadding)
    }
}
