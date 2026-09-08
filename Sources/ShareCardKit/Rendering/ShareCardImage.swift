//
//  ShareCardImage.swift
//
//  Copyright © 2026 ShareCardKit. All rights reserved.
//

#if !os(Android)
import CoreGraphics
#endif
import Foundation

// MARK: - ShareCardImage

/// The render output. The portable core is `data` / `size` / `scale` /
/// `variant` — encoded bytes plus geometry, identical on every platform
/// (this is the value type the Ayes `SharePayload` seam adopts in W3.1).
/// On Darwin it additionally carries the raw `CGImage` for hand-off to
/// `ShareLink` / `UIActivityViewController`; producers that render
/// server-side or via Compose (W5.6) supply encoded bytes only.
///
/// `size` is the logical pixel size — the on-disk image is `size × scale`.
public struct ShareCardImage: Sendable {

#if !os(Android)
    /// Raw image for share-sheet hand-off. Darwin-only — `CGImage` has
    /// no Android counterpart.
    public let cgImage: CGImage
#endif
    public let data: Data
    public let size: CGSize
    public let scale: CGFloat
    public let variant: ShareCardSize

#if !os(Android)
    public init(
        cgImage: CGImage,
        data: Data,
        size: CGSize,
        scale: CGFloat,
        variant: ShareCardSize
    ) {
        self.cgImage = cgImage
        self.data = data
        self.size = size
        self.scale = scale
        self.variant = variant
    }
#else
    public init(
        data: Data,
        size: CGSize,
        scale: CGFloat,
        variant: ShareCardSize
    ) {
        self.data = data
        self.size = size
        self.scale = scale
        self.variant = variant
    }
#endif
}
