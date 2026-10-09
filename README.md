<p align="center">
  <img src="assets/banner.png" alt="BrowserShift" width="820">
</p>

<h1 align="center">BrowserShift</h1>

<p align="center">
  <em>Switch browsers. Keep your flow.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-0.3.0-8B5CF6?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/license-MIT-22C55E?style=for-the-badge" alt="License">
  <img src="https://img.shields.io/badge/python-3.11%2B-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python">
  <img src="https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-4B5563?style=for-the-badge" alt="Platform">
</p>

<p align="center">
  <a href="#installation"><img src="https://img.shields.io/badge/install-30%20seconds-8B5CF6?style=flat-square" alt="Install"></a>
  <a href="#usage"><img src="https://img.shields.io/badge/usage-interactive-8B5CF6?style=flat-square" alt="Usage"></a>
  <a href="#migration-matrix"><img src="https://img.shields.io/badge/matrix-honest-4ADE80?style=flat-square" alt="Matrix"></a>
  <a href="#security-and-privacy"><img src="https://img.shields.io/badge/telemetry-none-EF4444?style=flat-square" alt="Telemetry"></a>
  <a href="#faq"><img src="https://img.shields.io/badge/FAQ-20%20questions-94A3B8?style=flat-square" alt="FAQ"></a>
</p>

---

## Table of Contents

