//
//  ShareCardImage.swift
//
//  Copyright © 2026 ShareCardKit. All rights reserved.
//

import CoreGraphics
import Foundation

// MARK: - ShareCardImage

/// The render output. Carries both the raw `CGImage` (for hand-off to
/// `ShareLink` / `UIActivityViewController`) and the encoded `Data` per the
/// renderer's configured format.
///
/// `size` is the logical pixel size — the on-disk image is `size × scale`.
public struct ShareCardImage: Sendable {

    public let cgImage: CGImage
    public let data: Data
    public let size: CGSize
    public let scale: CGFloat
    public let variant: ShareCardSize

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
}
