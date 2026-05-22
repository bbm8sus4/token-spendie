# Rename to Token Spendie — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename the project everywhere from "Claude Usage Widget" / `ClaudeUsage` to "Token Spendie" / `TokenSpendie`, with no behavior change.

**Architecture:** Pure rename. `git mv` for directory and doc-file renames (preserves history). Explicit per-line edits for source/config strings. Ordered `sed` for the bulk doc-content scrub, where substring collisions are handled by replacement order. Each task ends with a build/test/grep verification and a commit.

**Tech Stack:** Swift Package Manager, AppKit/SwiftUI, macOS. Branch: `rename-token-spendie` (already created, off `main`).

**Name mapping:**

| Context | Old | New |
|---|---|---|
| Display name | Claude Usage Widget | Token Spendie |
| Code identifier | ClaudeUsageWidget / ClaudeUsage | TokenSpendie |
| Bundle id | com.cherise.ClaudeUsage | com.cherise.TokenSpendie |
| App bundle / zip | ClaudeUsage.app / .zip | TokenSpendie.app / .zip |

**Files touched:**
- `Package.swift` — package + target names
- `Sources/ClaudeUsageWidget/` → `Sources/TokenSpendie/` (directory)
- `Tests/ClaudeUsageWidgetTests/` → `Tests/TokenSpendieTests/` (directory, 13 files)
- 9 source/tool string locations
- `build.sh`, `Resources/Info.plist`
- `README.md`
- `docs/superpowers/` plan + spec files (content + 2 filename renames)
- `.vscode/launch.json`, `.claude/settings.local.json` (untracked — no commit)

---

### Task 1: Rename Swift package, directories, and test imports

**Files:**
- Move: `Sources/ClaudeUsageWidget/` → `Sources/TokenSpendie/`
- Move: `Tests/ClaudeUsageWidgetTests/` → `Tests/TokenSpendieTests/`
- Modify: `Package.swift`
- Modify: all 13 files in `Tests/TokenSpendieTests/` (the `@testable import` line)
- Modify: `Tests/TokenSpendieTests/KeychainReaderTests.swift`, `Tests/TokenSpendieTests/ManualTokenStoreTests.swift` (test service-name literals)

- [ ] **Step 1: Move the directories with git**

```bash
git mv Sources/ClaudeUsageWidget Sources/TokenSpendie
git mv Tests/ClaudeUsageWidgetTests Tests/TokenSpendieTests
```

- [ ] **Step 2: Rewrite `Package.swift`**

