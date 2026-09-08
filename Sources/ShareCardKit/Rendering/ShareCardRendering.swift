//
//  ShareCardRendering.swift
//
//  Copyright © 2026 ShareCardKit. All rights reserved.
//

import Foundation

// MARK: - ShareCardRendering

/// Renderer seam for share-card production. `ShareCardRenderer`
/// (Darwin — SwiftUI `ImageRenderer`) is the shipped conformer; the
/// Android successors (server-side render adapter — primary — and the
/// Compose bitmap bridge fallback, W5.6) conform to the same surface
/// so hosts depend on the seam, not the platform renderer.
///
/// The `View`-generic conveniences on `ShareCardRenderer` are
/// deliberately NOT requirements — `SwiftUI.View` is not part of the
/// portable surface.
///
/// `@MainActor` matches the concrete renderer's isolation
/// (`ImageRenderer` is main-actor-bound). Conformers should be
/// `@MainActor` classes (a plain `actor` cannot satisfy
/// MainActor-isolated requirements); async requirements keep a
/// network-backed conformer viable — awaited work suspends off the
/// main thread, only coordination serializes.
@MainActor
public protocol ShareCardRendering: AnyObject {

    /// Render one `ShareableContent` value at one size. `nil` on
    /// render failure.
    func render<C: ShareableContent>(
        _ content: C,
        size: ShareCardSize
    ) async -> ShareCardImage?

    /// Render one value across several sizes. Failed sizes are
    /// dropped silently — check the returned dictionary's keys.
    func renderSet<C: ShareableContent>(
        _ content: C,
        sizes: [ShareCardSize]
    ) async -> [ShareCardSize: ShareCardImage]
}

// MARK: - Conveniences

public extension ShareCardRendering {

    /// Render across `ShareCardSize.socialSet`. Extension convenience
    /// (not a requirement) so every conformer agrees on what the
    /// social set is.
    func renderSocialSet<C: ShareableContent>(
        _ content: C
    ) async -> [ShareCardSize: ShareCardImage] {
        await renderSet(content, sizes: ShareCardSize.socialSet)
    }
}
