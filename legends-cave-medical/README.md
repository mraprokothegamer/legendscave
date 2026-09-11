# legends-cave-medical

Simple Legends Cave EMS scanner for FiveM, built for Qbox and ox resources.

## What it does

- Adds a third-eye interaction on players.
- Restricts the interaction to `Config.AmbulanceJob`.
- Runs a doctor inspection animation/progress.
- Shows a NUI result with a weather-based sickness.
- Shows city-wide weather warnings when weather changes.
- Supports ox_inventory treatment pills with a patient pill-taking animation.
- Adds an EMS `MediScan Tablet` item that shows the latest completed third-eye scan result.
- Makes players sick from weather exposure based on configurable chances.
- Plays a 2-second symptom animation immediately, then repeats it every 30 seconds until cured.
- Uses coughing, sneezing, or vomiting animations based on the sickness type.
- Drains the patient's health while they are sick.
- Requires severe cases to be scanned by an ambulance doctor before medication works.
- Uses no props, no streamed models, no equipment tables, and no placed scanners.

## Requirements

- `qbx_core`
- `ox_lib`
- `ox_target`
- `ox_inventory`

## Install

1. Put `legends-cave-medical` in your server resources folder.
2. Set the ambulance job name in `config.lua`.
3. Copy the PNG files from `installation/images` into `ox_inventory/web/images`.
4. Add the items from `installation/ox_items.lua` to your ox_inventory item data.
5. Add this to `server.cfg`:

```cfg
ensure legends-cave-medical
```

## Configuration

Weather categories are controlled by `Config.WeatherSources`.

Illnesses shown by scan results are controlled by `Config.Conditions`.

Automatic sickness chances are controlled by `Config.AutoSickness`.

Symptom animation timing and health drain are controlled by `Config.SymptomAnimation` and `Config.HealthDrain`.

The three sickness and medication pairs are:

- `Stormlung Syndrome` -> `AeroClear Capsules`
- `Sunflare Fever` -> `Sunveil Tablets`
- `Smogblood Toxicosis` -> `HemoPurge Pills`

The doctor tablet item is:

- `lc_mediscan_tablet` -> `MediScan Tablet`

Severe conditions use:

```lua
severity = 'severe',
requiredChecks = { 'Blood clean check', 'Blood pressure check', 'Heart check', 'Full medical check-up' }
```

Normal conditions can be treated directly with the correct pills. Severe conditions block treatment until an ambulance doctor runs the medical check-up with third eye.

## ox_inventory items

Add the items from [installation/ox_items.lua](installation/ox_items.lua) to your ox_inventory item data. Copy the matching PNG files from `installation/images` into `ox_inventory/web/images`. Each pill calls the same client export; the resource decides what sickness it treats from `Config.TreatmentItems`. The tablet calls `legends-cave-medical.useDoctorTablet` and opens the latest completed scan result.

```lua
['lc_aeroclear_capsules'] = {
    label = 'AeroClear Capsules',
    weight = 100,
    stack = true,
    close = true,
    image = 'lc_aeroclear_capsules.png',
    client = {
        export = 'legends-cave-medical.useTreatmentPill'
    }
},

['lc_sunveil_tablets'] = {
    label = 'Sunveil Tablets',
    weight = 100,
    stack = true,
    close = true,
    image = 'lc_sunveil_tablets.png',
    client = {
        export = 'legends-cave-medical.useTreatmentPill'
    }
},

['lc_hemopurge_pills'] = {
    label = 'HemoPurge Pills',
    weight = 100,
    stack = true,
    close = true,
    image = 'lc_hemopurge_pills.png',
    client = {
        export = 'legends-cave-medical.useTreatmentPill'
    }
},

['lc_mediscan_tablet'] = {
    label = 'MediScan Tablet',
    weight = 750,
    stack = false,
    close = true,
    image = 'lc_mediscan_tablet.png',
    client = {
        export = 'legends-cave-medical.useDoctorTablet'
    }
},
```
