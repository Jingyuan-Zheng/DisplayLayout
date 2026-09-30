# Display Layout / 显示器布局

[English](#english) · [中文](#中文)

## English

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
- App icon: bundled at `Resources/ApplicationStub.icns`; no local application dependency is required.

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

## 中文

原生 macOS SwiftUI 双显示器布局工具，可将副显示器移动到主显示器的上、下、左或右侧，并自动居中。它直接使用 CoreGraphics，不依赖 Homebrew、后台守护进程或 `displayplacer`。

### 构建与安装

```bash
cd /path/to/DisplayLayout
chmod +x bundle.sh
./bundle.sh
```

构建脚本会安装 `~/Applications/DisplayLayout.app`。应用支持英文和简体中文；可通过 **Display Layout → Settings…** (`⌘,`) 切换语言和“应用后退出”选项。

图标已包含在 `Resources/ApplicationStub.icns`，构建不依赖本机其他应用。
