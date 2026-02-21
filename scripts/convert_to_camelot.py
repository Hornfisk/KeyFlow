#!/usr/bin/env python3
import os, re, sys
from pathlib import Path

key_map = {
    'C': '8B', 'C#': '3B', 'Db': '3B', 'D': '10B', 'D#': '5B', 'Eb': '5B',
    'E': '12B', 'F': '7B', 'F#': '2B', 'Gb': '2B', 'G': '9B', 'G#': '4B',
    'Ab': '4B', 'A': '11B', 'A#': '6B', 'Bb': '6B', 'B': '1B',
    'Cm': '5A', 'C#m': '12A', 'Dbm': '12A', 'Dm': '7A', 'D#m': '2A', 'Ebm': '2A',
    'Em': '9A', 'Fm': '4A', 'F#m': '11A', 'Gbm': '11A', 'Gm': '6A', 'G#m': '1A',
    'Abm': '1A', 'Am': '8A', 'A#m': '3A', 'Bbm': '3A', 'Bm': '10A'
}

root = Path(sys.argv[1]).expanduser() if len(sys.argv) > 1 else Path.home() / "Music" / "Organized"
pattern = re.compile(r'^\[(?P<trad>.*?)\](?P<rest>.*)$')

for dirpath, _, files in os.walk(root):
    for fn in files:
        m = pattern.match(fn)
        if m and m.group('trad') in key_map:
            old, new = Path(dirpath) / fn, Path(dirpath) / f"[{key_map[m.group('trad')]}] {m.group('rest').strip()}"
            old.rename(new)
