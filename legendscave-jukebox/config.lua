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
    -- Portable / classic
    `prop_boombox_01`,
    `prop_ghettoblast_01`,
    `prop_ghettoblast_02`,
    `prop_portable_hifi_01`,
    `prop_hifi_01`,
    `prop_radio_01`,
    `prop_mp3_dock`,
    `prop_console_01`,

    -- Jukeboxes
    `prop_jukebox_01`,
    `prop_jukebox_02`,

    -- Speakers / amp
    `prop_out_door_speaker`,
    `prop_speaker_01`,
    `prop_speaker_02`,
    `prop_speaker_03`,
    `prop_speaker_05`,
    `prop_speaker_06`,
    `prop_speaker_07`,
    `prop_speaker_08`,
    `prop_amp_01`,
    `sf_prop_sf_speaker_l_01a`,
    `sf_prop_sf_speaker_stand_01a`,
    `sf_prop_sf_speaker_wall_01a`,
    `as_prop_as_speakerdock`,

    -- Interior audio
    `v_res_pcspeaker`,
    `v_res_mm_audio`,
    `v_res_fh_speakerdock`,
    `v_club_vu_djunit`,
    `v_club_vu_deckcase`,
    `v_club_roc_eq1`,
    `v_club_roc_eq2`,

    -- DJ booths / decks / mixers (base + After Hours / Cayo)
    `prop_dj_deck_01`,
    `prop_dj_deck_02`,
    `ba_prop_battle_dj_stand`,
    `ba_prop_battle_dj_deck_01a`,
    `ba_prop_battle_dj_kit_mixer`,
    `ba_prop_battle_dj_kit_speaker`,
    `ba_prop_battle_dj_mixer_01a`,
    `ba_prop_battle_dj_mixer_01b`,
    `ba_prop_battle_dj_mixer_01c`,
    `ba_prop_battle_dj_mixer_01d`,
    `ba_prop_battle_dj_mixer_01e`,
    `h4_prop_battle_dj_stand`,
    `h4_prop_battle_dj_deck_01a`,
    `h4_prop_battle_dj_deck_01b`,
    `h4_prop_battle_dj_kit_mixer`,
    `h4_prop_battle_dj_kit_speaker`,
    `h4_prop_battle_dj_mixer_01a`,
    `h4_prop_battle_dj_mixer_01b`,
    `h4_prop_battle_dj_mixer_01c`,
    `h4_prop_battle_dj_mixer_01d`,
    `h4_prop_battle_dj_mixer_01e`,
    `h4_prop_battle_dj_mixer_01f`,
    `h4_prop_battle_dj_box_01a`,
    `h4_prop_battle_dj_box_02a`,
    `h4_prop_battle_dj_box_03a`,

    -- Home theatre / apartment AV units (TV + media player / stereo below)
    `apa_mp_h_str_avunitl_01_b`,
    `apa_mp_h_str_avunitl_04`,
    `apa_mp_h_str_avunitm_01`,
    `apa_mp_h_str_avunitm_03`,
    `apa_mp_h_str_avunits_01`,
    `apa_mp_h_str_avunits_04`,
    `hei_heist_str_avunitl_01`,
    `hei_heist_str_avunitl_03`,
    `hei_heist_str_avunits_01`,

    -- TV cabinets / home stereo stacks (common in older interiors)
    `prop_tv_cabinet_03`,
    `prop_tv_cabinet_04`,
    `prop_tv_cabinet_05`,
    `v_res_fh_speaker`,
    `v_16_hifi`,
    `v_ind_cs_hifi`,
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
