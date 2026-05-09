# Creating a New Feature for Toolcase

This guide explains how to add a new feature/control to the Toolcase menu bar app.

## Architecture Overview

```
toolcase/
├── toolcaseApp.swift          # App entry point + system managers (AudioManager, ClipboardManager, GlobalHotkeyManager, OverlayManager)
├── ContentView.swift      # Main menu bar UI — sectioned layout with Tools + Settings
├── Features.swift         # Shared components: MenuItemView, SectionHeader, FeatureRegistry, NSColor extension
└── Features/              # ← Each feature lives here as its own file
    ├── ColorPickerFeature.swift      # Action-based feature (button row)
    ├── ClipboardHistoryFeature.swift  # Action-based feature (button row + badge)
    ├── MicToggleFeature.swift        # Toggle-based feature (switch row)
    └── LaunchAtStartupFeature.swift  # App control with toggle (lives in Settings section)
```

## UI Layout Structure

The menu bar panel has this sectioned layout:

```
┌──────────────────────────────┐
│  🧳 Toolcase                v1.0│  ← App Header (gradient icon + version pill)
│                              │
│  🔍 Search tools...         │  ← Rounded search bar with clear button
│                              │
│  TOOLS                       │  ← Section header (uppercase, tracked)
│  ┌──────────────────────────┐│
│  │ 🟦 Color Picker    ⌃⌥P ││  ← Action row (icon badge + shortcut)
│  │ 🟧 Clipboard Hist  ⌃⌥V ││  ← Action row (icon badge + count badge)
│  │ 🟩 Microphone      🔘  ││  ← Toggle row (icon badge + switch)
│  └──────────────────────────┘│
│                              │
│  SETTINGS                    │  ← Section header
│  ┌──────────────────────────┐│
│  │ 🟪 Launch at Start  🔘 ││  ← Toggle row (icon badge + switch)
│  │ 🟥 Quit Toolcase        ⌘Q ││  ← Action row (red icon badge)
│  └──────────────────────────┘│
└──────────────────────────────┘
```

**Key distinction:**
- **Tools** = Features that do something (registered in `FeatureRegistry`)
- **Settings** = App controls (hardcoded in `ContentView.swift`, NOT in the registry)

---

## Design System

### Icon Badges

Every row uses a colored icon badge — an SF Symbol on a rounded rect gradient background:

```swift
Image(systemName: "eyedropper")
    .font(.system(size: 12, weight: .semibold))
    .foregroundColor(.white)
    .frame(width: 28, height: 28)
    .background(
        RoundedRectangle(cornerRadius: 7, style: .continuous)
            .fill(Color.blue.gradient)   // ← Each feature has its own color
    )
```

**Assigned icon colors:**

| Feature           | Icon              | Color       |
|-------------------|-------------------|-------------|
| Color Picker      | `eyedropper`      | `.blue`     |
| Clipboard History | `list.clipboard`  | `.orange`   |
| Microphone Toggle | `mic.fill`        | `.green` / `.red` (dynamic) |
| Launch at Startup | `sunrise.fill`    | `.indigo`   |
| Quit              | `power`           | `.red`      |

When adding a new feature, pick a distinct color that doesn't conflict with existing ones. Good options: `.teal`, `.pink`, `.mint`, `.cyan`, `.brown`, `.yellow`.

### Typography

| Element          | Font                                              |
|------------------|---------------------------------------------------|
| Row title        | `.system(size: 13, weight: .medium)`              |
| Shortcut badge   | `.system(size: 10, weight: .medium, design: .monospaced)` |
| Section header   | `.system(size: 10, weight: .semibold)` + `.tracking(0.8)` + uppercase |
| Count badge      | `.system(size: 10, weight: .bold, design: .rounded)` |
| App title        | `.system(size: 15, weight: .bold, design: .rounded)` |
| Version pill     | `.system(size: 10, weight: .medium, design: .rounded)` |

### Two Row Types

#### 1. Action Row (uses `MenuItemView`)

For features triggered by clicking — color picker, clipboard history, quit:

