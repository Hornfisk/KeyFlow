#!/usr/bin/env python3
import sys, subprocess, shutil, re, os
from pathlib import Path

# These are placeholders that the install.sh will update
SRC = Path.home() / "Music"
DST = Path.home() / "Music" / "Organized"
EXTS = {'.mp3', '.flac', '.wav', '.m4a', '.aac', '.ogg'}

KEY_PREFIX_RE = re.compile(r'^(?P<key>(?:[A-G](?:#|b)?m?|[A-G](?:#|b)?))(?:[ _\-\.:]+)', re.IGNORECASE)
NUM_PREFIX_RE = re.compile(r'^(?:\d{1,3})(?:[ _\-\.:]+)')

def detect_key(path):
    try:
        out = subprocess.run(['keyfinder-cli', str(path)], capture_output=True, text=True, timeout=120)
        if out.returncode == 0:
            lines = [l.strip() for l in out.stdout.splitlines() if l.strip()]
            return lines[0] if lines else None
    except Exception as e:
        print(f"Error analyzing {path.name}: {e}")
    return None

def safe_copy(src: Path, dst: Path):
    dst.parent.mkdir(parents=True, exist_ok=True)
    if dst.exists():
        base, suff = dst.stem, dst.suffix
        i = 1
        while True:
            candidate = dst.parent / f"{base}.{i}{suff}"
            if not candidate.exists():
                dst = candidate
                break
            i += 1
    shutil.copy2(src, dst)
    return dst

def strip_leading_key_and_number(name):
    m = KEY_PREFIX_RE.match(name)
    leading_key, rest = None, name
    if m:
        leading_key = m.group('key')
        rest = name[m.end():].lstrip(' _-.:')
    rest = NUM_PREFIX_RE.sub('', rest)
    return leading_key, rest

def process_file(p: Path, rel_parent: Path):
    if p.suffix.lower() not in EXTS: return
    detected = detect_key(p)
    leading_key, cleaned = strip_leading_key_and_number(p.name)
    keytag = detected if detected else (leading_key if leading_key else "??")
    newname = f"[{keytag}] {cleaned}"
    target = DST / rel_parent / newname
    try:
        safe_copy(p, target)
        print(f"Processed: {newname}")
    except Exception as e:
        print(f"Failed: {p.name} ({e})")

def main():
    targets = sys.argv[1:] if len(sys.argv) > 1 else [SRC]
    for t in targets:
        s = Path(t).expanduser().resolve()
        if not s.exists(): continue
        if s.is_file():
            process_file(s, Path())
        else:
            parent_name = s.name
            for root, _, files in os.walk(s):
                rootp = Path(root).resolve()
                rel = Path(parent_name) / rootp.relative_to(s)
                for f in files:
                    if not f.startswith('._'):
                        process_file(rootp / f, rel)

if __name__ == "__main__":
    main()
