Config = {}

Config.Debug = false
Config.Framework = 'auto'
Config.Hud = '17mov_Hud'
Config.HudResource = '17mov_Hud'

-- NUI near player (slightly right of center) — not covering animation, not far edge
Config.NuiPosition = 'near-player'
Config.TargetDistance = 2.0

-- FREE water for everyone
Config.FreeWater = true
Config.WaterPrice = 0
Config.ThirstRefill = 30
Config.ThirstMax = 1000000

Config.EnableCooldown = false
Config.MaxDrinksPerHour = 10
Config.CooldownWindow = 60 * 60

Config.AnimDict = 'mp_player_intdrink'
Config.AnimName = 'loop_bottle'
Config.FillDuration = 7000
Config.SipDelay = 400
Config.AnimDuration = Config.FillDuration + 2500

-- LEFT hand cup (60309 = PH_L_Hand — best bone for handheld props)
Config.CupModel = `prop_plastic_cup_02`
Config.CupModelFallback = `apa_prop_cs_plastic_cup_01`
Config.CupBone = 60309
Config.CupOffset = { x = 0.13, y = 0.04, z = -0.04 }
Config.CupRotation = { x = -80.0, y = 0.0, z = -20.0 }

Config.PourSound = {
    name = 'Pour',
    bank = 'DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS',
}
Config.SipSound = {
    name = 'Drink',
    bank = 'DLC_Dmod_Prop_Editor_Sounds',
}

Config.Remarks = {
    'Ah, that hits the spot. I really needed that.',
    'Cold water on a hot day — nothing better.',
    'My throat was so dry... feeling human again.',
    'Public water never tasted so good.',
    'Feeling refreshed.',
}

-- Existing Rockstar coolers in the map (no spawning)
Config.ScanKeywords = { 'watercooler' }
Config.KnownModels = {
    `prop_watercooler`,
    `prop_watercooler_dark`,
}

Config.RescanInterval = 30000
Config.InitialScanDelay = 5000
