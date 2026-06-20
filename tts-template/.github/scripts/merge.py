#!/usr/bin/env python3
"""Merge WAV segments from ShryneTTS into a single file, preserving order."""

import os
import sys
from pydub import AudioSegment

def main():
    audio_paths_raw = os.environ.get("AUDIO_PATHS", "").strip()
    if not audio_paths_raw:
        print("No audio paths provided", file=sys.stderr)
        sys.exit(1)

    paths = [p.strip() for p in audio_paths_raw.split("\n") if p.strip()]
    if not paths:
        print("No audio files to merge", file=sys.stderr)
        sys.exit(1)

    print(f"Merging {len(paths)} segment(s)...", file=sys.stderr)
    merged = AudioSegment.empty()
    for i, path in enumerate(paths):
        print(f"  [{i+1}/{len(paths)}] {path}", file=sys.stderr)
        segment = AudioSegment.from_wav(path)
        merged += segment

    merged.export("merged.wav", format="wav")
    duration_s = len(merged) / 1000.0
    print(f"Done — merged.wav ({duration_s:.1f}s)", file=sys.stderr)

if __name__ == "__main__":
    main()