- [What is BrowserShift](#what-is-browsershift)
- [Screenshot](#screenshot)
- [Why this project exists](#why-this-project-exists)
- [Feature overview](#feature-overview)
- [Supported browsers](#supported-browsers)
- [Migration matrix](#migration-matrix)
- [Platform support](#platform-support)
- [Browser path reference](#browser-path-reference)
- [Installation](#installation)
- [Running the app](#running-the-app)
- [Usage walkthrough](#usage-walkthrough)
- [How cookie migration works](#how-cookie-migration-works)
- [How bookmark migration works](#how-bookmark-migration-works)
- [How history migration works](#how-history-migration-works)
- [Architecture](#architecture)
- [Project layout](#project-layout)
- [Security and privacy](#security-and-privacy)
- [Backup and restore](#backup-and-restore)
- [Progress engine](#progress-engine)
- [Logging](#logging)
- [Testing](#testing)
- [Development](#development)
- [Building](#building)
- [Adding a browser](#adding-a-browser)
- [Adding a category](#adding-a-category)
- [Known limitations](#known-limitations)
- [Design decisions](#design-decisions)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [Code of conduct](#code-of-conduct)
- [Credits](#credits)
- [License](#license)
- [Security policy](#security-policy)

---

## What is BrowserShift

BrowserShift is a **local, privacy-first terminal application** that migrates your browsing data between the browsers installed on your own computer. It runs on **Windows, Linux and macOS**, detects the operating system automatically, and uses the correct browser paths for each platform.

It is written in Python 3.11+ and uses `rich` for a beautiful purple-and-white terminal interface. There is no telemetry, no network access, and no uploads of any kind. Every operation happens on your machine, on your files, under your control.

The application was built around one rule: **never report success when something has failed**. Every migration step is verified, every backup is checksummed, and every error is surfaced honestly.

The whole project — source code, launcher scripts, documentation, assets and banner — is contained in the repository ZIP you downloaded. No external downloads are required after the initial setup.

---

## Screenshot

The banner above is included in the repository as `assets/banner.png`. It ships inside the project ZIP together with the source tree, the launcher scripts, and this README, so the documentation always matches the code that was shipped.

Additional screenshots live under `assets/screenshots/` and cover:

- `01-splash.png` — the animated purple-and-white splash.
- `02-detection.png` — the detected browsers table.
- `03-categories.png` — the category capability table.
- `04-live.png` — a running migration with live items.
- `05-finale.png` — the final report panel.

---

## Why this project exists

Switching browsers is painful. Bookmarks, history, cookies, and preferences live in different formats, different encryption schemes, and different directory layouts. Every browser has its own database schema, its own timestamp epoch, and its own way of storing the same conceptual data.

Export and import tools exist, but they are partial, browser-specific, and often lie about what they did. Manual migration is fragile: it means editing SQLite databases by hand, decrypting DPAPI blobs, converting epoch timestamps, and hoping nothing breaks.

BrowserShift solves this by:

- **Detecting** what you actually have installed, per operating system.
- **Reading** real data using native formats: JSON, SQLite, DPAPI, AES-GCM, PBKDF2.
- **Writing** into the destination using the destination's own encryption key.
- **Verifying** every write with a SHA-256 backup created beforehand.
- **Streaming** every single item so you can watch the migration happen in real time.
- **Refusing** to claim support for things it cannot actually do.

If a browser cannot be detected, it says so. If a category is not supported, the checkbox is disabled. If a write fails, the report says it failed. Nothing is faked, nothing is hidden.

---

## Feature overview

### Detection

- Automatic operating system detection for Windows, Linux and macOS.
- Per-platform browser path resolution.
- Per-browser user profile enumeration.
- Profile names extracted from `Preferences` (Chromium) or `profiles.ini` (Firefox).
- Default profile detection.
- Absolute paths shown in the interface.

### Reading

- Chromium bookmarks from `Bookmarks` JSON.
- Chromium history from `History` SQLite (`urls` table).
- Chromium cookies from `Cookies` SQLite (`cookies` table).
- Firefox bookmarks from `places.sqlite` (`moz_bookmarks` table).
- Firefox history from `places.sqlite` (`moz_places` table).
- Firefox cookies from `cookies.sqlite` (`moz_cookies` table).

### Writing

- Chromium bookmarks: JSON merge preserving folder hierarchy.
- Chromium history: SQLite insert with matching visit records.
- Chromium cookies: re-encryption with the destination master key.
- Duplicate detection: URL for bookmarks and history, `(host, name, path)` for cookies.
- Atomic writes using temp files and `os.replace`.
- Profile lock detection before writing.

### Interface

- Animated splash screen with a purple-and-white palette.
- Environment panel showing platform, Python version, and backup directory.
- Detection table with browser name, profile count, default profile, root path.
- Interactive source and destination browser pickers.
- Profile pickers with default indicators.
- Category capability table with `supported`, `partial`, `unsupported`, `not_tested` states.
- Confirmation panel showing the full plan.
- Live weighted progress bars, one per category.
- Per-category counters: imported, skipped, failed.
- Live items panel with the last eight processed items.
- Finale panel with backup path, totals, and error details.

### Safety

- Mandatory backup before any modification.
- SHA-256 manifest verification.
- Backup restoration.
- No modification of source data.
- No deletion of destination data.
- Explicit refusal to proceed when a destination cannot be written safely.
- Redaction helpers available throughout the codebase.

### Engineering

- Modular architecture with clear layer separation.
- Type hints throughout.
- Dataclasses for data models.
- Explicit exception hierarchy.
- Thread-safe progress engine with `threading.Lock`.
- Worker thread with cooperative cancellation.
- Rotating file logs.
- Automated test suite with pytest.
- No global mutable state outside the progress engine.

---

## Supported browsers

| Browser | Family | Windows | Linux | macOS |
|---|---|---|---|---|
| Google Chrome | Chromium | Yes | Yes | Yes |
| Microsoft Edge | Chromium | Yes | Yes | Yes |
| Brave | Chromium | Yes | Yes | Yes |
| Vivaldi | Chromium | Yes | Yes | Yes |
| Opera | Chromium | Yes | Yes | Yes |
| Opera GX | Chromium | Yes | Yes | Yes |
| Mozilla Firefox | Firefox | Yes | Yes | Yes |

### Capability matrix

| Browser | Detection | Bookmarks | History | Cookies | Open tabs | Extensions | Settings |
|---|---|---|---|---|---|---|---|
| Google Chrome | SUPPORTED | SUPPORTED | SUPPORTED | SUPPORTED | PARTIAL | PARTIAL | PARTIAL |
| Microsoft Edge | SUPPORTED | SUPPORTED | SUPPORTED | SUPPORTED | PARTIAL | PARTIAL | PARTIAL |
| Brave | SUPPORTED | SUPPORTED | SUPPORTED | SUPPORTED | PARTIAL | PARTIAL | PARTIAL |
| Vivaldi | SUPPORTED | SUPPORTED | SUPPORTED | SUPPORTED | PARTIAL | PARTIAL | PARTIAL |
| Opera | SUPPORTED | SUPPORTED | SUPPORTED | SUPPORTED | PARTIAL | PARTIAL | PARTIAL |
| Opera GX | SUPPORTED | SUPPORTED | SUPPORTED | SUPPORTED | PARTIAL | PARTIAL | PARTIAL |
| Mozilla Firefox | SUPPORTED | PARTIAL | PARTIAL | PARTIAL | PARTIAL | PARTIAL | PARTIAL |

### Legend

- **SUPPORTED** — fully implemented, tested, verified.
- **PARTIAL** — implemented with documented caveats, or read-only.
- **UNSUPPORTED** — explicitly not implemented in this release.
- **NOT_TESTED** — declared but not yet validated.

---

## Migration matrix

This matrix describes source → destination combinations that BrowserShift supports today.

| Source \ Destination | Chromium | Firefox |
|---|---|---|
| Chromium | Full (bookmarks, history, cookies) | Not supported |
| Firefox | Full (bookmarks, history, cookies) | Not supported |

### The most useful migrations

- **Chromium → Chromium** — copy everything from one Chromium browser to another. Chrome → Edge, Edge → Brave, Brave → Vivaldi, and so on.
- **Firefox → Chromium** — copy bookmarks, history and cookies from Firefox into any Chromium browser.

### What BrowserShift refuses to do

- Write into Firefox. The schemas are complex and safe writing requires validation that this release does not provide.
- Migrate extensions universally. Extension IDs, permissions and storage differ between browsers.
- Migrate open tabs. Session files are fragile and browser-specific.
- Migrate settings. Preferences contain machine-specific paths.

If any of these are attempted, the app explicitly says so and refuses to proceed rather than pretending it worked.

---

## Platform support

### Windows 10 / 11

- Uses `%LOCALAPPDATA%` for Chromium user data.
- Uses `%APPDATA%` for Firefox profiles.
- Cookies decrypted with DPAPI and AES-GCM.
- Master key extracted from `Local State`.
- Backup and logs under `%LOCALAPPDATA%\BrowserShift`.

### Linux

- Uses XDG paths: `$XDG_CONFIG_HOME` (`~/.config`) and `$XDG_DATA_HOME` (`~/.local/share`).
- Cookies decrypted with PBKDF2 and AES-GCM.
- PBKDF2 uses password `peanuts`, salt `saltysalt`, 1 iteration, SHA-1.
- Firefox profile root at `~/.mozilla/firefox`.
- Backup and logs under `~/.local/share/BrowserShift`.

### macOS

- Uses `~/Library/Application Support`.
- Firefox profile root at `~/Library/Application Support/Firefox`.
- Bookmark and history migration work fully.
- Cookie migration requires Keychain access and code signing. Not enabled by default.

---

## Browser path reference

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

### Everything you need is in the ZIP

The repository ZIP contains the source tree, the launcher scripts, this README, and the banner under `assets/banner.png`. Extract it and you are ready.

### Windows

1. Extract the ZIP to a folder, for example `C:\Users\<you>\Downloads\BrowserShift\`.
2. Double-click `run.bat`.
3. On first run, `run.bat`:
   - Looks for Python 3.11 or newer on your PATH.
   - If Python is missing, downloads Python 3.11.9 from python.org and installs it silently.
   - Creates `.venv`.
   - Upgrades `pip`.
   - Installs `rich`, `pycryptodome`, `pywin32`.
   - Launches the app.

Subsequent launches skip straight to starting the app.

### Linux and macOS

1. Extract the ZIP to `~/Downloads/BrowserShift/`.
2. Open a terminal in that folder.
3. Run:

```bash
chmod +x run.sh
./run.sh
```

On first run, `run.sh` finds a suitable Python, creates `.venv`, installs dependencies, and starts the app.

### Manual install

If you prefer full control:

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

## Running the app

### Windows

Double-click `run.bat` in the project folder.

### Linux / macOS

```bash
./run.sh
```

### Manual

```bash
python -m browsershift.main
```

### First run

The first run installs dependencies. Subsequent runs start immediately.

---

## Usage walkthrough

1. Launch the app.
2. Watch the animated splash.
3. Read the environment panel: platform, Python version, backup directory.
4. BrowserShift scans for installed browsers.
5. Choose **source browser** and **source profile**.
6. Choose **destination browser** and **destination profile**.
7. Select categories. Bookmarks and history are enabled by default. Cookies can be added if the destination supports them.
8. Review the confirmation panel with full source and destination paths.
9. Confirm.
10. Watch the live migration: progress bars, counters, and per-item lines.
11. Read the finale panel: backup path, imported, skipped, failed.
12. Close the app. You can restore the backup at any time.

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

The finale:

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

## How cookie migration works

Cookies are the most sensitive and technically complex category. Here is exactly what BrowserShift does.

### Chromium on Windows

1. Reads the destination profile's `Local State` file (one directory above the profile).
2. Extracts the `os_crypt.encrypted_key` field.
3. Base64-decodes it and strips the `DPAPI` prefix (first five bytes).
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
3. Derives a 16-byte key using PBKDF2 with password `peanuts`, salt `saltysalt`, 1 iteration, SHA-1.
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

Migrating cookies does not guarantee that you will stay logged in. Many websites use additional signals: browser fingerprinting, HTTP Strict Transport Security state, device-specific tokens, and short cookie expiry. BrowserShift does not make any promise about session validity. It migrates cookies correctly, which is what it can do.

---

## How bookmark migration works

### Reading Chromium bookmarks

1. Opens `<profile>\Bookmarks`.
2. Parses JSON.
3. Walks `roots.bookmark_bar`, `roots.other`, `roots.synced`.
4. Recursively descends folders.
5. Emits `BookmarkItem` with title, URL, and folder tuple.

### Reading Firefox bookmarks

1. Copies `places.sqlite` to a temp file.
2. Opens it in read-only mode.
3. Reads root folders from `moz_bookmarks`.
4. Recursively descends folders and emits `BookmarkItem`.

### Writing Chromium bookmarks

1. Reads destination `Bookmarks` JSON.
2. Collects existing URLs for duplicate detection.
3. For each source item:
   - If the URL already exists, skip it.
   - Otherwise, ensure the folder hierarchy exists, and append.
4. Writes atomically using a temp file and `os.replace`.

Folder hierarchy is preserved. Titles are preserved. Nothing is overwritten.

---

## How history migration works

### Reading Chromium history

1. Copies `History` to a temp file.
2. Opens it read-only.
3. Selects `url, title, visit_count, last_visit_time` from `urls`.
4. Converts `last_visit_time` from Chromium microseconds (1601 epoch) to a `datetime`.

### Reading Firefox history

1. Copies `places.sqlite` to a temp file.
2. Opens it read-only.
3. Selects `url, title, visit_count, last_visit_date` from `moz_places`.
4. Converts `last_visit_date` from Unix microseconds to a `datetime`.

### Writing Chromium history

1. Opens the destination `History` database.
2. Checks the profile is not locked.
3. Reads existing URLs for duplicate detection.
4. For each source item:
   - If the URL already exists, skip it.
   - Otherwise, insert into `urls` and insert a matching row into `visits`.
5. Commits and closes.

Existing entries are preserved. Timestamps are preserved. The destination's own records are never modified.

---

## Architecture

### Layers

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

## Project layout

```
BrowserShift/
├── assets/
│   ├── banner.png
│   ├── logo.svg
│   └── screenshots/
├── docs/
│   ├── architecture.md
│   ├── supported-browsers.md
│   └── security.md
├── src/
│   └── browsershift/
│       ├── __init__.py
│       ├── main.py
│       ├── utils/
│       │   ├── __init__.py
│       │   ├── platform.py
│       │   ├── paths.py
│       │   ├── exceptions.py
│       │   └── redact.py
│       ├── security/
│       │   ├── __init__.py
│       │   ├── permissions.py
│       │   ├── secret_handling.py
│       │   └── windows_crypto.py
│       ├── browsers/
│       │   ├── __init__.py
│       │   ├── base.py
│       │   ├── profiles.py
│       │   ├── chromium.py
│       │   ├── firefox.py
│       │   └── detector.py
│       ├── cookies/
│       │   ├── __init__.py
│       │   ├── chromium.py
│       │   ├── firefox.py
│       │   └── migrate.py
│       ├── backup/
│       │   ├── __init__.py
│       │   ├── create.py
│       │   ├── verify.py
│       │   └── restore.py
│       ├── migration/
│       │   ├── __init__.py
│       │   ├── bookmarks.py
│       │   └── history.py
│       ├── core/
│       │   ├── __init__.py
│       │   ├── plan.py
│       │   ├── progress.py
│       │   └── orchestrator.py
│       └── tui/
│           ├── __init__.py
│           ├── theme.py
│           ├── render.py
│           └── app.py
├── tests/
│   ├── __init__.py
│   ├── test_platform.py
│   ├── test_progress.py
│   ├── test_bookmarks.py
│   ├── test_history.py
│   ├── test_backup.py
│   └── test_redaction.py
├── run.bat
├── run.sh
├── pyproject.toml
├── README.md
├── LICENSE
├── CHANGELOG.md
├── CONTRIBUTING.md
├── SECURITY.md
└── .gitignore
```

---

## Security and privacy

### Principles

- **Local only.** No network calls of any kind.
- **No telemetry.** No analytics, no crash reporting, no usage tracking.
- **No uploads.** No browser data, no profiles, no reports leave your machine.
- **No secrets in logs.** Cookie values, tokens and passwords are never written.
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
- On Linux, cookies are encrypted with a well-known password. This is a Chromium design decision, not a BrowserShift one.
- On macOS, cookies are not migrated in this release.

### Reporting

See `SECURITY.md`. Report privately. Do not open public issues for security problems.

---

## Backup and restore

### Creation

Before any write, BrowserShift creates a backup of the destination profile:

- Copies `Bookmarks`, `History`, `Preferences`, `Cookies`, `Web Data` and `Local State`.
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

## Progress engine

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

A task with unknown total does not advance the percentage. That prevents misleading UI.

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

The test suite uses pytest. Current coverage includes:

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

## Adding a browser

1. Add a `ChromiumTarget` entry to `CHROMIUM_TARGETS`, or create a new adapter in `browsers/`.
2. Implement `detect`, `read_bookmarks`, `read_history`.
3. Declare `capabilities()` honestly.
4. Add tests under `tests/`.
5. Update the supported browsers table in this README.

---

## Adding a category

1. Create a module under `migration/` or `cookies/`.
2. Accept `(source_adapter, source_profile, dest_adapter, dest_profile, progress)`.
3. Use `progress.emit`, `progress.tick_imported`, `progress.tick_skipped`, `progress.tick_failed`.
4. Register the category in `core/orchestrator.py`.
5. Update the migration matrix in this README.

---

## Known limitations

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

## Design decisions

### Why a terminal UI instead of a GUI

A terminal UI is portable, scriptable, fast, and works over SSH. It also removes an entire class of cross-platform GUI issues. `rich` provides the visual polish without the weight of a full desktop toolkit.

### Why purple and white

The palette is deliberately restrained. Purple is a strong accent that reads well on both dark and light terminals. White text ensures contrast. Nothing is garish.

### Why mandatory backups

Any write into a browser profile is potentially destructive. A verified backup before every migration removes the risk of an irreversible mistake.

### Why a capability registry

Claiming support for something that is not implemented is worse than admitting the limitation. The capability registry makes the truth visible in the UI.

### Why no network code

The application has no reason to talk to the internet. Removing network code removes an entire attack surface and makes the privacy guarantee verifiable.

---

## Troubleshooting

### "Python not found"

Install Python 3.11+ from python.org, or let `run.bat` do it automatically on Windows.

### "Failed to create virtual environment"

Ensure you have write permissions in the project folder. Try running from a non-system location such as `~/Downloads/BrowserShift` or `%USERPROFILE%\Downloads\BrowserShift`.

### "Profile is in use"

Close the destination browser before running a migration. Chromium locks its `History` database while running.

### "No supported browsers detected"

Install at least one supported browser. Verify that the browser has been launched at least once so a profile exists.

### "Cookies were not decrypted"

On Windows, the DPAPI key is tied to your user account. If you copied a profile from another user or machine, its cookies cannot be decrypted. This is by design.

On Linux, verify that `pycryptodome` is installed correctly.

### "Migration took a long time"

Very large histories require a SQLite insert per entry. One million entries can take a few minutes. This is expected.

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
Yes. Detection, bookmarks, history and cookies all work on Linux.

**Does it work on macOS?**
Bookmarks and history work. Cookies do not in this release.

**Can I run it without installing Python?**
On Windows, `run.bat` downloads and installs Python silently if it is missing.

**Where are backups stored?**
Windows: `%LOCALAPPDATA%\BrowserShift\backups\`. Linux: `~/.local/share/BrowserShift/backups/`. macOS: `~/Library/Application Support/BrowserShift/backups/`.

**Can I migrate between two profiles of the same browser?**
Yes. Source and destination profiles are independent.

**Does it work while my browser is open?**
Reading works. Writing to Chromium `History` requires the browser to be closed. The app detects the lock and refuses to proceed.

**Is my data encrypted during migration?**
Cookies are decrypted in memory, migrated, and re-encrypted with the destination key. Other data is written in the destination's own format.

**Can I delete the app after migration?**
Yes. The app writes everything into standard browser locations. Once the migration is done, you can delete the app folder. The app itself says so at the end of every successful migration.

**Where is the banner from?**
The banner is included in the repository as `assets/banner.png`. It ships with the ZIP.

**Can I customize the theme?**
Yes. Edit `src/browsershift/tui/theme.py` and change the color constants.

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

## Code of conduct

Be kind. Be precise. Do not break things on purpose. Report issues with reproducible steps. Assume good faith.

---

## Credits

BrowserShift is built on the shoulders of these projects:

- [Python](https://www.python.org/) — the language.
- [rich](https://github.com/Textualize/rich) — the terminal UI.
- [pycryptodome](https://www.pycryptodome.org/) — AES-GCM and PBKDF2.
- [pywin32](https://github.com/mhammond/pywin32) — DPAPI on Windows.
- [SQLite](https://www.sqlite.org/) — the browser databases.
- [Shields.io](https://shields.io/) — the badges.

---

## License

MIT License. See `LICENSE`.

---

## Security policy

See `SECURITY.md`. Report vulnerabilities privately. Do not open public issues for security problems.

---

<p align="center">
  <sub>Built with care, honesty, and a lot of SQLite.</sub>
</p>

<p align="center">
  <a href="#browsershift">Back to top</a>
</p>
