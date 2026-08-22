Config = {}

-- Set true for F8 debug logs + /testwater /testnui
Config.Debug = false

-- Framework: 'auto', 'qbox', or 'esx'
Config.Framework = 'auto'

-- HUD: '17mov_Hud', 'auto', or 'default'
Config.Hud = '17mov_Hud'
Config.HudResource = '17mov_Hud'

-- NUI fill panel (far right)
Config.NuiPosition = 'bottom-right'
Config.NuiPaddingRight = 4

-- ox_target
Config.TargetDistance = 2.0

-- Pricing + thirst (original design)
Config.FreeWater = false
Config.WaterPrice = 10
Config.ThirstRefill = 30

-- esx_status max (ESX only)
Config.ThirstMax = 1000000

-- Optional anti-spam (set EnableCooldown = false to disable)
Config.EnableCooldown = false
Config.MaxDrinksPerHour = 10
Config.CooldownWindow = 60 * 60

-- Animation + fill timing
Config.AnimDict = 'mp_player_intdrink'
Config.AnimName = 'loop_bottle'
Config.FillDuration = 7000
Config.SipDelay = 400
Config.AnimDuration = Config.FillDuration + 2500

-- Cup in RIGHT hand (57005 = SKEL_R_Hand)
-- prop_cs_paper_cup is invalid on some builds — use plastic cup first
Config.CupModel = `prop_plastic_cup_02`
Config.CupModelFallback = `p_amb_coffeecup_01`
Config.CupBone = 57005
Config.CupOffset = { x = 0.12, y = 0.02, z = -0.02 }
Config.CupRotation = { x = -80.0, y = 0.0, z = 10.0 }

-- Sounds
Config.PourSound = {
    name = 'Pour',
    bank = 'DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS',
}

Config.SipSound = {
    name = 'Drink',
    bank = 'DLC_Dmod_Prop_Editor_Sounds',
}

-- Random remarks after drinking
Config.Remarks = {
    'Ah, that hits the spot. I really needed that.',
    'Cold water on a hot day — nothing better.',
    'My throat was so dry... feeling human again.',
    'Public water never tasted so good.',
    'Worth every dollar. Feeling refreshed.',
}

-- Multiple scan keywords (auto-detect props)
Config.ScanKeywords = {
    'watercooler',
    'dispenser',
    'hydrant',
}

-- Always register these models
Config.KnownModels = {
    `prop_watercooler`,
    `prop_watercooler_dark`,
}

Config.RescanInterval = 30000
Config.InitialScanDelay = 5000
