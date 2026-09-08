# ShareCardKit portability — Android (Skip Fuse)

Written for Ayes Android Phase 4, increment W2.7 (`docs/architecture/android-phase4/W2-kits.md`
in the Ayes repo). This file is the authoritative record of what is portable, what is
Darwin-gated, and what each gated surface's Android successor is.

## No manifest gate — but a resolution floor

There is no `SKIP_ANDROID` bimodal manifest (PageKit/PermissionsKit pattern): this kit has
no skip imports, no skipstone plugin, no `skip.yml`. The module is plain Swift on the
Android triple.

W2.7 added **`.macOS(.v14)`** to `platforms:`. This is **resolution-only**: the Skip Android
graph's macOS-26 host tooling resolves every package for macOS, and the kit's implicit
10.13 floor failed against swift-snapshot-testing's 10.15. The kit still does **not**
compile for macOS (UIKit/`ImageRenderer` paths) — accepted precedent (AyesCoreUI, W1);
iOS consumers are unaffected.

## The value type — the W3.1 cross-wave contract

`ShareCardImage` is the rendered-card value type. Its **portable core is identical on
every platform**:

```swift
public struct ShareCardImage: Sendable {
    public let data: Data              // encoded bytes (PNG/JPEG per render options)
    public let size: CGSize            // logical pixels (on-disk = size × scale)
    public let scale: CGFloat
    public let variant: ShareCardSize
}
```

- **Darwin adds** `public let cgImage: CGImage` and the existing 5-arg initializer
  `init(cgImage:data:size:scale:variant:)` — non-optional, byte-compatible with 1.0.0
  (Ayes' snapshot helper reads `cgImage` non-optionally).
- **Android adds** `init(data:size:scale:variant:)` — producers there supply encoded
  bytes (server-side render, or a Compose bitmap bridge that encodes first).
- **W3.1 adopts this type**: `SharePayload.image: UIImage` in `Modules/FeatureBills`
  becomes `ShareCardImage`; the Darwin share-sheet path reconstructs `UIImage` from
  `cgImage` at the presenter boundary (exactly what `ShareCardService` does today), and
  the upload path already consumes `.data`.

## What is portable

- **`ShareCardRendering`** (new in W2.7) — the renderer seam. Two requirements
  (`render(_:size:)`, `renderSet(_:sizes:)`) over `ShareableContent`, plus
  `renderSocialSet` as an extension convenience. Conformers must be `@MainActor`
  classes (a plain `actor` cannot satisfy MainActor-isolated requirements).
- **`ShareableContent`** — seven of eight requirements (all but `accentColor`).
- **`ShareableBreakdownSegment`** — `id`/`label`/`count` (+ `Hashable`/`Identifiable`).
- **`ShareCardImage`** portable core (above), **`ShareCardSize`** (incl. `.custom`,
  `socialSet`, `layoutAxis`), **`LayoutAxis`**, **`ShareCardRenderOptions`**.
- CG geometry (`CGSize`/`CGFloat`) comes through **Foundation** on every platform;
  `import CoreGraphics` does not resolve off-Darwin, so the geometry-only files import
  Foundation (byte-identical types on Darwin).

## What is gated, and the successor

| Surface | Frameworks | Android status |
|---|---|---|
| `Rendering/ShareCardRenderer.swift` (whole file) | SwiftUI `ImageRenderer`, UIKit (`UIImage` PNG/JPEG encoding) | **Successor: server-side render adapter (primary) / Compose bitmap bridge (fallback) behind `ShareCardRendering`, W5.6** |
| `Layouts/*.swift` — 4 files, incl. the internal style/badge/bar/chip components | SwiftUI | Same successor — the server render owns layout on Android (and, if adopted, on iOS too) |
| `ShareableContent.accentColor` + `ShareableBreakdownSegment.color` (+ its 4-arg init) | SwiftUI `Color` | Darwin-only. W5.6 successors take accent/segment styling out-of-band, keyed by segment `id` |
| `ShareCardImage.cgImage` + the 5-arg init | CoreGraphics | Darwin-only hand-off convenience |

## Behavioral notes / deltas

- `accentColor` is **unconsumed by the kit's own layouts** (the `ShareCardStyle` tokens
  win) — retained and gated purely for source compatibility with existing conformers.
- `ShareableBreakdownSegment`'s synthesized `Hashable`/`Equatable` includes `color` on
  Darwin and excludes it on Android — consistent per platform.
- A Darwin test double of `ShareCardRendering` needs a `CGImage` to build a
  `ShareCardImage` (trivial via a 1×1 `CGContext`); a Darwin `init(data:…)` convenience
  can be added later if W3 wants one — deliberately not added in W2.7.

## Verification performed (W2.7)

- `xcodebuild test -scheme ShareCardKit -destination 'platform=iOS Simulator,id=<iPhone 16 Plus>'`:
  **22/22** (3 suites) including all 10 committed snapshot references — baseline before
  W2.7 was 21/21 on the same simulator; the +1 is the new protocol-seam test. (`swift test`
  does not apply: the suite needs an iOS simulator, and the kit does not build for macOS.)
- Grep proof: every `import SwiftUI` / `import UIKit` / `import CoreGraphics` in `Sources/`
  sits inside `#if !os(Android)`; `ShareCardRendering.swift` imports Foundation only.
- Android compile: the kit builds for the Android triple inside the Ayes `AyesApp/` Skip
  Fuse graph via an uncommitted path override (`gradle assembleDebug`, W2.7 PR evidence).
- Darwin surface: every existing declaration byte-identical; additions only
  (`ShareCardRendering`, the conformance, the Android-only initializer, the macOS floor).
