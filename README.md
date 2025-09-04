# swift-ios-template

Opinionated Swift/SwiftUI MVVM starter.

Repo: [https://github.com/jf8989/swift-ios-template](https://github.com/jf8989/swift-ios-template)

* Navigation: `NavigationStack` (per-tab if you use a `TabView`)
* State: ViewModels with `@Published`; pure Models
* Engine: services/clients/repos/mappers/factories (concretes)
* Lint/format: `.swiftlint.yml`, `.swiftformat`
* Git hygiene: solid `.gitignore`

---

## Quick Start (Terminal)

### A) New app with a **fresh** git history (recommended)

```bash
# 1) Get the template files
git clone https://github.com/jf8989/swift-ios-template MyCoolApp
cd MyCoolApp

# 2) Start fresh history
rm -rf .git
git init
git add .
git commit -m "Initial commit from swift-ios-template"
git branch -M main

# 3) Point to your NEW empty repo and push
git remote add origin <https-url-or-ssh-of-your-new-repo>
git push -u origin main
```

### B) Keep the template’s commit history (optional)

```bash
git clone https://github.com/jf8989/swift-ios-template MyCoolApp
cd MyCoolApp
git remote set-url origin <https-url-or-ssh-of-your-new-repo>
git push -u origin main
```

---

## Local Setup

Install formatters (optional but recommended):

```bash
# macOS (Homebrew)
brew install swiftlint swiftformat
```

Run on demand:

```bash
swiftformat .
swiftlint
```

---

## Open & Rename

1. Open `swift-ios-template.xcodeproj` in Xcode.
2. In **Targets → General**, set:

   * **Display Name** and **Bundle Identifier**
3. Rename the app/scheme if desired:

   * Product menu → **Scheme → Manage Schemes…** → rename.
4. Update placeholder types in `/App/Main` if you change names:

   * `AppNameApp.swift`, `AppNameMainView.swift` → your names.

---

## Folder Structure

```
/App
  /Main            # <YourApp>App.swift + <YourApp>MainView (root shell/injection)
  /Shared          # cross-feature utilities (TaskBag, PreviewData, etc.)
  /Protocols       # app-wide service/repo contracts (...Type)
  /Engine          # concretes only
    /Clients       # HTTP/DB/Keychain/etc. low-level clients
    /Decorators    # cross-cutting wrappers (logging, retry, caching)
    /DTOs          # network/storage transfer types
    /Factories     # builders for clients/services/repos/formatters
    /Helpers       # small infra helpers
    /Mappers       # DTO ⇄ domain, domain ⇄ persistence
    /Network       # request builders, endpoints (if you separate them)
    /Providers     # environment/config providers
    /Repos         # repositories that merge sources (API/cache/disk)
    /Services      # business-ish operations built on repos/clients
  /Model           # pure domain types (no IO/UI)
  /<Feature>
    /Components    # small reusable view pieces
    /Helpers       # feature-local utilities
    /UIState       # lightweight structs/enums for the UI only
    FeatureMainView.swift
    FeatureViewModel.swift
/Extensions        # shared extensions only (no app state)
/Assets            # asset catalogs
```

---

## Create Your First Feature (tiny recipe)

1. Make a folder: `/App/PlanetList`
2. Add:

   * `/App/PlanetList/PlanetListMainView.swift`
   * `/App/PlanetList/PlanetListViewModel.swift`
   * `/App/PlanetList/UIState/...` (as needed)
3. In `MainView`, add a `NavigationStack` pointing to `PlanetListMainView`.

Minimal stubs:

```swift
// /App/PlanetList/PlanetListViewModel.swift
import Foundation

@MainActor
public final class PlanetListViewModel: ObservableObject {
    @Published public private(set) var planets: [String] = []
    public init() {}
    public func load() { planets = ["Mercury","Venus","Earth"] }
}
```

```swift
// /App/PlanetList/PlanetListMainView.swift
import SwiftUI

public struct PlanetListMainView: View {
    @StateObject private var vm = PlanetListViewModel()
    public init() {}
    public var body: some View {
        List(vm.planets, id: \._self, rowContent: Text.init)
            .navigationTitle("Planets")
            .task { vm.load() }
    }
}
```

Wire it from your root `MainView` (e.g., as a tab or a push destination).

---

## Repos, Mappers, Factories — where they live

* **Protocols**: `/App/Protocols` (e.g., `PlanetsRepositoryType`)
* **Repos** (concretes): `/App/Engine/Repos`
* **Mappers**: `/App/Engine/Mappers`
* **Factories**: `/App/Engine/Factories` return protocol types and compose clients/mappers.

---

## Git Tips

* Keep `Package.resolved` **committed** to lock dependency versions across machines/CI.
* Empty folders you want tracked (like `/App/Engine/Repos`) can include a `.keep` file.

---

## License

Choose your own; none included by default.
