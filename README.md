# Display Layout

A small native macOS SwiftUI utility for arranging a two-display extended desktop.

## What this build does

- Shows the current two-display arrangement visually.
- Moves the secondary display **above, below, left, or right** of the main display.
- Centers the secondary display along the shared axis automatically.
- Uses CoreGraphics directly; no Homebrew, shell helper, daemon, or `displayplacer` is required at runtime.
- Uses a normal macOS application lifecycle: it appears in the **Dock**, uses the **standard application menu bar**, and participates in **Mission Control**.
- Brings the main window to the front once at launch, then returns it to normal window level so it does not stay always-on-top.
- Uses the standard SwiftUI `Settings` scene, so macOS automatically provides **Display Layout → Settings…**.
- Default GUI language: **English**.
- In-app languages: **English** and **Simplified Chinese**.
- Uses standard `.lproj/Localizable.strings` localization resources.
- App icon at build time: macOS's built-in Finder icon.

## Build and install

On the target Mac:

```bash
cd /path/to/DisplayLayout
chmod +x bundle.sh
./bundle.sh
```

The script builds and installs:

```text
~/Applications/DisplayLayout.app
```

Then launch it with Finder, Spotlight, or:

```bash
open ~/Applications/DisplayLayout.app
```

## Settings

Open the standard macOS application menu:

**Display Layout → Settings…** (`⌘,`)

You can change:

- Language
- Quit after applying a layout

The app defaults to English even if the system language is different.

## Window behavior

At launch the main window is activated and briefly raised above normal windows to make it easy to find. It then returns to the normal window level. Clicking another application therefore behaves normally and Display Layout does not remain on top.

The app uses `NSApplication.ActivationPolicy.regular` and a managed normal window, so it is discoverable from the Dock and Mission Control.

## Source / attribution

The project was derived from ideas and CoreGraphics display-arrangement work in DisplayAlign. See `NOTICE.md` and `LICENSE-DISPLAYALIGN` for attribution and the MIT license notice.
