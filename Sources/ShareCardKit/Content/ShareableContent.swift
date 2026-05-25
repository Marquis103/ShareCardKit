//
//  ShareableContent.swift
//
//  Copyright © 2026 ShareCardKit. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - ShareableContent

/// The portable data shape consumed by `DefaultShareCardLayout`. Any
/// domain type can conform; the kit doesn't prescribe what `title` or
/// `breakdownSegments` mean.
///
/// Only `title` is required — every other field has a default of `nil`
/// (or empty) so callers can adopt incrementally.
///
/// ```swift
/// struct BillShareableContent: ShareableContent {
///     let bill: Bill
///     var title: String       { bill.title }
///     var subtitle: String?   { bill.primarySponsor?.displayName }
///     var badge: String?      { bill.billId }
///     var statusLine: String? { bill.statusLine }
///     var footerURL: URL?     { URL(string: "https://ayes.app/b/\(bill.billId)") }
///     var wordmark: String?   { "Ayes" }
///     var breakdownSegments: [ShareableBreakdownSegment] { [
///         .init(id: "D", label: "D", count: bill.democrats, color: .blue),
///         .init(id: "R", label: "R", count: bill.republicans, color: .red),
///         .init(id: "I", label: "I", count: bill.independents, color: .yellow)
///     ] }
/// }
/// ```
public protocol ShareableContent: Sendable {

    /// Headline. The only required field. Wraps to 2–3 lines in the default
    /// layouts before truncating.
    var title: String { get }

    /// Attribution / byline. Renders as a single line beneath the title.
    /// Example: "Sen. Patty Murray (D-WA)".
    var subtitle: String? { get }

    /// Identifier badge drawn in a pill above (or before) the title.
    /// Example: "H.R. 1234".
    var badge: String? { get }

    /// Procedural / state line. One short sentence; truncates if long.
    /// Example: "Reported out of committee 2026-03-15".
    var statusLine: String? { get }

    /// Data encoding rendered as either a horizontal bar (wide / tall axes)
    /// or a chip row (square axis). Empty hides the row entirely.
    var breakdownSegments: [ShareableBreakdownSegment] { get }

    /// Footer URL printed verbatim — typically the share URL the receiver
    /// will open. Hidden if `nil`.
    var footerURL: URL? { get }

    /// Optional accent color used for the badge pill and the title's
    /// emphasis underline. Defaults to neutral when `nil`.
    var accentColor: Color? { get }

    /// App wordmark printed near the footer (and on the right rail in
    /// `.wide` layouts). Hidden if `nil`.
    var wordmark: String? { get }
}

// MARK: - Defaults

public extension ShareableContent {
    var subtitle: String? { nil }
    var badge: String? { nil }
    var statusLine: String? { nil }
    var breakdownSegments: [ShareableBreakdownSegment] { [] }
    var footerURL: URL? { nil }
    var accentColor: Color? { nil }
    var wordmark: String? { nil }
}
