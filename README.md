# swift-ios-template

Opinionated Swift/SwiftUI MVVM starter.  
Repo: https://github.com/jf8989/swift-ios-template

- Navigation: `NavigationStack` (per-tab if you use a `TabView`)
- State: ViewModels with `@Published`; pure Models
- Engine: services/clients/repos/mappers/factories (concretes)
- Lint/format: `.swiftlint.yml`, `.swiftformat`
- Git hygiene: solid `.gitignore`

---

## Quick Start — Use with an **existing remote** (your case)

Target remote: `git@github.com:jf8989/mapkit-ios.git`

```bash
# from any parent folder
git clone git@github.com:jf8989/swift-ios-template.git MapKit-IOS
cd MapKit-IOS

# strip template history and start your own
rm -rf .git
git init
git add .
git commit -m "Bootstrap from swift-ios-template"
git branch -M main

# point to YOUR repo and push
git remote add origin git@github.com:jf8989/mapkit-ios.git

# if the remote is empty:
git push -u origin main

# if the remote already has commits, choose one:
# A) Safer PR route:
git switch -c chore/bootstrap-template
git push -u origin chore/bootstrap-template
# → open PR chore/bootstrap-template → main

# B) Replace history (be sure):
git push -u origin main --force-with-lease
