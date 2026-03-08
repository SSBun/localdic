# How to Hide Title Bar and Make Content Cover Full Window in macOS

This guide explains how to create a macOS app with a hidden title bar where the content view fully covers the entire window, including the title bar area.

## Overview

By default, macOS apps have a standard title bar with traffic light buttons (close, minimize, zoom). Sometimes you may want to:
- Hide the title bar
- Extend the content view to cover the entire window
- Have traffic lights float above your content

## Solution

### 1. AppDelegate Configuration

The key is to configure the `NSWindow` in the AppDelegate to enable full-size content view and transparency.

```swift
import SwiftUI
import AppKit

@main
struct YourApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                // Enable full size content view - allows content to extend to title bar area
                window.styleMask.insert(.fullSizeContentView)

                // Make title bar transparent
                window.titlebarAppearsTransparent = true

                // Hide title text
                window.titleVisibility = .hidden

                // Make window transparent
                window.isOpaque = false
                window.backgroundColor = .clear

                // Optionally hide zoom button
                window.standardWindowButton(.zoomButton)?.isHidden = true
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
```

### 2. Content View Configuration

In your ContentView, use `.edgesIgnoringSafeArea(.top)` to extend content to the top of the window.

```swift
struct ContentView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Your background (blur, color, etc.)
            YourBackgroundView()
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Your custom top bar (optional)
                CustomTopBar()

                // Main content
                MainContent()

                // Bottom bar
                BottomBar()
            }
            .frame(maxHeight: .infinity)
            .edgesIgnoringSafeArea(.top) // Extend to top, keep bottom default
        }
    }
}
```

## Key Concepts

| Property | Description |
|----------|-------------|
| `.fullSizeContentView` | Allows content to extend into the title bar area |
| `titlebarAppearsTransparent` | Makes title bar background transparent |
| `titleVisibility = .hidden` | Hides the title text |
| `isOpaque = false` | Makes window non-opaque |
| `backgroundColor = .clear` | Sets transparent background |
| `.edgesIgnoringSafeArea(.top)` | SwiftUI modifier to extend content to top edge |

## Complete Example

```swift
import SwiftUI
import AppKit

@main
struct YourApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                window.styleMask.insert(.fullSizeContentView)
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.isOpaque = false
                window.backgroundColor = .clear
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        ZStack {
            // Full window background
            Color.blue.ignoresSafeArea(.all)

            VStack {
                // Custom header (traffic lights area)
                Text("App Title")
                    .padding(.top, 13)

                Spacer()

                // Main content
                Text("Hello World")

                Spacer()
            }
        }
    }
}
```

## Notes

- Traffic lights (close, minimize, zoom buttons) will float above your content
- The traffic lights remain functional even with title bar hidden
- You can create a custom header bar that aligns with traffic lights using a 28pt height
- Use `.edgesIgnoringSafeArea(.top)` to extend content to the top while keeping bottom safe area respected

## Visual Effect Background (Optional)

To add a blur effect background like macOS native apps:

```swift
struct VisualEffectBackground: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// Usage
VisualEffectBackground(material: .hudWindow, blendingMode: .behindWindow)
    .ignoresSafeArea(.all)
```

Available materials:
- `.hudWindow` - HUD window style blur
- `.sidebar` - Sidebar style blur
- `.windowBackground` - Standard window blur
- `.fullScreenUI` - Full screen UI blur

## Summary

The key steps are:
1. Set `.windowStyle(.hiddenTitleBar)` in SwiftUI
2. Configure `NSWindow` in AppDelegate to enable fullSizeContentView and transparency
3. Use `.edgesIgnoringSafeArea(.top)` in your content view to extend to the top
