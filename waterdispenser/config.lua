Config = {}

-- Set true to print dispenser registration logs to console
Config.Debug = false

-- Framework: 'auto', 'qbox', or 'esx'
Config.Framework = 'auto'

-- HUD integration: '17mov_Hud', 'auto', or 'default'
Config.Hud = '17mov_Hud'
Config.HudResource = '17mov_Hud'

-- NUI position: 'bottom-right' (far right edge) or 'bottom-left'
Config.NuiPosition = 'bottom-right'

-- Pixels from right edge of screen for fill UI (lower = further right)
Config.NuiPaddingRight = 4

-- ox_target settings
Config.TargetLabel = 'Drink Water'
Config.TargetDistance = 2.0

-- Emergency city water: free for everyone
Config.FreeWater = true

-- Thirst refill percentage (0-100)
Config.ThirstRefill = 10

-- esx_status max thirst value (ESX only)
Config.ThirstMax = 1000000

-- Anti-spam: max drinks per player per cooldown window
Config.MaxDrinksPerHour = 2
Config.CooldownWindow = 60 * 60

-- Animation
Config.AnimDict = 'mp_player_intdrink'
Config.AnimName = 'loop_bottle'
Config.FillDuration = 7000
Config.SipDelay = 400
Config.AnimDuration = Config.FillDuration + 2500

-- Cup prop attachment (left hand bone 18905 = SKEL_L_Hand)
Config.CupModel = `prop_cs_paper_cup`
Config.CupModelFallback = `prop_plastic_cup_02`
Config.CupBone = 18905
Config.CupOffset = { x = 0.12, y = 0.028, z = 0.001 }
Config.CupRotation = { x = 10.0, y = 175.0, z = 0.0 }

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
    'Emergency hydration complete. I\'m good for now.',
}

-- Auto-detect dispensers by prop archetype keyword
Config.ScanKeywords = {
    'watercooler',
    'dispenser',
    'hydrant',
}

-- Always register these models immediately
Config.KnownModels = {
    `prop_watercooler`,
    `prop_watercooler_dark`,
}

-- World scan timing
Config.RescanInterval = 30000
Config.InitialScanDelay = 5000
