<div align="center">

# 🧳 Toolcase

**A lightweight macOS menu bar app for power users.**

Built-in system utilities + custom Swift script tools, all accessible from your menu bar with global keyboard shortcuts.

[![Swift](https://img.shields.io/badge/Swift-5.9+-F05138?style=flat-square&logo=swift&logoColor=white)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-macOS%2013+-000?style=flat-square&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)

</div>

## Features

| Tool | Shortcut | Description |
|------|----------|-------------|
| 🎨 **Color Picker** | `⌃⌥P` | Pick any color from the screen: hex code copied to clipboard |
| 📋 **Clipboard History** | `⌃⌥V` | Browse and re-copy your last 10 clipboard entries (text + images) |
| 🎤 **Mic Toggle** | `⌃⌥M` | Mute/unmute your system microphone at the hardware level |
| ⚡ **Custom Tools** | `⌃⌥[key]` | Add your own Swift scripts as tools with optional hotkeys |
| 🚀 **Launch at Startup** | None | Auto-start when you log in |

### Highlights

- **Runs in the menu bar**: no Dock icon, no clutter
- **Global hotkeys** via Carbon API: works in any app, no Accessibility permissions needed
- **Dynamic tool system**: write Swift scripts, assign them hotkeys, run them instantly
- **LLM-friendly**: built-in prompt template to generate tools with ChatGPT, Claude, etc.
- **Searchable**: find any tool instantly with the built-in search bar

## Installation

### 📥 Download (Recommended)

Download the latest version of **Toolcase** from the [Releases](https://github.com/neerajkumarc/toolcase/releases) page. Unzip the file and drag **Toolcase.app** to your `Applications` folder.

### Build from Source

```bash
git clone https://github.com/neerajkumarc/toolcase.git
cd toolcase
open toolcase.xcodeproj
```

Then press `⌘R` in Xcode to build and run.

## Project Structure

```
toolcase/
├── App/                          # App lifecycle
│   ├── ToolcaseApp.swift         # @main entry point + MenuBarExtra scene
│   └── AppDelegate.swift         # Dock hiding + background service bootstrap
│
├── Core/                         # System managers
│   ├── AudioManager.swift        # CoreAudio mic mute/unmute
│   ├── ClipboardManager.swift    # Pasteboard polling + history
│   ├── GlobalHotkeyManager.swift # Carbon RegisterEventHotKey
│   ├── OverlayManager.swift      # Floating toast + clipboard windows
│   └── NSColor+Hex.swift         # NSColor → hex string extension
│
├── Features/                     # Built-in tools (one file per feature)
│   ├── ColorPickerFeature.swift
│   ├── ClipboardHistoryFeature.swift
│   ├── MicToggleFeature.swift
│   └── LaunchAtStartupFeature.swift
│
├── UI/                           # Shared UI components
│   ├── MenuItemView.swift        # Reusable menu row with icon badge
│   ├── SectionHeader.swift       # Uppercase section label
│   ├── ToastView.swift           # Floating toast notifications
│   ├── ClipboardHistoryView.swift # Clipboard history panel
│   └── VisualEffectView.swift    # NSVisualEffectView wrapper
│
├── ContentView.swift             # Main menu bar panel
│   ├── Features.swift            # Feature registry
│   ├── DynamicToolManager.swift  # Custom tool persistence + execution
│   └── AddToolModal.swift        # Add Tool window + icon picker
│
└── Assets.xcassets/              # App assets
```

```
docs/
├── CREATING_FEATURES.md          # Guide: how to add a new built-in feature
└── TOOL_TEMPLATE.md              # LLM prompt template for generating custom tools
```

## Adding Custom Tools

1. Click **"Add Tool"** in the menu bar panel
2. Give your tool a name and icon
3. Write (or paste) a Swift script
4. Optionally assign a keyboard shortcut (`⌃⌥` + key)
5. Click **"Add Tool"**. It's ready to use.

### Generate Tools with AI

Click **"Copy LLM Prompt"** in the Add Tool window, paste it into ChatGPT/Claude, describe what you want, and paste the generated code back.

See [`docs/TOOL_TEMPLATE.md`](docs/TOOL_TEMPLATE.md) for the full prompt template and examples.

## Adding Built-in Features

Want to contribute a new built-in tool? See [`docs/CREATING_FEATURES.md`](docs/CREATING_FEATURES.md) for the full developer guide, including:

- Architecture overview
- Design system (icon badges, typography, row types)
- Step-by-step instructions
- Code templates

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-tool`)
3. Commit your changes (`git commit -m 'feat: add my-tool'`)
4. Push to the branch (`git push origin feature/my-tool`)
5. Open a Pull Request

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

<div align="center">
  <sub>Built with ❤️ by <a href="https://github.com/neerajkumarc">Neeraj Kumar</a></sub>
</div>
