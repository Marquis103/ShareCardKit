//
//  SquareShareCardLayout.swift
//
//  Copyright © 2026 ShareCardKit. All rights reserved.
//

import SwiftUI

// MARK: - SquareShareCardLayout

/// 1:1 layout. Stacked top-to-bottom: badge → title → subtitle →
/// breakdown chips → status line → footer (URL + wordmark).
/// Used for `.square` (in-app default) and `.instagramSquare`.
struct SquareShareCardLayout<Content: ShareableContent>: View {

    let content: Content
    let style: ShareCardStyle

    var body: some View {
        VStack(alignment: .leading, spacing: style.segmentSpacing) {

            if let badge = content.badge, !badge.isEmpty {
                ShareCardBadge(text: badge, style: style)
            }

            Text(content.title)
                .font(.system(size: style.titleSize, weight: .bold))
                .foregroundStyle(style.titleColor)
                .lineSpacing(style.titleSize * 0.06)
                .lineLimit(4)
                .truncationMode(.tail)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            if let subtitle = content.subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: style.subtitleSize, weight: .medium))
                    .foregroundStyle(style.bodyColor)
                    .lineLimit(2)
            }

            if !content.breakdownSegments.isEmpty {
                ShareCardBreakdownChips(
                    segments: content.breakdownSegments,
                    height: style.chipHeight,
                    style: style
                )
                .padding(.top, style.segmentSpacing * 0.5)
            }

            if let statusLine = content.statusLine, !statusLine.isEmpty {
                Text(statusLine)
                    .font(.system(size: style.statusSize, weight: .regular))
                    .foregroundStyle(style.mutedColor)
                    .lineLimit(3)
                    .padding(.top, style.segmentSpacing * 0.5)
            }

            Spacer(minLength: 0)

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
        .padding(style.outerPadding)
    }
}
