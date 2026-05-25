//
//  ShareCardSizeTests.swift
//
//  Copyright © 2026 ShareCardKit. All rights reserved.
//

import CoreGraphics
import Testing
@testable import ShareCardKit

@Suite("ShareCardSize geometry")
struct ShareCardSizeTests {

    @Test("Named sizes carry the documented dimensions")
    func namedDimensions() {
        #expect(ShareCardSize.square.dimensions == CGSize(width: 1200, height: 1200))
        #expect(ShareCardSize.twitter.dimensions == CGSize(width: 1200, height: 675))
        #expect(ShareCardSize.instagramSquare.dimensions == CGSize(width: 1080, height: 1080))
        #expect(ShareCardSize.instagramStory.dimensions == CGSize(width: 1080, height: 1920))
        #expect(ShareCardSize.openGraph.dimensions == CGSize(width: 1200, height: 630))
    }

    @Test("Custom size echoes its caller-supplied CGSize")
    func customDimensions() {
        let custom = ShareCardSize.custom(CGSize(width: 800, height: 400))
        #expect(custom.dimensions == CGSize(width: 800, height: 400))
        #expect(custom.aspectRatio == 2.0)
        #expect(custom.layoutAxis == .wide)
    }

    @Test("Aspect ratio is width / height")
    func aspectRatio() {
        #expect(approxEqual(ShareCardSize.square.aspectRatio, 1.0))
        #expect(approxEqual(ShareCardSize.twitter.aspectRatio, 1200.0 / 675.0))
        #expect(approxEqual(ShareCardSize.instagramStory.aspectRatio, 1080.0 / 1920.0))
    }

    private func approxEqual(_ lhs: CGFloat, _ rhs: CGFloat, epsilon: CGFloat = 1e-9) -> Bool {
        abs(lhs - rhs) < epsilon
    }

    @Test("Layout axis buckets sizes correctly")
    func layoutAxis() {
        #expect(ShareCardSize.square.layoutAxis == .square)
        #expect(ShareCardSize.instagramSquare.layoutAxis == .square)
        #expect(ShareCardSize.twitter.layoutAxis == .wide)
        #expect(ShareCardSize.openGraph.layoutAxis == .wide)
        #expect(ShareCardSize.instagramStory.layoutAxis == .tall)
    }

    @Test("socialSet contains exactly the five named sizes")
    func socialSetMembership() {
        let set = ShareCardSize.socialSet
        #expect(set.count == 5)
        #expect(Set(set) == Set([
            .twitter, .instagramSquare, .instagramStory, .openGraph, .square
        ] as [ShareCardSize]))
    }
}
