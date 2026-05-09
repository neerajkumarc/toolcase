# Toolcase — Create a Custom Tool

Use this template to ask any LLM (ChatGPT, Claude, Gemini, etc.) to generate a tool for Toolcase.

---

## Copy this prompt ↓

```
I'm using a macOS menu bar app called "Toolcase" that lets me add custom tools as Swift scripts.

Each tool is a standalone Swift script that runs via `/usr/bin/swift` on macOS.
The script runs as a regular process (not sandboxed), so it has access to:
- Foundation, Cocoa, AppKit
- NSWorkspace, FileManager, Process, NSPasteboard
- Shell commands via Process()
- Network requests via URLSession
- NSAppleScript for AppleScript

RULES:
1. The script must be a top-level Swift file (no @main, no struct App, no SwiftUI App lifecycle).
2. Import any needed frameworks at the top (e.g. `import Cocoa`, `import Foundation`).
3. The script runs and exits — keep it short and focused.
4. For async work, use DispatchGroup or RunLoop to keep the process alive until done.
5. Use `print()` to output results (they appear in Console.app logs).
6. To copy something to clipboard: `NSPasteboard.general.clearContents(); NSPasteboard.general.setString("value", forType: .string)`
7. To open URLs/files: `NSWorkspace.shared.open(URL(...))`
8. To run shell commands: Use `Process()` with `/bin/zsh` or specific executables.

PLEASE GENERATE A SWIFT SCRIPT THAT DOES THE FOLLOWING:

[DESCRIBE WHAT YOU WANT HERE]

Return ONLY the Swift code, no explanation.
```

---

## Examples

### Example 1: Open a URL
```swift
import Cocoa
NSWorkspace.shared.open(URL(string: "https://github.com")!)
```

### Example 2: Say something with TTS
```swift
import Foundation
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/say")
process.arguments = ["Hello from Toolcase!"]
try? process.run()
process.waitUntilExit()
```

### Example 3: Get your public IP and copy to clipboard
```swift
import Cocoa
let group = DispatchGroup()
group.enter()
let url = URL(string: "https://api.ipify.org")!
URLSession.shared.dataTask(with: url) { data, _, _ in
    if let data = data, let ip = String(data: data, encoding: .utf8) {
        DispatchQueue.main.async {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(ip, forType: .string)
            print("Public IP copied: \(ip)")
        }
    }
    group.leave()
}.resume()
group.wait()
```

### Example 4: Toggle Dark Mode
```swift
import Foundation
let script = """
tell application "System Events"
    tell appearance preferences
        set dark mode to not dark mode
    end tell
end tell
"""
var error: NSDictionary?
if let appleScript = NSAppleScript(source: script) {
    appleScript.executeAndReturnError(&error)
    if let error = error {
        print("Error: \(error)")
    }
}
```

### Example 5: Kill an app by name
```swift
import Cocoa
let appName = "Safari"
let apps = NSRunningApplication.runningApplications(withBundleIdentifier: "")
for app in NSWorkspace.shared.runningApplications {
    if app.localizedName == appName {
        app.terminate()
        print("Terminated \(appName)")
    }
}
```

### Example 6: Empty Trash
```swift
import Foundation
let process = Process()
process.executableURL = URL(fileURLWithPath: "/bin/zsh")
process.arguments = ["-c", "rm -rf ~/.Trash/*"]
try? process.run()
process.waitUntilExit()
print("Trash emptied")
```

### Example 7: Create a timestamped note on Desktop
```swift
import Foundation
let formatter = DateFormatter()
formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
let timestamp = formatter.string(from: Date())
let desktop = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop")
let file = desktop.appendingPathComponent("note_\(timestamp).txt")
try? "Quick note created at \(timestamp)".write(to: file, atomically: true, encoding: .utf8)
print("Note created: \(file.path)")
```

---

## Tips
- Start simple, test, then iterate.
- If something doesn't work, paste the error back to the LLM.
- Scripts have **full system access** — be careful with destructive operations.
- For GUI interactions, use `NSAppleScript` to call AppleScript from Swift.
