Config = {}

-- Emergency city water: free for everyone
Config.FreeWater = true

-- Thirst refill percentage (0-100)
Config.ThirstRefill = 10

-- esx_status uses 0-1000000; this is the max thirst value
Config.ThirstMax = 1000000

-- Max drinks allowed per player within the cooldown window
Config.MaxDrinksPerHour = 2

-- Cooldown window in seconds (1 hour)
Config.CooldownWindow = 60 * 60

-- Animation dictionary + animation name
Config.AnimDict = 'mp_player_intdrink'
Config.AnimName = 'loop_bottle'

-- How long the NUI cup-fill animation runs (ms) — 5 to 10 seconds
Config.FillDuration = 7000

-- Brief pause after fill before sip sound (ms)
Config.SipDelay = 400

-- Total drink animation length (should cover fill + sip)
Config.AnimDuration = Config.FillDuration + 2500

-- Cup prop model and hand attachment offsets
Config.CupModel = `prop_cs_paper_cup`
Config.CupBone = 57005 -- right hand
Config.CupOffset = { x = 0.13, y = 0.02, z = -0.02 }
Config.CupRotation = { x = 240.0, y = 0.0, z = 0.0 }

-- Two-stage sounds: pour when filling, sip when drinking
Config.PourSound = {
    name = 'Pour',
    bank = 'DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS',
}

Config.SipSound = {
    name = 'Drink',
    bank = 'DLC_Dmod_Prop_Editor_Sounds',
}

-- Random player remarks after drinking
Config.Remarks = {
    'Ah, that hits the spot. I really needed that.',
    'Cold water on a hot day — nothing better.',
    'My throat was so dry... feeling human again.',
    'Public water never tasted so good.',
    'Emergency hydration complete. I\'m good for now.',
}

-- Keywords used when scanning loaded world objects by archetype name
Config.ScanKeywords = {
    'watercooler',
    'dispenser',
    'hydrant',
}

-- Known Rockstar dispenser models (registered immediately, no scan needed)
Config.KnownModels = {
    `prop_watercooler`,
    `prop_watercooler_dark`,
}

-- How often to rescan the world for new dispenser props (ms)
Config.RescanInterval = 30000

-- Delay before the first world scan after resource start (ms)
Config.InitialScanDelay = 5000
