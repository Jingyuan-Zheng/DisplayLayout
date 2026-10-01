# 显示器布局

[English](README.md)

原生 macOS SwiftUI 双显示器布局工具。它通过 CoreGraphics 将副显示器移动到主显示器的上、下、左或右侧，并自动居中。

## 构建与安装

```bash
chmod +x bundle.sh
./bundle.sh
```

脚本会安装 `~/Applications/DisplayLayout.app`；应用支持英文和简体中文。

## 行为

此工具支持一个主显示器和一个处于扩展桌面模式的副显示器。它只修改副显示器的位置，不会改变分辨率、刷新率、缩放或主显示器选择。通过 **Display Layout → Settings…** 可切换语言和设置应用布局后是否退出。

## 要求与限制

需要 macOS 14 及以上、Xcode Command Line Tools，以及恰好两块处于扩展模式的显示器。镜像模式和多于两块显示器的配置会被明确拒绝。应用只调用本地 CoreGraphics API，不访问网络。
