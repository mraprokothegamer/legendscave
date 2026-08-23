Config = {}

--- Hearing / marker radius (metres). Keep modest for performance.
Config.SoundDistance = 20.0
Config.MarkerDrawDistance = 25.0
Config.Volume = 0.5

--- Default playlist shown in NUI (YouTube video ids).
Config.Playlist = {
    { id = 'dQw4w9WgXcQ', title = 'Track One', artist = 'Artist A', duration = 212 },
    { id = 'kJQP7kiw5Fk', title = 'Track Two', artist = 'Artist B', duration = 281 },
}

--- Rockstar / GTA audio props already placed in the world (not inventory items).
--- Names verified against common GTA V object lists; invalid hashes are skipped by the game.
Config.MusicProps = {
    `prop_boombox_01`,
    `prop_ghettoblast_01`,
    `prop_ghettoblast_02`,
    `prop_portable_hifi_01`,
    `prop_radio_01`,
    `prop_mp3_dock`,
    `prop_jukebox_01`,
    `prop_jukebox_02`,
    `prop_out_door_speaker`,
    `prop_speaker_01`,
    `prop_speaker_02`,
    `prop_speaker_03`,
    `prop_speaker_05`,
    `prop_speaker_06`,
    `prop_speaker_07`,
    `prop_speaker_08`,
    `prop_amp_01`,
    `v_res_pcspeaker`,
    `v_res_mm_audio`,
    `v_res_fh_speakerdock`,
    `v_club_vu_djunit`,
}

Config.Target = {
    icon = 'fa-solid fa-music',
    label = 'Open Jukebox',
    distance = 2.0,
}

--- World marker ring above the active prop (off by default — looks noisy)
Config.ShowMarker = false

--- Neon marker (type 28 = horizontal circle) — only used when ShowMarker is true
Config.Marker = {
    type = 28,
    offsetZ = 1.0,
    scale = 0.45,
    r = 255,
    g = 255,
    b = 0,
    a = 140,
}

Config.Text = {
    offsetZ = 1.25,
    fadeStep = 8,   -- alpha change per frame tick (~every 50ms in fade threads)
    fadeWait = 40,  -- ms between fade steps
    maxAlpha = 215,
}
