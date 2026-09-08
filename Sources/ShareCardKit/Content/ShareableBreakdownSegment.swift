//
//  ShareableBreakdownSegment.swift
//
//  Copyright © 2026 ShareCardKit. All rights reserved.
//

#if !os(Android)
import SwiftUI
#endif

// MARK: - ShareableBreakdownSegment

/// A single colored slice in a `ShareableContent`'s breakdown bar / chip row.
///
/// Used to render the data encoding that distinguishes a share card from
/// an opinion piece — e.g., for a U.S. bill: `("D", 12, .blue)`,
/// `("R", 8, .red)`, `("I", 1, .yellow)`. The kit treats segments as opaque
/// data; the caller decides the meaning, count, and color.
public struct ShareableBreakdownSegment: Sendable, Hashable, Identifiable {

    public let id: String

    /// One-letter or short string drawn on the chip (e.g., "D", "R", "I").
    public let label: String

    /// Numeric value. Drives the segment's proportional width in bar layouts
    /// and is drawn as the chip count in chip-row layouts.
    public let count: Int

#if !os(Android)
    /// Display color. Used as the chip background and bar segment fill.
    /// Darwin-only (`SwiftUI.Color`); the W5.6 renderer successors color
    /// segments out-of-band, keyed by segment `id`.
    public let color: Color

    public init(id: String, label: String, count: Int, color: Color) {
        self.id = id
        self.label = label
        self.count = count
        self.color = color
    }
#else
    public init(id: String, label: String, count: Int) {
        self.id = id
        self.label = label
        self.count = count
    }
#endif
}
