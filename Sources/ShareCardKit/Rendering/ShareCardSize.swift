//
//  ShareCardSize.swift
//
//  Copyright © 2026 ShareCardKit. All rights reserved.
//

// Foundation, not CoreGraphics: CG geometry values (CGSize/CGFloat) come through
// Foundation on every platform, including Android/corelibs where no CoreGraphics
// module exists.
import Foundation

// MARK: - ShareCardSize

/// The set of social-native target sizes the renderer ships defaults for,
/// plus an escape hatch (`.custom`) for ad-hoc dimensions.
///
/// Dimensions are **logical pixels** — multiply by the renderer's scale
/// (default `3.0`) for the on-disk image dimensions.
public enum ShareCardSize: Hashable, Sendable {

    /// 1200 × 1200. In-app share-sheet default.
    case square

    /// 1200 × 675. Twitter / X cards.
    case twitter

    /// 1080 × 1080. Instagram feed.
    case instagramSquare

    /// 1080 × 1920. Instagram / Facebook / TikTok story.
    case instagramStory

    /// 1200 × 630. Open Graph + Facebook link previews.
    case openGraph

    /// Caller-defined dimensions.
    case custom(CGSize)

    // MARK: - Geometry

    /// Logical pixel dimensions for this size.
    public var dimensions: CGSize {
        switch self {
        case .square:           return CGSize(width: 1200, height: 1200)
        case .twitter:          return CGSize(width: 1200, height: 675)
        case .instagramSquare:  return CGSize(width: 1080, height: 1080)
        case .instagramStory:   return CGSize(width: 1080, height: 1920)
        case .openGraph:        return CGSize(width: 1200, height: 630)
        case let .custom(size): return size
        }
    }

    /// Width-over-height ratio. Drives `layoutAxis` for the default layout.
    public var aspectRatio: CGFloat {
        let d = dimensions
        return d.height == 0 ? 0 : d.width / d.height
    }

    /// Coarse aspect bucket used to pick a default layout. Wide ≥ 1.5,
    /// tall ≤ 0.667, square otherwise.
    public var layoutAxis: LayoutAxis {
        let ratio = aspectRatio
        if ratio >= 1.5 { return .wide }
        if ratio <= 0.6667 { return .tall }
        return .square
    }

    // MARK: - Standard set

    /// The five named social sizes, in display order. Returned by
    /// `ShareCardRenderer.renderSocialSet`.
    public static let socialSet: [ShareCardSize] = [
        .twitter,
        .instagramSquare,
        .instagramStory,
        .openGraph,
        .square
    ]
}

// MARK: - LayoutAxis

/// Coarse aspect bucket. Drives which built-in layout `DefaultShareCardLayout`
/// renders for a given size.
public enum LayoutAxis: Hashable, Sendable {
    case wide
    case square
    case tall
}
