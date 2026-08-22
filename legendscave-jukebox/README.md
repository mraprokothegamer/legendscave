# Legendscave Jukebox

Qbox-ready FiveM resource: players **target existing Rockstar music props** (boombox, speakers, radios, jukeboxes) with `ox_target`, open a neon NUI, and play **YouTube** audio **locally** at that prop via `xsound` (nearby players only).

## Dependencies

- [ox_target](https://github.com/overextended/ox_target)
- [xsound](https://github.com/Xogy/xsound)

Works on Qbox servers; no inventory item is required.

## Install

1. Copy `legendscave-jukebox` into your `resources` folder.
2. Ensure start order:

```cfg
ensure ox_target
ensure xsound
ensure legendscave-jukebox
```

3. Edit `config.lua` for playlist, volume, and hearing distance.

## Features

- Targets **world props only** (no usable item).
- Each prop is its own sound source (`PlayUrlPos` + distance).
- Neon NUI: equalizer, circular play control, progress bar, elapsed/total time, playlist thumbnails, custom YouTube URL/ID.
- Lightweight active-prop visuals: one shared draw loop, neon ring marker, floating “Now Playing” text with **fade in / fade out**.

## Config props

Verified-style models in `Config.MusicProps` include boomboxes, ghettoblasters, speakers, jukeboxes, docks, etc. Add or remove hashes there as needed for your map.

## Notes

- Some YouTube videos block iframe/embed playback; those will fail in xsound (upstream limitation).
- Marker/text only draw within `Config.MarkerDrawDistance` and only while a prop is active.