Replace the entire contents of `Package.swift` with:

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TokenSpendie",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "TokenSpendie", path: "Sources/TokenSpendie"),
        .testTarget(
            name: "TokenSpendieTests",
            dependencies: ["TokenSpendie"],
            path: "Tests/TokenSpendieTests"
        ),
    ]
)
```

- [ ] **Step 3: Update the `@testable import` in every test file**

All 13 test files have `@testable import ClaudeUsageWidget` on line 2. Replace across the directory:

```bash
sed -i '' 's/@testable import ClaudeUsageWidget/@testable import TokenSpendie/' Tests/TokenSpendieTests/*.swift
```

- [ ] **Step 4: Update the two test service-name literals**

In `Tests/TokenSpendieTests/KeychainReaderTests.swift`, replace:

```swift
        let reader = KeychainReader(service: "ClaudeUsageWidget-NoSuchItem-\(UUID().uuidString)")
```

with:

```swift
        let reader = KeychainReader(service: "TokenSpendie-NoSuchItem-\(UUID().uuidString)")
```

In `Tests/TokenSpendieTests/ManualTokenStoreTests.swift`, replace:

```swift
        ManualTokenStore(service: "ClaudeUsageWidget-Test-\(UUID().uuidString)")
```

with:

```swift
        ManualTokenStore(service: "TokenSpendie-Test-\(UUID().uuidString)")
```

- [ ] **Step 5: Clear stale build products and build**

The old `.build/` holds artifacts keyed to the old target name. `.build/` is gitignored.

Run: `rm -rf .build && swift build`
Expected: `Build complete!` with no errors.

- [ ] **Step 6: Run the test suite**

Run: `swift test`
Expected: all tests pass (`Test Suite 'All tests' passed`).

- [ ] **Step 7: Verify no import references the old module**

Run: `git grep -n "import ClaudeUsageWidget"`
Expected: no output.

- [ ] **Step 8: Commit**

```bash
git add Package.swift Sources/TokenSpendie Tests/TokenSpendieTests
git commit -m "$(cat <<'EOF'
Rename Swift package and directories to TokenSpendie

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
EOF
)"
```

---

### Task 2: Rename internal source strings

All paths below are the post-Task-1 locations. These are nine independent
string edits — UI labels and internal identifiers.

**Files:**
- Modify: `Sources/TokenSpendie/AppDelegate.swift`
- Modify: `Sources/TokenSpendie/UI/PreferencesView.swift`
- Modify: `Sources/TokenSpendie/UI/DetailPanelView.swift`
- Modify: `Sources/TokenSpendie/Data/EndpointUsageProvider.swift`
- Modify: `Sources/TokenSpendie/Data/ManualTokenStore.swift`
- Modify: `Sources/TokenSpendie/Store/UsageStore.swift`
- Modify: `Sources/TokenSpendie/Store/SnapshotCache.swift`
- Modify: `Tools/probe.swift`
- Modify: `Tools/token-probe.swift`

- [ ] **Step 1: Window title**

In `Sources/TokenSpendie/AppDelegate.swift`, replace:

```swift
        window.title = "Claude Usage Widget"
```

with:

```swift
        window.title = "Token Spendie"
```

- [ ] **Step 2: Preferences header**

In `Sources/TokenSpendie/UI/PreferencesView.swift`, replace:

```swift
            Text("Claude Usage Widget").font(.system(size: 14, weight: .bold))
```

with:

```swift
            Text("Token Spendie").font(.system(size: 14, weight: .bold))
```

- [ ] **Step 3: Detail-panel header**

In `Sources/TokenSpendie/UI/DetailPanelView.swift`, replace:

```swift
            Text("CLAUDE USAGE")
```

with:

```swift
            Text("TOKEN SPENDIE")
```

- [ ] **Step 4: HTTP User-Agent (app)**

In `Sources/TokenSpendie/Data/EndpointUsageProvider.swift`, replace:

```swift
        request.setValue("ClaudeUsageWidget/1.0", forHTTPHeaderField: "User-Agent")
```

with:

```swift
        request.setValue("TokenSpendie/1.0", forHTTPHeaderField: "User-Agent")
```

- [ ] **Step 5: Keychain service for the manual token**

In `Sources/TokenSpendie/Data/ManualTokenStore.swift`, replace:

```swift
    init(service: String = "com.cherise.ClaudeUsage.token") {
```

with:

```swift
    init(service: String = "com.cherise.TokenSpendie.token") {
```

- [ ] **Step 6: Network-monitor dispatch queue label**

In `Sources/TokenSpendie/Store/UsageStore.swift`, replace:

```swift
        pathMonitor.start(queue: DispatchQueue(label: "ClaudeUsage.network"))
```

with:

```swift
        pathMonitor.start(queue: DispatchQueue(label: "TokenSpendie.network"))
```

- [ ] **Step 7: Application Support cache directory**

In `Sources/TokenSpendie/Store/SnapshotCache.swift`, replace the doc comment:

```swift
    /// Default location: ~/Library/Application Support/ClaudeUsage/last-snapshot.json
```

with:

```swift
    /// Default location: ~/Library/Application Support/TokenSpendie/last-snapshot.json
```

and replace:

```swift
            .appendingPathComponent("ClaudeUsage", isDirectory: true)
```

with:

```swift
            .appendingPathComponent("TokenSpendie", isDirectory: true)
```

- [ ] **Step 8: Probe-tool User-Agents**

In `Tools/probe.swift`, replace:

```swift
request.setValue("ClaudeUsageWidget/probe", forHTTPHeaderField: "User-Agent")
```

with:

```swift
request.setValue("TokenSpendie/probe", forHTTPHeaderField: "User-Agent")
```

In `Tools/token-probe.swift`, replace:

```swift
request.setValue("ClaudeUsageWidget/token-probe", forHTTPHeaderField: "User-Agent")
```

with:

```swift
request.setValue("TokenSpendie/token-probe", forHTTPHeaderField: "User-Agent")
```

- [ ] **Step 9: Build, test, and grep the source tree**

Run: `swift build && swift test`
Expected: build succeeds, all tests pass.

Run: `git grep -in "claudeusage" -- Sources Tools`
Expected: no output.

- [ ] **Step 10: Commit**

```bash
git add Sources/TokenSpendie Tools
git commit -m "$(cat <<'EOF'
Rename internal identifiers and UI strings to Token Spendie

Renames the Keychain service, Application Support directory, User-Agent
strings, dispatch queue label, and user-facing labels. The manual token
must be re-entered once; the old cache directory is left orphaned and
harmless.

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
EOF
)"
```

---

### Task 3: Rename the app bundle (build script + Info.plist)

**Files:**
- Modify: `build.sh`
- Modify: `Resources/Info.plist`

- [ ] **Step 1: Rewrite `build.sh`**

Replace the entire contents of `build.sh` with:

```bash
#!/usr/bin/env bash
# Builds TokenSpendie.app and a shareable zip.
set -euo pipefail
cd "$(dirname "$0")"

APP="build/TokenSpendie.app"
BIN_NAME="TokenSpendie"

echo "==> Compiling (release)"
swift build -c release

echo "==> Generating icon"
swift Tools/makeicon.swift
ICONSET="build/AppIcon.iconset"
rm -rf "$ICONSET" && mkdir -p "$ICONSET"
for s in 16 32 64 128 256 512; do
  sips -z $s $s     Resources/AppIcon-1024.png --out "$ICONSET/icon_${s}x${s}.png"   >/dev/null
  sips -z $((s*2)) $((s*2)) Resources/AppIcon-1024.png --out "$ICONSET/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o build/AppIcon.icns

echo "==> Assembling app bundle"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp ".build/release/$BIN_NAME" "$APP/Contents/MacOS/$BIN_NAME"
cp Resources/Info.plist "$APP/Contents/Info.plist"
cp build/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"

echo "==> Zipping for sharing"
( cd build && rm -f TokenSpendie.zip && ditto -c -k --keepParent TokenSpendie.app TokenSpendie.zip )

echo "==> Done: $APP  and  build/TokenSpendie.zip"
```

- [ ] **Step 2: Rewrite `Resources/Info.plist`**

Replace the entire contents of `Resources/Info.plist` with:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>            <string>TokenSpendie</string>
    <key>CFBundleDisplayName</key>     <string>Token Spendie</string>
    <key>CFBundleIdentifier</key>      <string>com.cherise.TokenSpendie</string>
    <key>CFBundleVersion</key>         <string>1</string>
    <key>CFBundleShortVersionString</key> <string>1.0.0</string>
    <key>CFBundlePackageType</key>     <string>APPL</string>
    <key>CFBundleExecutable</key>      <string>TokenSpendie</string>
    <key>CFBundleIconFile</key>        <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>  <string>13.0</string>
    <key>LSUIElement</key>             <true/>
    <key>NSHumanReadableCopyright</key><string>Personal use.</string>
</dict>
</plist>
```

- [ ] **Step 3: Remove stale build artifacts and rebuild**

`build/` is gitignored; deleting the old-named artifacts only avoids confusion.

```bash
rm -rf build/ClaudeUsage.app build/ClaudeUsage.zip
./build.sh
```

Expected: final line `==> Done: build/TokenSpendie.app  and  build/TokenSpendie.zip`.

- [ ] **Step 4: Verify the bundle**

Run: `ls build/TokenSpendie.app/Contents/MacOS/`
Expected: a single file named `TokenSpendie`.

Run: `/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' build/TokenSpendie.app/Contents/Info.plist`
Expected: `com.cherise.TokenSpendie`.

- [ ] **Step 5: Commit**

```bash
git add build.sh Resources/Info.plist
git commit -m "$(cat <<'EOF'
Rename app bundle to TokenSpendie.app

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
EOF
)"
```

---

### Task 4: Rename the README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Rewrite `README.md`**

Replace the entire contents of `README.md` with:

```markdown
# Token Spendie

A macOS menu bar widget that shows your Claude Code usage — the 5-hour session
window and weekly caps — in real time.

## Build

Requires the Swift toolchain (Xcode Command Line Tools). No Xcode needed.

    ./build.sh

This produces `build/TokenSpendie.app` and `build/TokenSpendie.zip`.

## Install

1. Unzip `TokenSpendie.zip` and move `TokenSpendie.app` to `/Applications`.
2. **First launch:** right-click the app → **Open**, then confirm. This is
   required once because the app is not notarized.
3. When macOS asks for Keychain access, choose **Allow** — the widget reads your
   Claude Code login token to fetch usage.

## Requirements

- macOS 13 (Ventura) or later.
- Claude Code installed and logged in (`claude` working in a terminal). The
  widget reads the token Claude Code already stores; it never logs you in.

## Using it

- The menu bar shows your session usage as a ring. Click it for the full
  breakdown (session, weekly, per-model weekly).
- In Settings you can enable a floating always-on-top panel, change the refresh
  interval, and toggle launch-at-login.

## Sharing with friends

Send them `TokenSpendie.zip`. They follow the same Install steps. Each machine
uses its own Claude Code login automatically — there is nothing to configure.
```

- [ ] **Step 2: Verify**

Run: `git grep -in "claude usage\|claudeusage" -- README.md`
Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "$(cat <<'EOF'
Rename README to Token Spendie

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
EOF
)"
```

---

### Task 5: Rename the docs (content + filenames)

Scrubs the old name from the historical plan/spec docs and renames the two
files whose names carry the old project name.

**Files:**
- Modify (content): `docs/superpowers/plans/2026-05-21-claude-usage-widget.md`
- Modify (content): `docs/superpowers/plans/2026-05-21-widget-theming-and-credentials.md`
- Modify (content): `docs/superpowers/plans/2026-05-22-dropdown-ui-polish.md`
- Modify (content): `docs/superpowers/specs/2026-05-21-claude-usage-widget-design.md`
- Modify (content): `docs/superpowers/specs/2026-05-21-widget-theming-and-credentials-design.md`
- Modify (content): `docs/superpowers/specs/2026-05-22-dropdown-ui-polish-design.md`
- Rename: `docs/superpowers/plans/2026-05-21-claude-usage-widget.md` → `...-token-spendie.md`
- Rename: `docs/superpowers/specs/2026-05-21-claude-usage-widget-design.md` → `...-token-spendie-design.md`

> **Do NOT touch** `docs/superpowers/specs/2026-05-22-rename-to-token-spendie-design.md`
> or `docs/superpowers/plans/2026-05-22-rename-to-token-spendie.md`. They
> intentionally contain the old name in old→new mapping tables; scrubbing them
> would corrupt those tables.

- [ ] **Step 1: Scrub the old name from the six doc files**

The replacement order matters — the longer/more-specific patterns run first so
`ClaudeUsageWidget` is never left as a `TokenSpendieWidget` fragment.

```bash
for f in \
  docs/superpowers/plans/2026-05-21-claude-usage-widget.md \
  docs/superpowers/plans/2026-05-21-widget-theming-and-credentials.md \
  docs/superpowers/plans/2026-05-22-dropdown-ui-polish.md \
  docs/superpowers/specs/2026-05-21-claude-usage-widget-design.md \
  docs/superpowers/specs/2026-05-21-widget-theming-and-credentials-design.md \
  docs/superpowers/specs/2026-05-22-dropdown-ui-polish-design.md
do
  sed -i '' \
    -e 's/Claude Usage Widget/Token Spendie/g' \
    -e 's/claude-usage-widget/token-spendie/g' \
    -e 's/ClaudeUsageWidget/TokenSpendie/g' \
    -e 's/ClaudeUsage/TokenSpendie/g' \
    -e 's/CLAUDE USAGE/TOKEN SPENDIE/g' \
    "$f"
done
```

- [ ] **Step 2: Rename the two doc files**

```bash
git mv docs/superpowers/plans/2026-05-21-claude-usage-widget.md \
       docs/superpowers/plans/2026-05-21-token-spendie.md
git mv docs/superpowers/specs/2026-05-21-claude-usage-widget-design.md \
       docs/superpowers/specs/2026-05-21-token-spendie-design.md
```

- [ ] **Step 3: Verify the scrub**

Run:
```bash
git grep -il "claudeusage\|claude-usage\|claude usage" -- docs/ \
  ':!docs/superpowers/specs/2026-05-22-rename-to-token-spendie-design.md' \
  ':!docs/superpowers/plans/2026-05-22-rename-to-token-spendie.md'
```
Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add docs/superpowers/plans docs/superpowers/specs
git commit -m "$(cat <<'EOF'
Rename docs content and filenames to Token Spendie

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
EOF
)"
```

---

### Task 6: Update editor and tooling config

`.vscode/` and `.claude/settings.local.json` are untracked (not gitignored, but
never committed). Update them on disk so debugging and the permission allowlist
keep working, but do **not** `git add` them — they stay untracked.

**Files:**
- Modify: `.vscode/launch.json`
- Modify: `.claude/settings.local.json`

- [ ] **Step 1: Rewrite `.vscode/launch.json`**

Replace the entire contents of `.vscode/launch.json` with:

```json
{
    "configurations": [
        {
            "type": "swift",
            "request": "launch",
            "args": [],
            "cwd": "${workspaceFolder:claude-widget}",
            "name": "Debug TokenSpendie",
            "target": "TokenSpendie",
            "configuration": "debug",
            "preLaunchTask": "swift: Build Debug TokenSpendie"
        },
        {
            "type": "swift",
            "request": "launch",
            "args": [],
            "cwd": "${workspaceFolder:claude-widget}",
            "name": "Release TokenSpendie",
            "target": "TokenSpendie",
            "configuration": "release",
            "preLaunchTask": "swift: Build Release TokenSpendie"
        }
    ]
}
```

- [ ] **Step 2: Update old-name strings in `.claude/settings.local.json`**

This file is a permission allowlist. Replace old-name fragments in-place,
`ClaudeUsageWidget` before `ClaudeUsage` to avoid a stale `TokenSpendieWidget`:

```bash
sed -i '' \
  -e 's/ClaudeUsageWidget/TokenSpendie/g' \
  -e 's/ClaudeUsage/TokenSpendie/g' \
  .claude/settings.local.json
```

- [ ] **Step 3: Verify the JSON still parses**

Run: `python3 -c 'import json; json.load(open(".claude/settings.local.json")); json.load(open(".vscode/launch.json")); print("ok")'`
Expected: `ok`.

- [ ] **Step 4: No commit**

Both files are untracked. Confirm they are not staged:

Run: `git status --porcelain .vscode .claude`
Expected: lines start with `??` (untracked) — nothing staged.

---

### Task 7: Final verification

- [ ] **Step 1: Full clean build and test**

Run: `rm -rf .build && swift build && swift test`
Expected: build succeeds, all tests pass.

- [ ] **Step 2: Release bundle build**

Run: `./build.sh`
Expected: final line names `build/TokenSpendie.app` and `build/TokenSpendie.zip`.

- [ ] **Step 3: Repo-wide old-name scan**

Run:
```bash
git grep -il "claudeusage\|claude-usage" -- . \
  ':!docs/superpowers/specs/2026-05-22-rename-to-token-spendie-design.md' \
  ':!docs/superpowers/plans/2026-05-22-rename-to-token-spendie.md'
```
Expected: no output. (The rename spec and this plan are excluded — they document the old name on purpose.)

- [ ] **Step 4: Confirm the branch state**

Run: `git log --oneline main..HEAD`
Expected: the design-spec commit plus the five rename commits from Tasks 1–5.

- [ ] **Step 5: Report remaining manual steps**

These are outside the repo and must be done by the user, not the plan:
- Delete the old installed app: `rm -rf /Applications/ClaudeUsage.app`
- Install the new build: copy `build/TokenSpendie.app` to `/Applications`.
- Re-enter the manual token in Settings (the Keychain service changed).
- The old cache folder `~/Library/Application Support/ClaudeUsage/` is orphaned and may be deleted.
