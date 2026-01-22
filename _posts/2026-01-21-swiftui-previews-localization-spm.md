---
title: "How to Fix SwiftUI Preview Localization in Swift Package Manager (SPM)"
categories: swiftui spm localization
excerpt: How to fix SwiftUI preview localization in Swift Package Manager (SPM).
---

If you're building modular iOS apps with **Swift Package Manager (SPM)**, you've likely hit a frustrating wall: **SwiftUI previews** can't access localization resources from **String Catalogs** (`.xcstrings` files). Setting `.environment(\.locale)` in **Xcode previews** doesn't work, and your previews stubbornly display keys instead of localized strings.

This project provides a lightweight, **type-safe localization** solution that works seamlessly with **SwiftUI previews** in SPM modules—no **SwiftGen**, no code generation, just pure Swift.

<img src="{{ site.url }}/assets/posts/2026-01-21-swiftui-previews-localization-spm/preview-blog-video-10fps.gif">

## The Problem

When you move your localization resources to an **SPM module**, three issues emerge:

1. **SwiftUI previews** can't resolve `Bundle.module` in the preview context
2. The `.environment(\.locale)` modifier doesn't help with **Xcode preview** localization
3. Your **Localizable.xcstrings** strings become inaccessible during development

> **Technical Note:** At build time, Xcode compiles `.xcstrings` String Catalogs into traditional `.lproj` bundle directories—the same runtime format iOS has used for years. The problem isn't the String Catalog format itself, but how **SPM modules** package and resolve these compiled resources during preview runtime.

Existing solutions like **SwiftGen** or **R.swift** require build phases, configuration files, and code generation—adding complexity to your Swift Package Manager workflow.

## The Solution: Two Problems, One Approach

This project solves both **preview localization** and **type safety** with a simple wrapper pattern.

### Problem 1: SwiftUI Preview Localization in SPM

A custom preview language override system that works directly with **String Catalogs**:

```swift
#Preview("Spanish") {
  LocalizableString.setPreviewLanguage(.spanish)
  return AppContentView()
}

#Preview("English") {
  LocalizableString.setPreviewLanguage(.english)
  return AppContentView()
}
```

The `PreviewLocalization` system intercepts string lookups in debug mode and redirects them to the correct **Bundle.module** resource, making **SwiftUI internationalization** work in previews without any `.environment` hacks.

### Problem 2: Type-Safe iOS Localization

Instead of scattered string literals, organize **localized strings** by feature with compile-time safety:

```swift
extension LocalizableString {
  enum AppFeature {
    static let greeting = LocalizableString(
      "app.greeting",
      comment: "Main greeting shown on app launch"
    )
    static let welcomeMessage = LocalizableString(
      "app.welcome_message",
      comment: "Welcome message for new users"
    )
  }
}

// Usage in SwiftUI:
Text(LocalizableString.AppFeature.greeting.localized())
```

No more typos in your **xcstrings** keys. No more searching for where strings are used. Just static, discoverable, type-safe localization.

## Why Not SwiftGen?

**SwiftGen** is powerful, but it requires:
- External dependencies
- Build phase scripts
- Generated code that can become stale
- Complex configuration for **Swift Package Manager** projects

This solution is pure Swift:
- Works directly with **String Catalogs** (no intermediate generation)
- No build phases or external tools
- Simple to maintain in SPM-based architectures
- Full compile-time safety without code generation

## Implementation

The complete implementation is available at [github.com/rcaos/SwiftUI-Localization-Demo](https://github.com/rcaos/SwiftUI-Localization-Demo).

**Key files to review:**
- `Sources/LocalizedStrings/LocalizableString.swift` - Type-safe wrapper
- `Sources/LocalizedStrings/PreviewLocalization.swift` - Preview override system  
- `Sources/AppFeature/AppContentView.swift` - Usage examples

## Quick Start

1. **Move localization to SPM module** - Configure your `Package.swift` to include `.xcstrings` resources
2. **Declare supported languages in Info.plist** - Add `CFBundleLocalizations` array with your language codes:
```xml
<key>CFBundleLocalizations</key>
<array>
  <string>en</string>
  <string>es</string>
  <string>ja</string>
</array>
```
3. **Use `LocalizableString` wrapper** - Create type-safe static properties for your strings
4. **Call `setPreviewLanguage()` in previews** - Enable multi-language **Xcode previews**

That's it. No build phases, no code generation, just clean Swift for **iOS localization** in modular projects.

---

**Tags:** SwiftUI, Swift Package Manager, iOS Development, Localization, String Catalog, SwiftUI Previews, Type Safety, Xcode

