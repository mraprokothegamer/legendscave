Config = {}

Config.Debug = true
Config.Framework = 'auto'
Config.Hud = '17mov_Hud'
Config.HudResource = '17mov_Hud'

Config.NuiPosition = 'near-player'
Config.TargetDistance = 2.0

-- FREE water
Config.FreeWater = true
Config.WaterPrice = 0
Config.ThirstRefill = 30
Config.ThirstMax = 1000000

Config.EnableCooldown = false
Config.MaxDrinksPerHour = 10
Config.CooldownWindow = 60 * 60

Config.AnimDict = 'mp_player_intdrink'
Config.AnimName = 'loop_bottle'

-- ~10 seconds to fill + drink
Config.FillDuration = 10000
Config.SipDelay = 500
Config.AnimDuration = 12000

-- LEFT hand red plastic cup (PH_L_Hand wants small offsets)
Config.CupModel = `prop_plastic_cup_02`
Config.CupModelFallback = `ng_proc_sodacup_01a`
Config.CupBone = 60309
Config.CupOffset = { x = 0.02, y = 0.02, z = -0.01 }
Config.CupRotation = { x = -15.0, y = 0.0, z = 0.0 }

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

Config.ScanKeywords = { 'watercooler' }
Config.KnownModels = {
    `prop_watercooler`,
    `prop_watercooler_dark`,
}

Config.RescanInterval = 30000
Config.InitialScanDelay = 5000
