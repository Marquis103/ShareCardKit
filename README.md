# ShareCardKit

SwiftUI `ImageRenderer` wrapper that produces multi-size, social-native share cards (Twitter, Instagram Square / Story, OG / Facebook, in-app square) from any SwiftUI view or any value conforming to `ShareableContent`.

Built so a share card posted to a feed can stand on its own as "source of truth" content — credible to a reader who's never installed the app.

## Install

```swift
.package(url: "https://github.com/Marquis103/ShareCardKit", from: "1.0.0")
```

```swift
import ShareCardKit
```

## Quick start — your own view

```swift
let renderer = ShareCardRenderer()

let card = await renderer.render(MyBillCardView(bill: bill), size: .twitter)
// card.cgImage, card.data (PNG by default), card.size, card.scale, card.variant

let socialSet = await renderer.renderSocialSet(MyBillCardView(bill: bill))
// → [ShareCardSize: ShareCardImage] with one image per .socialSet entry
```

## Quick start — built-in layout

Conform your domain type to `ShareableContent` and the kit composes an aspect-adaptive layout per size:

```swift
struct BillShareableContent: ShareableContent {
    let bill: Bill

    var title: String       { bill.title }
    var subtitle: String?   { bill.primarySponsor?.displayName }   // "Sen. Patty Murray (D-WA)"
    var badge: String?      { bill.billId }                        // "H.R. 1234"
    var statusLine: String? { bill.statusLine }                    // "Reported out of committee 2026-03-15"
    var footerURL: URL?     { URL(string: "https://ayes.app/b/\(bill.billId)") }
    var wordmark: String?   { "Ayes" }

    var breakdownSegments: [ShareableBreakdownSegment] {
        [
            .init(id: "D", label: "D", count: bill.democrats, color: .blue),
            .init(id: "R", label: "R", count: bill.republicans, color: .red),
            .init(id: "I", label: "I", count: bill.independents, color: .yellow)
        ]
    }
}

let renderer = ShareCardRenderer()
let set = await renderer.renderSocialSet(BillShareableContent(bill: bill))
```

## Sizes

| Case                  | Pixels (logical) | Aspect | Use                  |
|-----------------------|------------------|--------|----------------------|
| `.twitter`            | 1200 × 675       | 16:9   | Twitter / X cards    |
| `.openGraph`          | 1200 × 630       | ~1.9:1 | OG previews, Facebook|
| `.square`             | 1200 × 1200      | 1:1    | In-app share sheet   |
| `.instagramSquare`    | 1080 × 1080      | 1:1    | IG feed              |
| `.instagramStory`     | 1080 × 1920      | 9:16   | IG / FB / TT stories |
| `.custom(CGSize)`     | caller-defined   | any    | Escape hatch         |

`ShareCardSize.socialSet` returns the five named sizes for `renderSocialSet`.

Every render is `@3x` by default — pass `scale:` to `ShareCardRenderer(init:)` to override.

## Aspect-adaptive contract

The built-in `DefaultShareCardLayout` dispatches on `ShareCardSize.layoutAxis`:

| Axis      | Sizes                          | Composition                                                         |
|-----------|--------------------------------|---------------------------------------------------------------------|
| `.wide`   | `.twitter`, `.openGraph`       | Title + subtitle on left ~⅔; breakdown bar + wordmark on right ~⅓.  |
| `.square` | `.square`, `.instagramSquare`  | Stacked: badge → title → subtitle → breakdown chips → status → URL. |
| `.tall`   | `.instagramStory`              | Top third: badge + title. Middle: breakdown bar + negative space. Bottom third: status + URL + wordmark. |

If the default layouts don't fit a specific use, pass your own `View` to `render(_:size:)`. The kit guarantees the output dimensions; the view owns aspect adaptation.

## Light + Dark

```swift
let renderer = ShareCardRenderer(
    options: ShareCardRenderOptions(appearance: .dark, format: .jpeg(quality: 0.92))
)
```

Default is light — social feeds read it more consistently against varied backgrounds. Dark is available for users who share from a dark UI.

## Output

`ShareCardImage` carries both the `CGImage` (for handing to `ShareLink` / `UIActivityViewController`) and the encoded `Data` (PNG by default, JPEG with quality on request). `size` is the logical pixel size; multiply by `scale` for the on-disk pixel dimensions.

## Snapshot tests

The kit's own test target validates the default layouts at every size × Light/Dark with `swift-snapshot-testing`. Run via Xcode against an iOS Simulator. Reference PNGs live under `Tests/ShareCardKitTests/__Snapshots__/` and are committed to the repo; rerun with `isRecording = true` (or delete the offending PNG) to regenerate after an intentional layout change.

## License

Copyright © 2026 ShareCardKit. All rights reserved.
