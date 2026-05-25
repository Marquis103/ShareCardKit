//
//  MockShareableContent.swift
//
//  Copyright © 2026 ShareCardKit. All rights reserved.
//

import Foundation
import SwiftUI
@testable import ShareCardKit

// MARK: - MockShareableContent

/// Canonical test fixture. Domain-neutral but shaped close enough to a real
/// bill that the snapshot reference PNGs stay credible — title is verbose,
/// breakdown has three segments, status line names a real-sounding date.
struct MockShareableContent: ShareableContent {

    var title: String
    var subtitle: String?
    var badge: String?
    var statusLine: String?
    var breakdownSegments: [ShareableBreakdownSegment]
    var footerURL: URL?
    var accentColor: Color?
    var wordmark: String?

    static let canonical = MockShareableContent(
        title: "Bipartisan Infrastructure Maintenance & Modernization Act of 2026",
        subtitle: "Sen. Patty Murray (D-WA)",
        badge: "H.R. 1234",
        statusLine: "Reported out of Senate Appropriations Committee 2026-03-15",
        breakdownSegments: [
            .init(id: "D", label: "D", count: 12, color: Color(red: 0.20, green: 0.45, blue: 0.85)),
            .init(id: "R", label: "R", count: 8,  color: Color(red: 0.82, green: 0.20, blue: 0.20)),
            .init(id: "I", label: "I", count: 1,  color: Color(red: 0.85, green: 0.66, blue: 0.10))
        ],
        footerURL: URL(string: "https://ayes.app/b/HR1234-119"),
        accentColor: nil,
        wordmark: "AYES"
    )
}
