Config = {}

Config.TargetSystem = 'ox_target'
Config.AmbulanceJob = 'ambulance'
Config.ScanDistance = 2.5
Config.ScanDuration = 5000
Config.Debug = false

Config.AutoSickness = {
    enabled = true,
    checkInterval = 60000,
    cooldown = 900,
    chances = {
        respiratory = 35,
        toxic = 35,
        heat = 30,
        normal = 0
    }
}

Config.ScanAnimation = {
    dict = 'amb@medic@standing@tendtodead@idle_a',
    clip = 'idle_a'
}

-- Used by third-eye scan and tablet Scan Self (same progress circle).
-- sound.name / sound.set are PlaySoundFrontend natives; no extra audio files.
Config.SevereScanAnimation = {
    dict = 'amb@medic@standing@timeofdeath@base',
    clip = 'base',
    sound = {
        enabled = true,
        name = 'FocusIn',
        set = 'HintCamSounds'
    }
}

Config.SymptomAnimation = {
    repeatInterval = 30000,
    defaultType = 'cough',
    types = {
        cough = {
            duration = 2000,
            dict = 'timetable@gardener@smoking_joint',
            clip = 'idle_cough',
            flag = 48,
            sound = {
                enabled = true,
                name = 'CONFIRM_BEEP',
                set = 'HUD_MINI_GAME_SOUNDSET'
            }
        },
        sneeze = {
            duration = 2000,
            dict = 'amb@code_human_wander_idles_fat@female@idle_a',
            clip = 'idle_b_sneeze',
            flag = 48,
            sound = {
                enabled = true,
                name = 'NAV_UP_DOWN',
                set = 'HUD_FRONTEND_DEFAULT_SOUNDSET'
            }
        },
        vomit = {
            duration = 2000,
            dict = 'missheistpaletoscore1leadinout',
            clip = 'trv_puking_leadout',
            flag = 48,
            sound = {
                enabled = true,
                name = 'CANCEL',
                set = 'HUD_FRONTEND_DEFAULT_SOUNDSET'
            }
        }
    }
}

Config.HealthDrain = {
    enabled = true,
    interval = 60000,
    amount = 1,
    minimumHealth = 105
}

Config.PillAnimation = {
    duration = 3500,
    dict = 'mp_suicide',
    clip = 'pill',
    sound = {
        enabled = true,
        name = 'PICK_UP',
        set = 'HUD_FRONTEND_DEFAULT_SOUNDSET'
    }
}

Config.Tablet = {
    item = 'lc_mediscan_tablet',
    label = 'MediScan Tablet',
    autoOpenAfterScan = true,
    requireAmbulanceJob = true,
    noScanMessage = 'No scan result stored. Run a third-eye medical check-up or Scan Self from the tablet.',
    notAllowedMessage = 'Only medical staff can use the MediScan Tablet.'
}

-- Doctors can scan their own ped via the tablet "Scan Self" button.
-- Add this whole table if you keep an older config.lua on the live server.
-- enabled = false forbids self-scan; requireIllness = true only allows it when already sick.
Config.SelfScan = {
    enabled = true,
    requireIllness = true,
    buttonLabel = 'Scan Self',
    disabledMessage = 'Self-scan is disabled.',
    notIllMessage = 'You have no weather-related sickness to scan.',
    scanningLabel = 'Running self check-up...'
}

Config.WeatherWarning = {
    enabled = true,
    checkInterval = 15000,
    title = 'City Wide Weather Warning',
    showInChat = true,
    messages = {
        RAIN = 'Rainfall reported city wide. Respiratory cases may increase.',
        THUNDER = 'Thunderstorm warning city wide. Respiratory cases may increase.',
        CLEARING = 'Wet roads and damp air remain after rainfall.',
        XMAS = 'Cold front warning city wide. Cold exposure cases may increase.',
        SNOW = 'Snow warning city wide. Cold exposure cases may increase.',
        SNOWLIGHT = 'Light snow warning city wide. Cold exposure cases may increase.',
        BLIZZARD = 'Blizzard warning city wide. Cold exposure cases may increase.',
        FOGGY = 'Fog warning city wide. Toxic exposure cases may increase.',
        SMOG = 'Smog warning city wide. Toxic exposure cases may increase.',
        EXTRASUNNY = 'Extreme heat warning city wide. Heat exhaustion cases may increase.',
        CLEAR = 'High temperature warning city wide. Heat illness cases may increase.',
        NEUTRAL = 'Weather has stabilized city wide.',
        CLOUDS = 'Cloud cover reported city wide. Medical risk is normal.',
        OVERCAST = 'Overcast conditions reported city wide. Medical risk is normal.',
        UNKNOWN = 'Weather has changed city wide. Medical symptoms may vary.'
    }
}

