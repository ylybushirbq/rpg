#!/usr/bin/env python3
"""Rotate Meowa API profiles when the active key has no credits."""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PROFILES_DIR = ROOT / ".meowa" / "profiles"
ACTIVE_FILE = ROOT / ".meowa" / "active"
RUNNER = ROOT / ".agents" / "skills" / "game-assets" / "meowart_api.py"
ORDER = ["primary", "second", "third"]
TARGETS = [
    ROOT / ".env",
    ROOT / ".agents" / "skills" / "game-assets" / ".env",
]


def _profile_path(name: str) -> Path:
    path = PROFILES_DIR / f"{name}.env"
    if not path.is_file():
        raise FileNotFoundError(f"missing profile: {name}")
    return path


def _read_key(name: str) -> str:
    for line in _profile_path(name).read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if stripped.startswith("MEOWART_API_KEY="):
            return stripped.split("=", 1)[1].strip().strip("'\"")
    raise ValueError(f"no MEOWART_API_KEY in profile {name}")


def _active_name() -> str:
    if ACTIVE_FILE.is_file():
        name = ACTIVE_FILE.read_text(encoding="utf-8").strip()
        if name:
            return name
    return ORDER[0]


def activate(name: str) -> None:
    source = _profile_path(name)
    for target in TARGETS:
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
    ACTIVE_FILE.write_text(name, encoding="ascii")
    os.environ["MEOWART_API_KEY"] = _read_key(name)


def _credits(name: str) -> dict:
    env = os.environ.copy()
    env.pop("MEOWART_DEV_KEY", None)
    env["MEOWART_API_KEY"] = _read_key(name)
    result = subprocess.run(
        [sys.executable, str(RUNNER), "credits-balance"],
        cwd=str(ROOT),
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        err = (result.stderr or result.stdout or "credits-balance failed").strip()
        raise RuntimeError(f"{name}: {err}")
    payload = json.loads(result.stdout)
    return {
        "profile": name,
        "total_credits": int(payload.get("total_credits") or 0),
        "trial_credits": int(payload.get("trial_credits") or 0),
        "paid_credits": int(payload.get("paid_credits") or 0),
    }


def _order_from(start: str) -> list[str]:
    names = [name for name in ORDER if (PROFILES_DIR / f"{name}.env").is_file()]
    if start in names:
        idx = names.index(start)
        return names[idx:] + names[:idx]
    return names


def status() -> list[dict]:
    rows: list[dict] = []
    active = _active_name()
    for name in ORDER:
        if not (PROFILES_DIR / f"{name}.env").is_file():
            continue
        row = _credits(name)
        row["active"] = name == active
        rows.append(row)
    return rows


def ensure(min_credits: int = 1) -> dict:
    active = _active_name()
    last_error = ""
    for name in _order_from(active):
        try:
            row = _credits(name)
        except Exception as exc:  # noqa: BLE001
            last_error = str(exc)
            continue
        if row["total_credits"] >= min_credits:
            if name != active:
                activate(name)
                row["switched_from"] = active
            else:
                activate(name)
            row["active"] = True
            return row
    raise RuntimeError(
        last_error or f"no Meowa profile has at least {min_credits} credits"
    )


def rotate(min_credits: int = 1) -> dict:
    active = _active_name()
    names = _order_from(active)
    if len(names) > 1:
        names = names[1:] + names[:1]
    last_error = ""
    for name in names:
        try:
            row = _credits(name)
        except Exception as exc:  # noqa: BLE001
            last_error = str(exc)
            continue
        if row["total_credits"] >= min_credits:
            activate(name)
            row["active"] = True
            row["switched_from"] = active
            return row
    raise RuntimeError(last_error or "no remaining Meowa profile has credits")


def main() -> int:
    command = sys.argv[1] if len(sys.argv) > 1 else "status"
    min_credits = int(sys.argv[2]) if len(sys.argv) > 2 else 1
    if command == "status":
        print(json.dumps(status(), ensure_ascii=False, indent=2))
        return 0
    if command == "ensure":
        print(json.dumps(ensure(min_credits), ensure_ascii=False, indent=2))
        return 0
    if command == "rotate":
        print(json.dumps(rotate(min_credits), ensure_ascii=False, indent=2))
        return 0
    if command == "use":
        if len(sys.argv) < 3:
            raise SystemExit("usage: rotate.py use <profile>")
        activate(sys.argv[2])
        print(json.dumps({"active": sys.argv[2]}, ensure_ascii=False, indent=2))
        return 0
    raise SystemExit("usage: rotate.py [status|ensure|rotate|use] [min_credits|profile]")


if __name__ == "__main__":
    raise SystemExit(main())
