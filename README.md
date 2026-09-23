# BetterTheaterMode — Safari Extension

Makes the video **fill the entire Safari window** when YouTube's theater mode is
active. The top bar (search/header) and the title strip that normally peek in
around the player are covered by the player, and the video letterboxes (never
crops) when the window shape doesn't match 16:9.

- Toolbar button toggles the behavior on/off (on by default, remembered).
- Regular (non-theater) pages, the homepage, and true fullscreen are untouched.
- Scrolling still works in theater mode, exactly like stock YouTube.

## Repository layout

One git repository: `github.com/dsun05/BetterTheaterMode`.

```
BetterTheaterMode.xcodeproj           Xcode project (at the repo root)
AppIcon.icon/                          App icon (macOS 26 Icon Composer format)
BetterTheaterMode/                    Container app target
  BetterTheaterModeApp.swift          SwiftUI app hosting the status window
  Resources/Icon.png                   Icon shown in the helper window
BetterTheaterMode Extension/          Safari extension target
  Resources/                           ← the web extension itself:
    manifest.json, content.css, content.js, background.js, icons/
```

> Edit the extension's behavior in
> `BetterTheaterMode Extension/Resources/content.css` —
> that copy is what the app builds from.

## How it works

When `ytd-watch-flexy` has the `theater` attribute, `content.css`:

1. hides `#masthead-container` and zeroes `#page-manager`'s top margin,
2. stretches `#full-bleed-container` (today's theater player wrapper) to
   `100vh`, along with every wrapper down to `.html5-video-container`,
3. forces the `<video>` to `100% × 100%` with `object-fit: contain`, beating
   the inline sizes YouTube's player JS writes (which use `object-fit: cover`
   against the *old* container size).

All rules are gated on an `html.ytf-on` class that `content.js` manages and
`background.js` toggles from the toolbar button, so clicking it switches the
behavior instantly with no reload. Selectors were verified against YouTube's
live DOM in September 2026 (`#player-theater-container` no longer exists; the
theater player is `#full-bleed-container`).

## LLM Disclosure

This project was wholly coded by GLM 5.3 with human planning, direction, and
supervision.

## License

[MIT](LICENSE)
