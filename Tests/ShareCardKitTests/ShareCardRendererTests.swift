//
//  ShareCardRendererTests.swift
//
//  Copyright © 2026 ShareCardKit. All rights reserved.
//

import CoreGraphics
import SwiftUI
import Testing
@testable import ShareCardKit

@Suite("ShareCardRenderer")
@MainActor
struct ShareCardRendererTests {

    @Test("Single render produces a @3x CGImage with the requested logical dimensions")
    func singleRenderDimensions() async throws {
        let renderer = ShareCardRenderer()
        let image = try #require(
            await renderer.render(MockShareableContent.canonical, size: .twitter)
        )

        #expect(image.variant == .twitter)
        #expect(image.scale == 3.0)
        #expect(image.size == CGSize(width: 1200, height: 675))
        #expect(image.cgImage.width == Int(1200 * 3))
        #expect(image.cgImage.height == Int(675 * 3))
        #expect(!image.data.isEmpty)
    }

    @Test("renderSocialSet returns one image per size in the standard set")
    func socialSetCoverage() async throws {
        let renderer = ShareCardRenderer()
        let set = await renderer.renderSocialSet(MockShareableContent.canonical)

        #expect(Set(set.keys) == Set(ShareCardSize.socialSet))

        for size in ShareCardSize.socialSet {
            let image = try #require(set[size])
            let expectedWidth = Int(size.dimensions.width * 3.0)
            let expectedHeight = Int(size.dimensions.height * 3.0)
            #expect(image.cgImage.width == expectedWidth, "wrong pixel width for \(size)")
            #expect(image.cgImage.height == expectedHeight, "wrong pixel height for \(size)")
        }
    }

    @Test("Custom scale flows through to the CGImage")
    func customScale() async throws {
        let renderer = ShareCardRenderer(scale: 2.0)
        let image = try #require(
            await renderer.render(MockShareableContent.canonical, size: .square)
        )

        #expect(image.scale == 2.0)
        #expect(image.cgImage.width == 2400)
        #expect(image.cgImage.height == 2400)
    }

    @Test("JPEG format produces JPEG-magic-byte data")
    func jpegFormat() async throws {
        let renderer = ShareCardRenderer(
            options: ShareCardRenderOptions(appearance: .light, format: .jpeg(quality: 0.85))
        )
        let image = try #require(
            await renderer.render(MockShareableContent.canonical, size: .openGraph)
        )

        // JPEG SOI marker = 0xFF 0xD8.
        #expect(image.data.count >= 2)
        #expect(image.data[0] == 0xFF)
        #expect(image.data[1] == 0xD8)
    }

    @Test("PNG format produces PNG-magic-byte data")
    func pngFormat() async throws {
        let renderer = ShareCardRenderer()
        let image = try #require(
            await renderer.render(MockShareableContent.canonical, size: .square)
        )

        // PNG signature: 89 50 4E 47 0D 0A 1A 0A.
        #expect(image.data.count >= 8)
        let signature: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        for (offset, byte) in signature.enumerated() {
            #expect(image.data[offset] == byte, "PNG signature mismatch at byte \(offset)")
        }
    }

    @Test("Arbitrary SwiftUI view renders to the requested size")
    func arbitraryViewRender() async throws {
        struct StubView: View {
            var body: some View {
                Color.blue
                    .overlay(Text("HELLO").foregroundStyle(.white).font(.system(size: 80, weight: .black)))
            }
        }

        let renderer = ShareCardRenderer()
        let image = try #require(
            await renderer.render(StubView(), size: .openGraph)
        )

        #expect(image.cgImage.width == 3600) // 1200 * 3
        #expect(image.cgImage.height == 1890) // 630 * 3
    }
}
