import hashlib
import json
import shutil
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path

from ..browsers.base import BrowserProfile
from ..utils.paths import backups_dir
from ..utils.exceptions import BackupError


BACKUP_FILES = ("Bookmarks", "History", "Preferences", "Cookies", "Web Data", "Local State")


@dataclass
class BackupResult:
    identifier: str
    path: Path
    file_count: int


def create_backup(destination_profile: BrowserProfile, browser_id: str, on_progress=None) -> BackupResult:
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    safe = "".join(ch if ch.isalnum() or ch in "-_" else "_" for ch in destination_profile.id)
    ident = f"{browser_id}-{safe}-{stamp}"
    target = backups_dir() / ident
    target.mkdir(parents=True, exist_ok=True)

    manifest = {
        "identifier": ident,
        "created_at": datetime.now().isoformat(timespec="seconds"),
        "browser_id": browser_id,
        "profile_id": destination_profile.id,
        "profile_path": str(destination_profile.path),
        "files": [],
    }

    local_state = destination_profile.path.parent / "Local State"
    sources = []
    for name in BACKUP_FILES:
        f = destination_profile.path / name
        if f.is_file():
            sources.append(f)
    if local_state.is_file():
        sources.append(local_state)

    total = len(sources)
    done = 0
    for source in sources:
        dest = target / source.name
        try:
            shutil.copy2(source, dest)
        except Exception as exc:
            raise BackupError(f"Failed to copy {source.name}: {exc}") from exc
        manifest["files"].append({
            "name": source.name,
            "size": dest.stat().st_size,
            "sha256": _sha256(dest),
        })
        done += 1
        if on_progress:
            on_progress(done, total)

    (target / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8",
    )
    return BackupResult(identifier=ident, path=target, file_count=total)


def _sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()
