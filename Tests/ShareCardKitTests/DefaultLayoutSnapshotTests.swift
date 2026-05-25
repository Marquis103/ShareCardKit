//
//  DefaultLayoutSnapshotTests.swift
//
//  Copyright © 2026 ShareCardKit. All rights reserved.
//

#if canImport(UIKit)

import SnapshotTesting
import SwiftUI
import Testing
@testable import ShareCardKit

@Suite("DefaultShareCardLayout snapshots — 5 sizes × Light/Dark")
@MainActor
struct DefaultLayoutSnapshotTests {

    // MARK: - Light appearance

    @Test("Light · Twitter (1200×675)")
    func lightTwitter() {
        assertLayoutSnapshot(size: .twitter, appearance: .light)
    }

    @Test("Light · Open Graph (1200×630)")
    func lightOpenGraph() {
        assertLayoutSnapshot(size: .openGraph, appearance: .light)
    }

    @Test("Light · Square (1200×1200)")
    func lightSquare() {
        assertLayoutSnapshot(size: .square, appearance: .light)
    }

    @Test("Light · Instagram Square (1080×1080)")
    func lightInstagramSquare() {
        assertLayoutSnapshot(size: .instagramSquare, appearance: .light)
    }

    @Test("Light · Instagram Story (1080×1920)")
    func lightInstagramStory() {
        assertLayoutSnapshot(size: .instagramStory, appearance: .light)
    }

    // MARK: - Dark appearance

    @Test("Dark · Twitter (1200×675)")
    func darkTwitter() {
        assertLayoutSnapshot(size: .twitter, appearance: .dark)
    }

    @Test("Dark · Open Graph (1200×630)")
    func darkOpenGraph() {
        assertLayoutSnapshot(size: .openGraph, appearance: .dark)
    }

    @Test("Dark · Square (1200×1200)")
    func darkSquare() {
        assertLayoutSnapshot(size: .square, appearance: .dark)
    }

    @Test("Dark · Instagram Square (1080×1080)")
    func darkInstagramSquare() {
        assertLayoutSnapshot(size: .instagramSquare, appearance: .dark)
    }

    @Test("Dark · Instagram Story (1080×1920)")
    func darkInstagramStory() {
        assertLayoutSnapshot(size: .instagramStory, appearance: .dark)
    }

    // MARK: - Helper

    private func assertLayoutSnapshot(
        size: ShareCardSize,
        appearance: ShareCardRenderOptions.Appearance,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        let view = DefaultShareCardLayout(
            content: MockShareableContent.canonical,
            size: size,
            appearance: appearance
        )
        .frame(width: size.dimensions.width, height: size.dimensions.height)

        let layout = SwiftUISnapshotLayout.fixed(
            width: size.dimensions.width,
            height: size.dimensions.height
        )

        assertSnapshot(
            of: view,
            as: .image(
                perceptualPrecision: 0.95,
                layout: layout,
                traits: .init(userInterfaceStyle: appearance == .dark ? .dark : .light)
            ),
            fileID: fileID,
            file: filePath,
            testName: testName,
            line: line,
            column: column
        )
    }
}

#endif
