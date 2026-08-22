Config = {}

Config.Debug = false
Config.Framework = 'auto'
Config.Hud = '17mov_Hud'
Config.HudResource = '17mov_Hud'

-- Far right so NUI does not block the player
Config.NuiPosition = 'bottom-right'
Config.NuiPaddingRight = 8
Config.TargetDistance = 2.0

Config.FreeWater = false
Config.WaterPrice = 10
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

-- RIGHT hand — use plastic cup (paper cup crashes on many builds)
Config.CupModel = `prop_plastic_cup_02`
Config.CupModelFallback = `p_amb_coffeecup_01`
Config.CupBone = 57005
Config.CupOffset = { x = 0.12, y = 0.02, z = -0.02 }
Config.CupRotation = { x = -80.0, y = 0.0, z = 10.0 }

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
    'Worth every dollar. Feeling refreshed.',
}

-- Existing Rockstar coolers in the map (no spawning)
Config.ScanKeywords = { 'watercooler' }
Config.KnownModels = {
    `prop_watercooler`,
    `prop_watercooler_dark`,
}

Config.RescanInterval = 30000
Config.InitialScanDelay = 5000
