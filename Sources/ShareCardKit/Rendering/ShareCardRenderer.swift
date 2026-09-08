//
//  ShareCardRenderer.swift
//
//  Copyright © 2026 ShareCardKit. All rights reserved.
//

// Android: excluded — SwiftUI ImageRenderer capture + UIKit PNG/JPEG encoding, behind the
// portable ShareCardRendering seam. Successor: server-side render adapter (primary) /
// Compose bitmap bridge (fallback) behind ShareCardRendering, W5.6.
#if !os(Android)

import CoreGraphics
import Foundation
import SwiftUI
import UIKit

// MARK: - ShareCardRenderer

/// Renders a SwiftUI view (or a `ShareableContent` value via the built-in
/// layout) to one or more social-native image sizes using `SwiftUI.ImageRenderer`.
///
/// The renderer is `@MainActor` because `ImageRenderer` itself is. Parallel
/// rendering of multiple sizes uses a `TaskGroup` that re-enters the main
/// actor for each capture.
@MainActor
public final class ShareCardRenderer {

    // MARK: - Configuration

    public let scale: CGFloat
    public let options: ShareCardRenderOptions

    public init(
        scale: CGFloat = 3.0,
        options: ShareCardRenderOptions = ShareCardRenderOptions()
    ) {
        self.scale = scale
        self.options = options
    }

    // MARK: - Render (arbitrary view)

    /// Render an arbitrary SwiftUI view at the requested size. The view is
    /// responsible for adapting to the target aspect ratio.
    public func render<V: View>(_ view: V, size: ShareCardSize) async -> ShareCardImage? {
        await capture(view: view, size: size)
    }

    /// Render the same view across `ShareCardSize.socialSet` in parallel.
    /// Failed sizes are dropped silently — check the returned dictionary's
    /// keys to see what landed.
    public func renderSocialSet<V: View>(_ view: V) async -> [ShareCardSize: ShareCardImage] {
        await renderSet(view, sizes: ShareCardSize.socialSet)
    }

    /// Render an arbitrary view at a caller-supplied set of sizes.
    public func renderSet<V: View>(
        _ view: V,
        sizes: [ShareCardSize]
    ) async -> [ShareCardSize: ShareCardImage] {
        await withTaskGroup(of: (ShareCardSize, ShareCardImage?).self) { group in
            for size in sizes {
                group.addTask { @MainActor in
                    let image = await self.capture(view: view, size: size)
                    return (size, image)
                }
            }

            var output: [ShareCardSize: ShareCardImage] = [:]
            for await (size, image) in group {
                if let image { output[size] = image }
            }
            return output
        }
    }

    // MARK: - Render (ShareableContent + built-in layout)

    /// Convenience: render a `ShareableContent` value using the kit's
    /// aspect-adaptive `DefaultShareCardLayout` across the standard social set.
    public func renderSocialSet<C: ShareableContent>(
        _ content: C
    ) async -> [ShareCardSize: ShareCardImage] {
        await renderSet(content, sizes: ShareCardSize.socialSet)
    }

    /// Render a `ShareableContent` value via the built-in layout at the
    /// requested set of sizes.
    public func renderSet<C: ShareableContent>(
        _ content: C,
        sizes: [ShareCardSize]
    ) async -> [ShareCardSize: ShareCardImage] {
        await withTaskGroup(of: (ShareCardSize, ShareCardImage?).self) { group in
            let appearance = options.appearance
            for size in sizes {
                group.addTask { @MainActor in
                    let view = DefaultShareCardLayout(
                        content: content,
                        size: size,
                        appearance: appearance
                    )
                    let image = await self.capture(view: view, size: size)
                    return (size, image)
                }
            }

            var output: [ShareCardSize: ShareCardImage] = [:]
            for await (size, image) in group {
                if let image { output[size] = image }
            }
            return output
        }
    }

    /// Convenience for a single-size `ShareableContent` render.
    public func render<C: ShareableContent>(
        _ content: C,
        size: ShareCardSize
    ) async -> ShareCardImage? {
        let view = DefaultShareCardLayout(
            content: content,
            size: size,
            appearance: options.appearance
        )
        return await capture(view: view, size: size)
    }

    // MARK: - Internal capture

    private func capture<V: View>(view: V, size: ShareCardSize) async -> ShareCardImage? {
        let dimensions = size.dimensions
        let colorScheme: ColorScheme = options.appearance == .dark ? .dark : .light

        let hosted = view
            .frame(width: dimensions.width, height: dimensions.height)
            .environment(\.colorScheme, colorScheme)

        let renderer = ImageRenderer(content: hosted)
        renderer.scale = scale
        renderer.proposedSize = ProposedViewSize(width: dimensions.width, height: dimensions.height)

        guard let cgImage = renderer.cgImage else { return nil }
        guard let data = encode(cgImage: cgImage, format: options.format) else { return nil }

        return ShareCardImage(
            cgImage: cgImage,
            data: data,
            size: dimensions,
            scale: scale,
            variant: size
        )
    }

    private func encode(cgImage: CGImage, format: ShareCardRenderOptions.Format) -> Data? {
        let uiImage = UIImage(cgImage: cgImage, scale: scale, orientation: .up)
        switch format {
        case .png:
            return uiImage.pngData()
        case let .jpeg(quality):
            let clamped = max(0.0, min(1.0, quality))
            return uiImage.jpegData(compressionQuality: clamped)
        }
    }
}

// MARK: - ShareCardRendering conformance

/// The existing `ShareableContent`-generic methods witness the protocol
/// exactly; the `View`-generic overloads stay concrete-only.
extension ShareCardRenderer: ShareCardRendering {}

#endif // !os(Android)
