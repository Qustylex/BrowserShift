# BrowserShift

> Switch browsers. Keep your flow.

A beautiful terminal application that migrates your browsing data between installed browsers. Windows, Linux and macOS. Auto-detects the operating system.

## Features

- Real browser detection: Chrome, Edge, Brave, Vivaldi, Opera, Opera GX, Firefox.
- Real profile discovery with absolute paths.
- Real bookmark and history migration into Chromium-based browsers.
- Streaming view: watch every single item being imported in real time.
- Verified SHA-256 backup before any modification.
- Restore support for every backup.
- Beautiful purple and white terminal interface.
- Zero telemetry. Zero network. 100% local.

## Windows: one-click

Double-click `run.bat`. If Python is missing, it is downloaded and installed automatically, then the app launches.

## Linux / macOS

```bash
chmod +x run.sh
./run.sh
```

## Manual install

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e .
python -m browsershift.main
```

## License

MIT