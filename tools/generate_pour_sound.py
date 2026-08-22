#!/usr/bin/env python3
"""Generate ls_waterdispenser/html/sounds/pour.wav.

Synthesises a ~5s water-pour/gulp placeholder from filtered noise so the
resource ships with working audio. Uses only the Python standard library.
Replace the .wav with a nicer asset any time; this just guarantees sound works.
"""
import math
import os
import random
import struct
import wave

SAMPLE_RATE = 22050
DURATION = 5.0
OUT = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "ls_waterdispenser", "html", "sounds", "pour.wav",
)


def envelope(t: float) -> float:
    """Fade in, sustain, fade out over the clip."""
    fade_in = min(1.0, t / 0.25)
    fade_out = min(1.0, (DURATION - t) / 0.4)
    return max(0.0, min(fade_in, fade_out))


def main() -> None:
    random.seed(7)
    total = int(SAMPLE_RATE * DURATION)

    # One-pole low-pass state + a slow "bubble" amplitude wobble.
    lp = 0.0
    samples = []
    for i in range(total):
        t = i / SAMPLE_RATE
        white = random.uniform(-1.0, 1.0)
        # Low-pass to turn harsh white noise into a softer water rush.
        lp += 0.06 * (white - lp)
        bubble = 0.6 + 0.4 * math.sin(2 * math.pi * 3.5 * t + math.sin(t * 7.0))
        val = lp * bubble * envelope(t) * 0.7
        clamped = max(-1.0, min(1.0, val))
        samples.append(int(clamped * 32767))

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with wave.open(OUT, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        w.writeframes(b"".join(struct.pack("<h", s) for s in samples))

    print(f"Wrote {OUT} ({os.path.getsize(OUT)} bytes, {DURATION}s @ {SAMPLE_RATE}Hz)")


if __name__ == "__main__":
    main()
