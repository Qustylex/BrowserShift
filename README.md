<p align="center">
  <img src="https://plain-weur-prod-public.komododecks.com/202610/09/wDMnvB5KeKMNw9MGdkNn/image.png" alt="BrowserShift" width="720">
</p>

# BrowserShift

> Switch browsers. Keep your flow.

<p align="center">
  <img src="https://img.shields.io/badge/version-0.3.0-8B5CF6?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/license-MIT-22C55E?style=for-the-badge" alt="License">
  <img src="https://img.shields.io/badge/python-3.11%2B-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python">
  <img src="https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-4B5563?style=for-the-badge" alt="Platform">
</p>
---

## Table of Contents

- [Overview](#overview)
- [Why BrowserShift](#why-browsershift)
- [Features](#features)
- [Supported Browsers](#supported-browsers)
- [Migration Matrix](#migration-matrix)
- [Platform Support](#platform-support)
- [Installation](#installation)
- [Usage](#usage)
- [How Cookie Migration Works](#how-cookie-migration-works)
- [Architecture](#architecture)
- [Security and Privacy](#security-and-privacy)
- [Backup and Restore](#backup-and-restore)
- [Progress Engine](#progress-engine)
- [Logging](#logging)
- [Testing](#testing)
- [Development](#development)
- [Building](#building)
- [Known Limitations](#known-limitations)
- [FAQ](#faq)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [Security Policy](#security-policy)

---

## Overview

BrowserShift is a **local, privacy-first terminal application** that migrates browsing data between installed browsers on your own computer. It runs on **Windows, Linux and macOS**, detects the operating system automatically, and uses the correct browser paths for each platform.

It is written in Python 3.11+ and uses `rich` for a beautiful purple-and-white terminal interface. There is no telemetry, no network access, and no uploads of any kind. Every operation happens on your machine, on your files, under your control.

The application was built around one rule: **never report success when something has failed**. Every migration step is verified, every backup is checksummed, and every error is surfaced honestly.

BrowserShift was born from a simple observation: switching browsers is painful. Bookmarks, history, cookies, and preferences live in different formats, different encryption schemes, and different directory layouts. Every browser has its own database schema, its own timestamp epoch, and its own way of storing the same conceptual data.

BrowserShift bridges that gap. It reads real data from real browser installations, converts it correctly, and writes it into the destination using the destination's own encryption scheme. If it cannot do something safely, it says so.

---

## Why BrowserShift

### The problem

Switching browsers means losing:

- Bookmarks organized in folders you spent years building.
- History you use to find pages you forgot to bookmark.
- Cookies that keep you logged into websites.
- Preferences, extensions, and session state.

Export and import tools exist, but they are partial, browser-specific, and often lie about what they did. Manual migration is fragile: it means editing SQLite databases by hand, decrypting DPAPI blobs, converting epoch timestamps, and hoping nothing breaks.

### The solution

BrowserShift does all of that automatically, with these guarantees:

1. **Verification before modification.** Every write is preceded by a SHA-256 backup that is verified immediately.
2. **Honest reporting.** If a task fails, the report says it failed. If a category is not supported, the checkbox is disabled.
3. **Streaming transparency.** Every single item is shown in the live items panel as it is processed.
4. **Local only.** No network code exists in the project.
5. **Cross-platform.** Windows, Linux and macOS are first-class citizens, not afterthoughts.

### What makes it different

- It does not pretend to support what it cannot do.
- It shows you the real paths, real profiles, real counts.
- It uses the same crypto the browsers use, not a workaround.
- It never deletes source data.
- It never installs extensions silently.
- It never promises that website sessions will remain valid.

---

## Features

### Detection

- Automatic operating system detection for Windows, Linux, and macOS.
- Per-platform browser path resolution: `%LOCALAPPDATA%`, `%APPDATA%`, `~/.config`, `~/.mozilla`, `~/Library/Application Support`, XDG directories.
- Per-browser user profile enumeration.
- Display name extraction from `Preferences` JSON for Chromium browsers.
- Display name extraction from `profiles.ini` for Firefox.
- Default profile detection.
- Absolute paths shown in the interface.

### Reading

- Chromium bookmarks from `Bookmarks` JSON.
- Chromium history from `History` SQLite (`urls` table).
- Chromium cookies from `Cookies` SQLite (`cookies` table) with decryption.
- Firefox bookmarks from `places.sqlite` (`moz_bookmarks` table).
- Firefox history from `places.sqlite` (`moz_places` table).
- Firefox cookies from `cookies.sqlite` (`moz_cookies` table).

### Writing

- Chromium bookmarks: JSON merge preserving folder hierarchy.
- Chromium history: SQLite insert with visit records.
- Chromium cookies: re-encryption with the destination master key.
- Duplicate detection: URL for bookmarks and history, `(host, name, path)` for cookies.
- Atomic writes using temp files and `os.replace`.
- Profile lock detection before writing.

### Interface

- Animated purple-and-white splash screen.
- Environment panel: platform, Python version, backup directory.
- Detection table: browser, profile count, default profile, root path.
- Interactive source and destination pickers.
- Profile pickers with default indicators.
- Category capability table with `supported`, `partial`, `unsupported`, `not_tested` states.
- Confirmation panel with the full plan.
- Live weighted progress bars.
- Per-category counters: imported, skipped, failed.
- Live items panel with the last 8 processed items.
- Finale panel with backup path, totals, and error details.

### Safety

- Mandatory backup before any modification.
- SHA-256 manifest verification.
- Backup restoration.
- No source data modification.
- No destination data deletion.
- Explicit refusal to proceed when a destination cannot be written safely.

### Engineering

- Modular architecture with clear layer separation.
- Type hints everywhere.
- Dataclasses for data models.
- Explicit exception hierarchy.
- Thread-safe progress engine with lock.
- Worker thread with cancellation.
- Rotating file logs.
- Automated test suite.
- No global state.

---

## Supported Browsers

| Browser | Family | Windows | Linux | macOS | Detection | Bookmarks | History | Cookies |
|---|---|---|---|---|---|---|---|---|
| Google Chrome | Chromium | Yes | Yes | Yes | SUPPORTED | SUPPORTED | SUPPORTED | SUPPORTED |
| Microsoft Edge | Chromium | Yes | Yes | Yes | SUPPORTED | SUPPORTED | SUPPORTED | SUPPORTED |
| Brave | Chromium | Yes | Yes | Yes | SUPPORTED | SUPPORTED | SUPPORTED | SUPPORTED |
| Vivaldi | Chromium | Yes | Yes | Yes | SUPPORTED | SUPPORTED | SUPPORTED | SUPPORTED |
| Opera | Chromium | Yes | Yes | Yes | SUPPORTED | SUPPORTED | SUPPORTED | SUPPORTED |
| Opera GX | Chromium | Yes | Yes | Yes | SUPPORTED | SUPPORTED | SUPPORTED | SUPPORTED |
| Mozilla Firefox | Firefox | Yes | Yes | Yes | SUPPORTED | PARTIAL | PARTIAL | PARTIAL |

### Legend

- **SUPPORTED** — fully implemented, tested, verified.
- **PARTIAL** — implemented with documented caveats or read-only.
- **UNSUPPORTED** — explicitly not implemented.
- **NOT_TESTED** — declared but not validated.

---

## Migration Matrix

This matrix describes source → destination combinations that BrowserShift supports today.

| Source \ Destination | Chromium | Firefox |
|---|---|---|
| Chromium | Full (bookmarks, history, cookies) | Not supported |
| Firefox | Full (bookmarks, history, cookies) | Not supported |

### The most useful migration

**Chromium → Chromium**: copy everything from one Chromium browser to another. Chrome → Edge, Edge → Brave, Brave → Vivaldi, and so on.

**Firefox → Chromium**: copy bookmarks, history, and cookies from Firefox into any Chromium browser.

### What BrowserShift refuses to do

- Write into Firefox. The schemas are complex and safe writing requires validation that this release does not provide.
- Migrate extensions. Extension IDs, permissions, and storage differ between browsers.
- Migrate open tabs. Session files are fragile and browser-specific.
- Migrate settings. Preferences contain machine-specific paths.

If any of these are attempted, the app explicitly says so and refuses to proceed rather than pretending it worked.

---

## Platform Support

### Windows 10 / 11

- Uses `%LOCALAPPDATA%` for Chromium user data.
- Uses `%APPDATA%` for Firefox profiles.
- Cookies decrypted with DPAPI + AES-GCM.
- Master key extracted from `Local State`.
- Backup and logs under `%LOCALAPPDATA%\BrowserShift`.

### Linux

- Uses XDG paths: `$XDG_CONFIG_HOME` (`~/.config`) and `$XDG_DATA_HOME` (`~/.local/share`).
- Cookies decrypted with PBKDF2 + AES-GCM.
- PBKDF2 uses password `peanuts`, salt `saltysalt`, 1 iteration, SHA-1.
- Firefox profile root at `~/.mozilla/firefox`.
- Backup and logs under `~/.local/share/BrowserShift`.

### macOS

- Uses `~/Library/Application Support`.
- Firefox profile root at `~/Library/Application Support/Firefox`.
- Bookmark and history migration work fully.
- Cookie migration requires Keychain access and code signing. Not enabled by default.

### Path table

| Browser | Windows | Linux | macOS |
|---|---|---|---|
| Chrome | `%LOCALAPPDATA%\Google\Chrome\User Data` | `~/.config/google-chrome` | `~/Library/Application Support/Google/Chrome` |
| Edge | `%LOCALAPPDATA%\Microsoft\Edge\User Data` | `~/.config/microsoft-edge` | `~/Library/Application Support/Microsoft Edge` |
| Brave | `%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data` | `~/.config/BraveSoftware/Brave-Browser` | `~/Library/Application Support/BraveSoftware/Brave-Browser` |
| Vivaldi | `%LOCALAPPDATA%\Vivaldi\User Data` | `~/.config/vivaldi` | `~/Library/Application Support/Vivaldi` |
| Opera | `%APPDATA%\Opera Software\Opera Stable` | `~/.config/opera` | `~/Library/Application Support/com.operasoftware.Opera` |
| Opera GX | `%APPDATA%\Opera Software\Opera GX Stable` | `~/.config/opera-gx` | `~/Library/Application Support/com.operasoftware.OperaGX` |
| Firefox | `%APPDATA%\Mozilla\Firefox` | `~/.mozilla/firefox` | `~/Library/Application Support/Firefox` |

---

## Installation

### Windows

1. Save the setup script as `BrowserShift_Setup.bat`.
2. Double-click it.
3. It creates `%USERPROFILE%\Downloads\BrowserShift\` with the full project.
4. It launches `run.bat`, which:
   - Finds Python 3.11+ on your PATH.
   - If Python is missing, downloads Python 3.11.9 and installs it silently.
   - Creates `.venv`.
   - Installs `rich`, `pycryptodome`, `pywin32`.
   - Runs the app.

Subsequent launches: double-click `run.bat` inside `BrowserShift\`.

### Linux and macOS

1. Save the setup script as `setup.sh`.
2. Run:

```bash
chmod +x setup.sh
./setup.sh
```

It creates `~/Downloads/BrowserShift/` with the full project. Then:

```bash
cd ~/Downloads/BrowserShift
chmod +x run.sh
./run.sh
```

### Manual install

```bash
git clone https://github.com/BrowserShift/BrowserShift.git
cd BrowserShift
python -m venv .venv
source .venv/bin/activate          # Linux / macOS
# .\.venv\Scripts\Activate.ps1     # Windows PowerShell
python -m pip install --upgrade pip
python -m pip install -e .
python -m browsershift.main
```

### Requirements

- Python 3.11 or newer.
- `rich` 13.7 or newer.
- `pycryptodome` 3.20 or newer.
- `pywin32` 306 or newer (Windows only, automatically skipped elsewhere).
- No administrator privileges.
- No network access after installation.

---

## Usage

1. Launch the app.
2. Watch the animated splash.
3. Read the environment panel.
4. BrowserShift scans for installed browsers.
5. Choose **source browser** and **source profile**.
6. Choose **destination browser** and **destination profile**.
7. Select categories. Bookmarks and history are selected by default. Cookies can be added.
8. Review the confirmation panel.
9. Watch the live migration: progress bars, counters, and per-item lines.
10. Read the finale panel: backup path, imported / skipped / failed totals.

### Example session

```
==========================================
          BrowserShift Launcher
==========================================

[OK] Using Python: /usr/bin/python3.11
[*] Creating virtual environment...
[*] Upgrading pip...
[*] Installing BrowserShift and dependencies...
[OK] Setup complete.

[*] Starting BrowserShift...

  Platform: Linux
  Python:   3.11.9
  Backups:  /home/user/.local/share/BrowserShift/backups

        Detected browsers
 ┏━━━┳━━━━━━━━━━━━━━━━━┳━━━━━━━━━┳━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ # ┃ Browser         ┃ Profiles┃ Default ┃ Root path                 ┃
 ┡━━━╇━━━━━━━━━━━━━━━━━╇━━━━━━━━━╇━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━━━━┩
 │ 1 │ Google Chrome   │       2 │ Default │ ~/.config/google-chrome   │
 │ 2 │ Brave           │       1 │ Default │ ~/.config/BraveSoftware/… │
 │ 3 │ Mozilla Firefox │       1 │ default │ ~/.mozilla/firefox        │
 └───┴─────────────────┴─────────┴─────────┴───────────────────────────┘
```

Then the migration runs and the finale appears:

```
╭──────────────────────── BrowserShift ────────────────────────╮
│ Migration complete.                                          │
│                                                              │
│ Backup saved at:                                             │
│   /home/user/.local/share/BrowserShift/backups/chrome-…      │
│                                                              │
│ Summary                                                      │
│   imported  1432                                             │
│   skipped   87                                               │
│   failed    0                                                │
│                                                              │
│ You can delete me now - you won't need me anymore. AHAHAHA   │
╰──────────────────────────────────────────────────────────────╯
```

---

## How Cookie Migration Works

Cookies are the most sensitive and technically complex category. Here is exactly what BrowserShift does.

### Chromium on Windows

1. Reads the destination profile's `Local State` file (one directory above the profile).
2. Extracts the `os_crypt.encrypted_key` field.
3. Base64-decodes it and strips the `DPAPI` prefix (first 5 bytes).
4. Calls `win32crypt.CryptUnprotectData` to obtain the 32-byte AES key.
5. Reads the source profile's `Cookies` SQLite database into memory.
6. For each cookie, reads `encrypted_value`.
7. If it starts with `v10` or `v11`, splits into nonce (12 bytes), ciphertext, and tag (16 bytes).
8. Decrypts with AES-GCM using the source's master key.
9. Re-encrypts with the destination's key using a fresh random nonce.
10. Writes the new `encrypted_value` into the destination's `Cookies` table.
11. Skips cookies whose `(host, name, path)` already exist in the destination.

### Chromium on Linux

1. Reads the destination profile's `Local State`.
2. Base64-decodes `encrypted_key`.
3. Derives a 16-byte key using PBKDF2 with password `peanuts`, salt `saltysalt`, 1 iteration, and SHA-1.
4. Uses AES-CBC with a 16-space IV to decrypt the master key.
5. Takes the last 16 bytes as the actual AES key.
6. Proceeds as on Windows with AES-GCM for individual cookies.

The Linux method is not a bypass. It is exactly what Chromium itself does. The password `peanuts` is a well-documented constant, and any process running as the same user can decrypt these cookies. BrowserShift does not defeat any protection.

### Firefox

1. Reads `cookies.sqlite` directly.
2. Firefox stores cookies in plaintext. No decryption is required.
3. Converts `expiry` from Unix seconds to Chromium microseconds (1601 epoch).
4. Maps columns: `host`, `name`, `value`, `path`, `expiry`, `isSecure`, `isHttpOnly`.
5. Writes into the destination Chromium `Cookies` table with encryption.

### macOS

Cookie migration on macOS requires reading the Chromium AES key from the macOS Keychain. The Keychain is protected by the user's login password, and reading it requires the app to be code-signed to avoid repeated prompts. This is not enabled in the current release.

Bookmarks and history work normally on macOS.

### What BrowserShift will never do with cookies

- Bypass DPAPI or any OS-level protection.
- Extract credentials, passwords, or tokens.
- Force browser encryption or try to defeat it.
- Claim a website session will remain valid after migration.
- Write cookie values into log files.
- Upload cookies to any server.

### A note on session validity

Migrating cookies does not guarantee that you will stay logged in. Many websites use additional signals:

- Browser fingerprinting.
- HTTP Strict Transport Security state.
- Device-specific tokens.
- Short cookie expiry.

BrowserShift does not make any promise about session validity. It migrates cookies correctly, which is what it can do.

---

## Architecture

### Directory layout

```
src/browsershift/
├── main.py                  Entry point
├── utils/
│   ├── platform.py          OS detection and per-platform paths
│   ├── paths.py             App data, backups, logs directories
│   ├── exceptions.py        Exception hierarchy
│   └── redact.py            Sensitive key detection and redaction
├── security/
│   ├── permissions.py       User scope checks
│   ├── secret_handling.py   Redaction helpers
│   └── windows_crypto.py    DPAPI wrapper
├── browsers/
│   ├── base.py              Adapter interface, data models, capability registry
│   ├── profiles.py          Profile enumeration
│   ├── chromium.py          Chromium adapter and time conversions
│   ├── firefox.py           Firefox adapter
│   └── detector.py          Adapter registry and detection entry point
├── cookies/
│   ├── chromium.py          Chromium cookie read/write with DPAPI and AES-GCM
│   ├── firefox.py           Firefox cookie reader
│   └── migrate.py           Cookie migration orchestration
├── backup/
│   ├── create.py            SHA-256 manifest backup
│   ├── verify.py            Manifest verification
│   └── restore.py           Backup restoration
├── migration/
│   ├── bookmarks.py         Bookmark migration
│   └── history.py           History migration
├── core/
│   ├── plan.py              MigrationPlan dataclass
│   ├── progress.py          Weighted progress engine and task handles
│   └── orchestrator.py      End-to-end migration coordinator
└── tui/
    ├── theme.py             Purple and white theme, logo
    ├── render.py            Banners, tables, sections
    └── app.py               Main interactive flow
```

### Layer responsibilities

- **`tui/`** — presentation only. No migration logic.
- **`core/`** — orchestration, plan, progress. No file I/O.
- **`browsers/`** — detection and adapters. No UI.
- **`migration/`** — per-category operations. Uses adapters and progress handles.
- **`cookies/`** — cookie-specific crypto and migration.
- **`backup/`** — backup, verification, restore.
- **`security/`** — permissions, redaction, DPAPI.
- **`utils/`** — platform, paths, exceptions, redaction helpers.

### Data flow

1. `tui.app.run()` prints the banner and calls `detect_all()`.
2. `browsers.detector.detect_all()` iterates adapters and returns detected browsers.
3. The user picks source and destination in the TUI.
4. A `MigrationPlan` is constructed in `core.plan`.
5. `core.orchestrator.run_migration()` is invoked with a `ProgressEngine`.
6. The orchestrator creates a backup in `backup.create`.
7. The backup is verified in `backup.verify`.
8. Each selected category is executed in a separate task, updating the progress engine.
9. The TUI polls the progress engine and updates the live view.
10. The finale panel is printed with the report.

### Threading model

- The TUI runs on the main thread.
- Migration runs on a worker thread.
- The progress engine is protected by a `threading.Lock`.
- The TUI polls the engine every 80 milliseconds.
- No Qt widgets are involved, so there are no cross-thread GUI issues.

### Cancellation

- The progress engine exposes an `is_cancelled` flag.
- Migration modules check the flag at every item.
- Cancellation raises `CancelledError`.
- The orchestrator converts it into a `cancelled` status.
- Partial results are preserved.

---

## Security and Privacy

### Principles

- **Local only.** No network calls of any kind.
- **No telemetry.** No analytics, no crash reporting, no usage tracking.
- **No uploads.** No browser data, no profiles, no reports leave your machine.
- **No secrets in logs.** Cookie values, tokens, and passwords are never written.
- **Minimal temporary copies.** Sensitive files are copied to temp locations and deleted immediately.
- **No security bypass.** Browser encryption and OS protections are respected.

### What is protected

- Cookie values are decrypted only in memory.
- Temporary SQLite copies are deleted in `finally` blocks.
- Backups contain the same files the browser uses, stored under your user profile only.
- Logs contain timestamps, levels, module names, and messages — never values.
- Redaction helpers are available throughout the codebase.

### What is not protected

- Backups are plain files. If someone can read your user profile, they can read your backups.
- On Linux, cookies are encrypted with a well-known password. This is a Chromium design decision.
- On macOS, cookies are not migrated in this release.

### Reporting vulnerabilities

See `SECURITY.md`. Report privately. Do not open public issues for security problems.

---

## Backup and Restore

### Creation

Before any write, BrowserShift creates a backup of the destination profile:

- Copies `Bookmarks`, `History`, `Preferences`, `Cookies`, `Web Data`, and `Local State`.
- Computes SHA-256 for every copied file.
- Writes a `manifest.json` with identifier, timestamp, profile path, and per-file hashes.
- Stores it under the per-OS app data directory.

### Verification

Immediately after creation, the backup is verified:

- `manifest.json` must exist and parse.
- Every listed file must exist.
- Every file's SHA-256 must match the manifest.

If verification fails, migration does not proceed.

### Restoration

Restoration reads the manifest and copies files back into the original profile path. This is available through `backup/restore.py`.

### Backup location

| Platform | Path |
|---|---|
| Windows | `%LOCALAPPDATA%\BrowserShift\backups\` |
| Linux | `~/.local/share/BrowserShift/backups/` |
| macOS | `~/Library/Application Support/BrowserShift/backups/` |

### Backup naming

Backups are named `{browser_id}-{profile_id}-{timestamp}`. Example:

```
chrome-Default-20250101-143000
```

Inside, each backed-up file sits next to `manifest.json`.

---

## Progress Engine

### Concepts

- **Task** — a unit of work with a stable ID, a category, and a weight.
- **Weight** — relative importance in the overall percentage.
- **Completed** — number of units processed.
- **Total** — total units, when known.
- **Status** — `pending`, `running`, `done`, `skipped`, `failed`, `cancelled`.

### Overall percentage

```
sum over tasks:
    if status in (done, failed, skipped, cancelled): full weight
    elif total > 0: weight * (completed / total)
    else: 0
divided by total weight
```

This means a task with unknown total does not advance the percentage. That prevents misleading UI.

### Default weights

| Category | Weight |
|---|---|
| Backup | 2.0 |
| Bookmarks | 3.0 |
| History | 4.0 |
| Cookies | 3.0 |

### Cancellation

Cancellation sets a global flag. Every migration module checks it at every item and stops gracefully. The report is marked `cancelled` and partial results are preserved.

---

## Logging

- Rotating file handler: 2 MB per file, 5 backups.
- Format: `HH:MM:SS | LEVEL | module | message`.
- Levels: DEBUG, INFO, WARNING, ERROR, CRITICAL.
- No sensitive data is ever logged.
- A redaction module provides `is_sensitive(key)` and `redact(value)` helpers.

Log files are stored in the per-OS app data directory under `logs/`.

---

## Testing

The test suite uses pytest. Current coverage:

- Platform detection.
- Progress engine math.
- Progress cancellation.
- Chromium bookmark parsing.
- Chromium epoch conversions.
- Firefox epoch handling.
- Backup creation and verification.
- Backup tampering detection.
- Redaction helpers.

Run the tests:

```bash
pytest -q
```

All tests are deterministic and use synthetic data. No real profiles, no personal data, no credentials.

---

## Development

### Setup

```bash
git clone https://github.com/BrowserShift/BrowserShift.git
cd BrowserShift
python -m venv .venv
source .venv/bin/activate
python -m pip install -e ".[dev]"
```

### Run

```bash
python -m browsershift.main
```

### Test

```bash
pytest -q
```

### Add a browser

1. Add a `ChromiumTarget` entry to `CHROMIUM_TARGETS`, or create a new adapter.
2. Implement `detect`, `read_bookmarks`, `read_history`.
3. Declare `capabilities()` honestly.
4. Add tests under `tests/`.
5. Update the supported browsers table in this README.

### Add a category

1. Create a module under `migration/` or `cookies/`.
2. Accept `(source_adapter, source_profile, dest_adapter, dest_profile, progress)`.
3. Use `progress.emit`, `progress.tick_imported`, `progress.tick_skipped`, `progress.tick_failed`.
4. Register the category in `core/orchestrator.py`.
5. Update the migration matrix in this README.

---

## Building

### PyInstaller (optional)

```bash
python -m pip install pyinstaller
python -m PyInstaller --clean --noconfirm browsershift.spec
```

Output in `dist/BrowserShift/`. The executable is not code-signed in this release.

### Launcher scripts

- `run.bat` — Windows launcher with automatic Python bootstrap.
- `run.sh` — Linux and macOS launcher.

Both scripts create `.venv` on first run, install dependencies, and start the app.

---

## Known Limitations

- Writing into Firefox is not implemented.
- macOS cookie migration requires Keychain access and code signing.
- Opera and Opera GX cookie schema may differ; write support is best-effort.
- Some Chromium forks (Arc, Ungoogled Chromium) are not detected.
- Extension migration is not universal and is not implemented.
- Open tabs migration is not implemented.
- Settings migration is not implemented.
- Very large histories (over one million entries) may take several minutes.

Every one of these is surfaced as a capability state in the app. Nothing is hidden.

---

## FAQ

**Does BrowserShift upload my data?**
No. It has no network code.

**Does it modify my source browser?**
No. It only reads from the source.

**Does it delete anything from the destination?**
No. It merges. Duplicates are skipped.

**Can I undo a migration?**
Yes. Restore the backup created before the migration.

**Why does it refuse to write into Firefox?**
Because Firefox's bookmark and history schemas are complex and safe writing requires more validation than this release provides.

**Will my website sessions stay logged in after migrating cookies?**
Maybe. This depends on the site, on cookie flags, and on browser fingerprinting. BrowserShift does not promise this.

**Does it need administrator rights?**
No.

**Does it work on Linux?**
Yes. Detection, bookmarks, history, and cookies all work on Linux.

**Does it work on macOS?**
Bookmarks and history work. Cookies do not in this release.

**Can I run it without installing Python?**
On Windows, `run.bat` downloads and installs Python silently if it is missing.

**Where are backups stored?**
Windows: `%LOCALAPPDATA%\BrowserShift\backups\`. Linux: `~/.local/share/BrowserShift/backups/`. macOS: `~/Library/Application Support/BrowserShift/backups/`.

**Can I migrate between two profiles of the same browser?**
Yes. Source and destination profiles are independent.

---

## Roadmap

### Phase 1 — Done

- Detection, profiles, adapters.
- Bookmarks and history reading.
- Backup with verification.
- Purple and white TUI.
- Progress engine with cancellation.

### Phase 2 — Done

- Bookmark and history writing into Chromium.
- Cookie reading and writing for Chromium.
- Firefox cookie reading.
- Cross-platform launchers.

### Phase 3 — Planned

- Firefox bookmark and history writing.
- macOS Keychain integration with code signing.
- HTML bookmark export fallback.
- JSON migration report.

### Phase 4 — Exploring

- Extension inventory and compatibility hints.
- Session file handling.
- Profile diff viewer.

---

## Contributing

Contributions are welcome. Please:

1. Run the tests before opening a PR.
2. Never commit real browser profiles or personal data.
3. Use synthetic fixtures under `tests/fixtures/`.
4. Declare capabilities honestly.
5. Never report success when an operation failed.
6. Keep UI code separate from migration logic.

See `CONTRIBUTING.md` for the full guide.

---

## License

MIT License. See `LICENSE`.

---

## Security Policy

See `SECURITY.md`. Report vulnerabilities privately. Do not open public issues for security problems.

---

<p align="center">
  <sub>Built with care, honesty, and a lot of SQLite.</sub>
</p>

<p align="center">
  <a href="#browsershift">Back to top</a>
</p>