```swift
MenuItemView(
    title: "Feature Name",
    icon: "sf.symbol.name",
    iconColor: .blue,              // ← Gradient badge color
    shortcutText: "⌃⌥X",         // ← Optional shortcut label
    action: performAction
) {
    // Trailing content: badges, status text, color swatches, etc.
}
```

#### 2. Toggle Row (custom inline layout)

For features with on/off state — microphone, launch at startup:

```swift
HStack(spacing: 12) {
    // Icon badge (same style as action rows)
    Image(systemName: "your.icon")
        .font(.system(size: 12, weight: .semibold))
        .foregroundColor(.white)
        .frame(width: 28, height: 28)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.teal.gradient)
        )
    
    // Label + optional shortcut
    VStack(alignment: .leading, spacing: 1) {
        Text("Feature Name")
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.primary)
        
        Text("⌃⌥X")   // optional
            .font(.system(size: 10, weight: .medium, design: .monospaced))
            .foregroundColor(.secondary.opacity(0.7))
    }
    
    Spacer()
    
    // Native macOS toggle switch
    Toggle("", isOn: $yourBinding)
        .toggleStyle(.switch)
        .labelsHidden()
        .controlSize(.small)
}
.padding(.horizontal, 10)
.padding(.vertical, 8)
.contentShape(Rectangle())
```

### Hover Effects

Action rows use animated opacity hover:
```swift
.background(
    RoundedRectangle(cornerRadius: 8, style: .continuous)
        .fill(isHovered ? Color.primary.opacity(0.06) : Color.clear)
)
.onHover { hovering in
    withAnimation(.easeInOut(duration: 0.15)) {
        isHovered = hovering
    }
}
```

### Count / Status Badges

Circular count badge (e.g., clipboard items):
```swift
Text("\(count)")
    .font(.system(size: 10, weight: .bold, design: .rounded))
    .foregroundColor(.white)
    .frame(width: 20, height: 20)
    .background(Circle().fill(Color.orange.opacity(0.8)))
```

Shortcut pill badge (e.g., ⌘Q on Quit):
```swift
Text("⌘Q")
    .font(.system(size: 10, weight: .medium, design: .monospaced))
    .foregroundColor(.secondary.opacity(0.5))
    .padding(.horizontal, 5)
    .padding(.vertical, 2)
    .background(
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(Color.secondary.opacity(0.08))
    )
```

---

## Step-by-Step: Add a New Feature

### 1. Create the Feature File

Create a new Swift file inside `toolcase/Features/` named `YourFeatureNameFeature.swift`.

**Action-based feature template:**

```swift
import SwiftUI

// MARK: - Your Feature Name
// Brief description of what this feature does
// Shortcut: ⌃⌥X (if applicable)

struct YourFeatureMenuItem: View {
    // Add any @State or @ObservedObject properties here

    var body: some View {
        MenuItemView(
            title: "Your Feature Title",
            icon: "star",                       // SF Symbol name
            iconColor: .teal,                   // Pick a unique color
            shortcutText: "⌃⌥X",              // Optional shortcut label
            action: performAction
        ) {
            // Trailing content (right side of the row)
            // Examples: status text, badge, color swatch, etc.
        }
    }

    private func performAction() {
        // Your feature logic here
        // Optionally show a toast:
        // OverlayManager.shared.showToast(icon: "star.fill", iconColor: .yellow)
    }
}
```

**Toggle-based feature template:**

```swift
import SwiftUI

// MARK: - Your Toggle Feature
// Brief description

struct YourToggleMenuItem: View {
    @State private var isEnabled = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isEnabled ? "icon.fill" : "icon")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill((isEnabled ? Color.green : Color.gray).gradient)
                )

            VStack(alignment: .leading, spacing: 1) {
                Text("Feature Name")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                Text("⌃⌥X")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary.opacity(0.7))
            }

            Spacer()

            Toggle("", isOn: $isEnabled)
                .toggleStyle(.switch)
                .labelsHidden()
                .controlSize(.small)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}
```

### 2. Register in FeatureRegistry

Open `toolcase/Features.swift` and add an entry to the `FeatureRegistry.all` array:

