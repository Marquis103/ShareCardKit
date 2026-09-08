//
//  ShareCardRenderOptions.swift
//
//  Copyright © 2026 ShareCardKit. All rights reserved.
//

// Foundation, not CoreGraphics: CG geometry values (CGFloat) come through
// Foundation on every platform, including Android/corelibs where no CoreGraphics
// module exists.
import Foundation

// MARK: - ShareCardRenderOptions

/// Renderer-wide knobs. Defaults are tuned for social feeds:
/// light appearance (reads consistently against varied feed backgrounds)
/// and PNG output (sharper for text-heavy cards; no JPEG ringing).
public struct ShareCardRenderOptions: Sendable, Equatable {

    public enum Appearance: Sendable, Equatable {
        case light
        case dark
    }

    public enum Format: Sendable, Equatable {

        /// Lossless. Default. Best for text + flat color regions.
        case png

        /// Lossy. Use when payload size matters more than crispness;
        /// `quality` is clamped to `0...1` at encode time.
        case jpeg(quality: CGFloat)
    }

    public var appearance: Appearance
    public var format: Format

    public init(appearance: Appearance = .light, format: Format = .png) {
        self.appearance = appearance
        self.format = format
    }
}
