Config = {}

-- How many times a player may use emergency water within the rolling window.
Config.UsesPerHour = 3

-- Length of the rolling window, in minutes. Uses older than this no longer count.
Config.WindowMinutes = 60

-- How much thirst each use restores (additive, capped at 100).
Config.ThirstRestore = 45

-- How long the drink takes (ms). The player stays in the drinking animation for
-- this whole time while the middle-right NUI fills the cup with water; both end
-- together when the cup is full.
Config.DrinkDuration = 10000

-- ox_target option appearance.
Config.TargetLabel = 'Drink water'
Config.TargetIcon = 'fa-solid fa-glass-water'
Config.TargetDistance = 2.0

-- Drinking animation played on the ped for the duration of the drink.
-- Swap for any valid dict/clip you prefer.
Config.Anim = {
    dict = 'mp_player_intdrink',
    clip = 'loop_bottle',
    flag = 49, -- upper-body + loop, lets the player keep moving
}

-- Cup prop held in the player's LEFT hand while drinking.
-- `bone` 18905 is SKEL_L_Hand (left hand). Tune offset/rotation on your server
-- since exact fit varies by prop; set `model = false` to disable the held prop.
--
-- IMPORTANT: use a real GTA prop. `ng_proc_watercup_01` is NOT a valid model
-- (hash -487885758) and will crash ox_lib requestModel.
-- Good options: prop_cs_paper_cup, prop_plastic_cup_02, p_amb_coffeecup_01,
-- ng_proc_sodacup_01a, apa_prop_cs_plastic_cup_01
Config.Cup = {
    model = 'prop_cs_paper_cup',
    fallback = 'prop_plastic_cup_02',
    bone = 18905,
    offset = { x = 0.12, y = 0.028, z = 0.001 },
    rotation = { x = 10.0, y = 175.0, z = 0.0 },
}

-- Pour/gulp sound. Played through the NUI (HTML5 audio) so it needs no extra deps.
-- Drop your own file into html/sounds/ and point `file` at it to change the sound.
Config.Sound = {
    enabled = true,
    file = 'pour.wav',
    volume = 0.5,
}

-- Every water cooler / dispenser prop to attach the interaction to.
-- These are ox_target model names; add or remove freely.
Config.Props = {
    -- Freestanding office water coolers (blue bottle on a white stand)
    'prop_watercooler',
    'prop_watercooler_dark',
    -- Water vending machine
    'prop_vend_water_01',

    -- Wall-mounted fountains / other coolers vary by map & MLO. Add the exact
    -- model names your server uses here, for example:
    -- 'v_res_watercooler',
    -- 'ex_office_watercooler',
    -- 'apa_mp_h_acc_watercooler_01',
}
