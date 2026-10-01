# Display Layout

[简体中文](README.zh-CN.md)

A native macOS SwiftUI utility for arranging a two-display extended desktop. It moves the secondary display above, below, left, or right of the main display and centers it automatically through CoreGraphics.

## Build and install

```bash
chmod +x bundle.sh
./bundle.sh
```

The script installs `~/Applications/DisplayLayout.app`. The app supports English and Simplified Chinese.

## Behaviour

The utility supports one main display and one secondary display in extended-desktop mode. It changes only the secondary display position; resolution, refresh rate, scaling, and main-display selection remain unchanged. Open **Display Layout → Settings…** to choose language and whether the app quits after applying a layout.

## Requirements and limitations

Requires macOS 14 or later, Xcode Command Line Tools, and exactly two displays in extended mode. Mirrored displays and configurations with more than two displays are intentionally rejected. The app uses local CoreGraphics APIs only and does not access the network.