```swift
static let all: [FeatureEntry] = [
    // ... existing entries ...

    FeatureEntry(
        id: "your-feature",                              // Unique ID
        title: "Your Feature Title",                      // Must match the view title
        keywords: ["keyword1", "keyword2", "keyword3"],   // Search terms
        view: AnyView(YourFeatureMenuItem())              // Wrap your view
    ),
]
```

> **Note:** Only add features to `FeatureRegistry`. App controls (like Launch at Startup, Quit) go directly in `ContentView.swift` under the "Settings" section.

### 3. (Optional) Add a Global Hotkey

Global hotkeys use the **Carbon `RegisterEventHotKey` API** — this works system-wide regardless of which app is focused, with no Accessibility permissions required.

In `toolcaseApp.swift`:

**a) Add a hotkey ID constant (top of file, near existing ones):**
```swift
private let kHotkeyYourFeature: UInt32 = 4  // increment from last ID
```

**b) Add to the callback switch:**
```swift
case kHotkeyYourFeature:
    DispatchQueue.main.async { /* trigger your feature */ }
```

**c) Register the hotkey in `registerCarbonHotkeys()`:**
```swift
// Register ⌃⌥X — Your Feature (use the correct kVK_ANSI_* keycode)
registerHotkey(id: kHotkeyYourFeature, keyCode: UInt32(kVK_ANSI_X), modifiers: modifiers, signature: signature)
```

**Common Carbon keycodes (`Carbon.HIToolbox`):**
| Key | Constant        |
|-----|-----------------|
| A   | `kVK_ANSI_A`   |
| B   | `kVK_ANSI_B`   |
| ... | `kVK_ANSI_*`   |
| 1   | `kVK_ANSI_1`   |

### 4. (Optional) Show a Toast Notification

Use the OverlayManager to show an icon-only toast:

```swift
OverlayManager.shared.showToast(icon: "checkmark.circle.fill", iconColor: .green)
```

### 5. (Optional) Show a Floating Window

If your feature needs a modal/panel (like Clipboard History), use `OverlayManager` as a pattern — create a new `NSWindow` in `OverlayManager` with your custom SwiftUI view.

---

## Available Shared Components

| Component | Description |
|-----------|-------------|
| `MenuItemView` | Reusable action row with icon badge, title, trailing content, shortcut label, and hover effect |
| `SectionHeader` | Uppercase tracked section label (e.g., "TOOLS", "SETTINGS") |
| `OverlayManager.shared.showToast(icon:iconColor:)` | Show a floating icon-only toast at the bottom of the screen |
| `OverlayManager.shared.showClipboardHistory()` | Example of showing a floating window |
| `AudioManager.shared` | Manages system microphone mute state |
| `ClipboardManager.shared` | Tracks clipboard history (last 5 items) |

## SF Symbols Reference

Use any SF Symbol name for icons. Common ones:
- `"star"`, `"gear"`, `"bell"`, `"wifi"`, `"lock"`, `"eye"`
- `"moon"`, `"sun.max"`, `"bolt"`, `"arrow.clockwise"`
- `"doc.on.doc"`, `"trash"`, `"folder"`, `"pencil"`

Browse all symbols: https://developer.apple.com/sf-symbols/

## Keyboard Shortcut Convention

All global shortcuts use **⌃⌥ (Control + Option)** to avoid conflicts with other apps.  
Format for display: `"⌃⌥X"` where X is the letter key.

## Checklist

- [ ] Created `Features/YourFeatureFeature.swift`
- [ ] Chose the correct row type: **Action** (`MenuItemView`) or **Toggle** (inline `HStack` + `Toggle`)
- [ ] Picked a unique `iconColor` that doesn't conflict with existing features
- [ ] Added `FeatureEntry` to `FeatureRegistry.all` in `Features.swift` (features only, NOT app controls)
- [ ] Added search keywords that users might type
- [ ] (Optional) Added global hotkey via `RegisterEventHotKey` in `GlobalHotkeyManager`
- [ ] (Optional) Added toast feedback for the action