Config.Messages = {
    invalidPatient = 'Invalid patient.',
    notAllowed = 'You are not allowed to scan patients.',
    tooFar = 'You are too far away from the patient.',
    noCondition = 'No weather-related sickness detected.',
    scanCancelled = 'Scan cancelled.',
    scanning = 'Inspecting patient...',
    severeScanning = 'Running blood clean, blood pressure, heart check, and full check-up...',
    becameSick = 'You are feeling sick. Visit a doctor or take the correct medication.',
    recovered = 'You are no longer feeling sick.',
    severeNeedsScan = 'This condition is severe. A doctor must scan you before medication will work.'
}

Config.TreatmentItems = {
    lc_aeroclear_capsules = {
        label = 'AeroClear Capsules',
        treats = { 'Stormlung Syndrome' }
    },
    lc_sunveil_tablets = {
        label = 'Sunveil Tablets',
        treats = { 'Sunflare Fever' }
    },
    lc_hemopurge_pills = {
        label = 'HemoPurge Pills',
        treats = { 'Smogblood Toxicosis' }
    }
}

Config.WeatherSources = {
    RAIN = 'respiratory',
    THUNDER = 'respiratory',
    CLEARING = 'respiratory',
    XMAS = 'respiratory',
    SNOW = 'respiratory',
    SNOWLIGHT = 'respiratory',
    BLIZZARD = 'respiratory',
    FOGGY = 'toxic',
    SMOG = 'toxic',
    EXTRASUNNY = 'heat',
    CLEAR = 'heat',
    NEUTRAL = 'normal',
    CLOUDS = 'normal',
    OVERCAST = 'normal'
}

Config.Conditions = {
    respiratory = {
        {
            name = 'Stormlung Syndrome',
            severity = 'normal',
            symptom = 'cough',
            description = 'A wet-weather respiratory sickness caused by storm exposure. Patient may cough, run a fever, and show reduced oxygen saturation.',
            vitals = {
                temperature = { min = 38.0, max = 39.2 },
                heartRate = { min = 95, max = 112 },
                oxygen = { min = 84, max = 91 },
                bloodPressure = { min = 108, max = 125 }
            }
        }
    },
    toxic = {
        {
            name = 'Smogblood Toxicosis',
            severity = 'severe',
            symptom = 'sneeze',
            requiredChecks = { 'Blood clean check', 'Oxygen saturation check', 'Heart check', 'Full medical check-up' },
            description = 'A severe blood-toxin sickness caused by smog or polluted air. Patient needs a doctor scan before HemoPurge medication can work.',
            vitals = {
                temperature = { min = 37.5, max = 39.0 },
                heartRate = { min = 104, max = 126 },
                oxygen = { min = 80, max = 89 },
                bloodPressure = { min = 105, max = 128 }
            }
        }
    },
    heat = {
        {
            name = 'Sunflare Fever',
            severity = 'severe',
            symptom = 'vomit',
            requiredChecks = { 'Blood pressure check', 'Heart check', 'Hydration check', 'Full medical check-up' },
            description = 'A severe heat-triggered fever. Patient may be dehydrated, dizzy, and unstable until a doctor completes the check-up.',
            vitals = {
                temperature = { min = 38.2, max = 40.1 },
                heartRate = { min = 112, max = 138 },
                oxygen = { min = 92, max = 97 },
                bloodPressure = { min = 88, max = 106 }
            }
        }
    },
    normal = {}
}
