local isSick = false
local currentIllness = nil
local lastScanResult = nil
local lastKnownWeather = 'UNKNOWN'

local function notify(message, notifyType)
    lib.notify({
        description = message,
        type = notifyType or 'inform'
    })
end

local function getSoundVolume()
    local volume = Config.Sound and tonumber(Config.Sound.volume)
    if volume == nil then
        volume = 0.3
    end

    if volume < 0 then
        return 0.0
    end

    if volume > 1 then
        return 1.0
    end

    return volume
end

local function selfScanEnabled()
    local cfg = Config.SelfScan
    if cfg == nil then
        return true
    end

    return cfg.enabled ~= false
end

local function selfScanLabel()
    return (Config.SelfScan and Config.SelfScan.buttonLabel) or 'Scan Self'
end

local function hideScanUi()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'hideScan'
    })
end

local function attachSelfScanFlags(scan)
    scan = scan or {}
    scan.canSelfScan = selfScanEnabled()
    scan.selfScanLabel = selfScanLabel()
    return scan
end

local function openScanResult(scan)
    SetNuiFocus(true, true)
    scan = attachSelfScanFlags(scan)
    SendNUIMessage({
        action = 'showScanResult',
        patientId = scan.patientId,
        recordId = scan.recordId,
        patient = scan.patient,
        patientName = scan.patientName,
        doctorName = scan.doctorName,
        scannedAt = scan.scannedAt,
        weather = scan.weather,
        category = scan.category,
        illness = scan.illness,
        description = scan.description,
        severity = scan.severity,
        checkupComplete = scan.checkupComplete,
        requiredChecks = scan.requiredChecks,
        vitals = scan.vitals,
        prescription = scan.prescription,
        doctorNote = scan.doctorNote,
        history = scan.history,
        canSelfScan = scan.canSelfScan,
        selfScanLabel = scan.selfScanLabel,
        isSelfScan = scan.isSelfScan == true
    })
end

local function openTabletHome()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openTablet',
        canSelfScan = selfScanEnabled(),
        selfScanLabel = selfScanLabel(),
        weather = lastKnownWeather,
        illness = currentIllness and currentIllness.name or nil
    })
end

local function symptomSoundEnabled(sound)
    return type(sound) == 'table' and sound.enabled ~= false
end

local function playSymptomWorldSound(playerId, symptomType)
    local animation = Config.SymptomAnimation.types and Config.SymptomAnimation.types[symptomType]
    local sound = animation and animation.sound
    if not symptomSoundEnabled(sound) then
        return
    end

    local targetPlayer = GetPlayerFromServerId(playerId)
    if targetPlayer == -1 then
        return
    end

    local ped = GetPlayerPed(targetPlayer)
    if ped == 0 or not DoesEntityExist(ped) then
        return
    end

    local coords = GetEntityCoords(ped)
    local range = tonumber(Config.SymptomAnimation.soundDistance) or 25.0
    local dist = #(GetEntityCoords(PlayerPedId()) - coords)
    if dist > range then
        return
    end

    local master = getSoundVolume()
    if master <= 0 then
        return
    end

    local volume = master
    if dist > 1.0 then
        volume = math.max(0.04, master * (1.0 - (dist / range)))
    end

    if type(sound.file) == 'string' and sound.file ~= '' then
        SendNUIMessage({
            action = 'playSymptomSound',
            symptom = symptomType,
            file = sound.file,
            volume = volume
        })
        return
    end

    if type(sound.speech) == 'string' and sound.speech ~= '' then
        PlayAmbientSpeechFromPositionNative(
            sound.speech,
            sound.voice or 'A_M_M_MALIBU_01_WHITE_FULL_01',
            coords.x,
            coords.y,
            coords.z,
            sound.speechParam or 'SPEECH_PARAMS_STANDARD'
        )
    end
end

local function playConfigSound(sound)
    if type(sound) ~= 'table' or sound.enabled == false then
        return
    end

    local volume = getSoundVolume()
    if volume <= 0 then
        return
    end

    local name = sound.name
    local set = sound.set
    if type(name) ~= 'string' or name == '' or type(set) ~= 'string' or set == '' then
        return
    end

    local soundId = GetSoundId()
    PlaySoundFrontend(soundId, name, set, true)
    SetVariableOnSound(soundId, 'Volume', volume)
    ReleaseSoundId(soundId)
end

local function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(25)
    end
end

local function getWeatherName()
    local weatherTypes = {
        'EXTRASUNNY',
        'CLEAR',
        'NEUTRAL',
        'SMOG',
        'FOGGY',
        'OVERCAST',
        'CLOUDS',
        'CLEARING',
        'RAIN',
        'THUNDER',
        'SNOW',
        'BLIZZARD',
        'SNOWLIGHT',
        'XMAS',
        'HALLOWEEN'
    }

    local function fromHash(weatherHash)
        for _, weatherName in ipairs(weatherTypes) do
            if weatherHash == joaat(weatherName) then
                return weatherName
            end
        end
        return nil
    end

    return fromHash(GetPrevWeatherTypeHashName())
        or fromHash(GetNextWeatherTypeHashName())
        or 'UNKNOWN'
end

local function getWeatherCategory(weatherName)
    return (Config.WeatherSources and Config.WeatherSources[weatherName]) or 'normal'
end

local function playSymptomAnimation()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) or IsEntityDead(ped) then
        return
    end

    local symptomType = currentIllness and currentIllness.symptom or Config.SymptomAnimation.defaultType
    local animation = Config.SymptomAnimation.types[symptomType] or Config.SymptomAnimation.types[Config.SymptomAnimation.defaultType]
    if not animation then
        return
    end

    loadAnimDict(animation.dict)
    TaskPlayAnim(
        ped,
        animation.dict,
        animation.clip,
        8.0,
        -8.0,
        animation.duration,
        animation.flag,
        0.0,
        false,
        false,
        false
    )

    if symptomSoundEnabled(animation.sound) then
        TriggerServerEvent('legends-cave-medical:server:symptomSound', symptomType)
    end
end

local function scanPatient(entity)
    if not entity or not DoesEntityExist(entity) then
        notify(Config.Messages.invalidPatient, 'error')
        return
    end

    local localServerId = GetPlayerServerId(PlayerId())
    local patientServerId

    if entity == PlayerPedId() then
        patientServerId = localServerId
    else
        if not IsPedAPlayer(entity) then
            notify(Config.Messages.invalidPatient, 'error')
            return
        end

        local targetPlayer = NetworkGetPlayerIndexFromPed(entity)
        if targetPlayer == -1 then
            notify(Config.Messages.invalidPatient, 'error')
            return
        end

        patientServerId = GetPlayerServerId(targetPlayer)
    end

    if not patientServerId or patientServerId == 0 then
        notify(Config.Messages.invalidPatient, 'error')
        return
    end

    local weatherName = getWeatherName()
    local isSelf = patientServerId == localServerId
    local scanLabel = Config.Messages.severeScanning
    if isSelf and Config.SelfScan and Config.SelfScan.scanningLabel then
        scanLabel = Config.SelfScan.scanningLabel
    end

    playConfigSound(Config.SevereScanAnimation.sound)

    local finished = lib.progressCircle({
        duration = Config.ScanDuration,
        label = scanLabel,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true
        },
        anim = {
            dict = Config.SevereScanAnimation.dict,
            clip = Config.SevereScanAnimation.clip
        }
    })

    if not finished then
        notify(Config.Messages.scanCancelled, 'error')
        return
    end

    TriggerServerEvent('legends-cave-medical:server:scanPatient', patientServerId, weatherName)
end

local function addTarget()
    exports.ox_target:addGlobalPlayer({
        {
            icon = 'fa-solid fa-stethoscope',
            label = 'Run Medical Check-up',
            groups = Config.AmbulanceJob,
            distance = Config.ScanDistance,
            onSelect = function(data)
                scanPatient(data.entity)
            end
        }
    })
end

local function showWeatherWarning(weatherName)
    local message = Config.WeatherWarning.messages[weatherName] or Config.WeatherWarning.messages.UNKNOWN

    -- Same id replaces any previous weather toast so it cannot stack or re-ring.
    lib.notify({
        id = 'legends-cave-medical-weather',
        title = Config.WeatherWarning.title,
        description = message,
        type = 'warning',
        duration = 8000
    })
    playConfigSound(Config.WeatherWarning.sound)

    if Config.WeatherWarning.showInChat then
        TriggerEvent('chat:addMessage', {
            color = { 245, 158, 11 },
            multiline = true,
            args = { Config.WeatherWarning.title, message }
        })
    end
end

RegisterNetEvent('legends-cave-medical:client:setSickness', function(illness)
    local wasSick = isSick
    local previousName = currentIllness and currentIllness.name
    isSick = illness ~= nil
    currentIllness = illness

    if isSick then
        local illnessName = illness.name or illness.symptom
        if not wasSick or illnessName ~= previousName then
            notify(Config.Messages.becameSick, 'warning')
            playSymptomAnimation()
        end
    elseif wasSick then
        notify(Config.Messages.recovered, 'success')
        ClearPedTasks(PlayerPedId())
    end
end)

RegisterNetEvent('legends-cave-medical:client:symptomSound', function(playerId, symptomType)
    playSymptomWorldSound(tonumber(playerId) or 0, tostring(symptomType or ''))
end)

RegisterNetEvent('legends-cave-medical:client:showScanResult', function(scan)
    lastScanResult = attachSelfScanFlags(scan)

    if Config.Tablet.autoOpenAfterScan then
        openScanResult(lastScanResult)
    else
        notify('Scan complete. Open your MediScan Tablet to view the results.', 'success')
    end
end)

RegisterNUICallback('selfScan', function(_, cb)
    cb({ ok = true })

    if not selfScanEnabled() then
        notify((Config.SelfScan and Config.SelfScan.disabledMessage) or 'Self-scan is disabled.', 'error')
        return
    end

    -- Server activeIllnesses is the diagnosis source of truth. Ask before
    -- closing the tablet or running the scan animation.
    local allowed, message = lib.callback.await('legends-cave-medical:server:canSelfScan', false)
    if not allowed then
        notify(message or (Config.SelfScan and Config.SelfScan.notIllMessage) or 'You have no weather-related sickness to scan.', 'error')
        return
    end

    hideScanUi()
    CreateThread(function()
        Wait(100)
        scanPatient(PlayerPedId())
    end)
end)

RegisterNUICallback('closeScan', function(_, cb)
    hideScanUi()
    cb({ ok = true })
end)

RegisterNUICallback('saveScanNote', function(data, cb)
    if lastScanResult then
        lastScanResult.doctorNote = data.note or ''
        lastScanResult.prescription = data.prescription or lastScanResult.prescription
    end

    TriggerServerEvent(
        'legends-cave-medical:server:saveScanNote',
        data.patientId,
        data.recordId,
        data.note,
        data.prescription
    )

    cb({ ok = true })
end)

function useTreatmentPill(data, slot)
    local itemName = data and data.name
    local treatment = itemName and Config.TreatmentItems[itemName]
    if not treatment then
        return
    end

    local allowed, message = lib.callback.await('legends-cave-medical:server:canUseTreatment', false, itemName)
    if not allowed then
        notify(message or Config.Messages.severeNeedsScan, 'error')
        return
    end

    playConfigSound(Config.PillAnimation.sound)

    local finished = lib.progressCircle({
        duration = Config.PillAnimation.duration,
        label = ('Taking %s...'):format(treatment.label),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true
        },
        anim = {
            dict = Config.PillAnimation.dict,
            clip = Config.PillAnimation.clip
        }
    })

    if not finished then
        notify('Treatment cancelled.', 'error')
        return
    end

    exports.ox_inventory:useItem(data, function(used)
        if used then
            TriggerServerEvent('legends-cave-medical:server:useTreatment', itemName)
        end
    end)
end

function useDoctorTablet(data, slot)
    if data and data.name ~= Config.Tablet.item then
        return
    end

    local allowed, message = lib.callback.await('legends-cave-medical:server:canUseTablet', false)
    if not allowed then
        notify(message or Config.Tablet.notAllowedMessage, 'error')
        return
    end

    if lastScanResult then
        openScanResult(lastScanResult)
        return
    end

    if selfScanEnabled() then
        openTabletHome()
        return
    end

    notify(Config.Tablet.noScanMessage, 'error')
end

exports('useTreatmentPill', useTreatmentPill)
exports('useDoctorTablet', useDoctorTablet)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    exports('useTreatmentPill', useTreatmentPill)
    exports('useDoctorTablet', useDoctorTablet)
    hideScanUi()
    CreateThread(function()
        Wait(100)
        hideScanUi()
    end)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    SetNuiFocus(false, false)
end)

CreateThread(function()
    Wait(1000)
    addTarget()
end)

CreateThread(function()
    if not Config.WeatherWarning.enabled then
        return
    end

    -- Alert once on first check, then only when the weather *category* changes
    -- (respiratory / toxic / heat / normal). RAIN<->THUNDER in the same storm
    -- must not re-pop the toast or replay the notify sound.
    local lastAnnouncedCategory = nil
    local stableCategory = nil
    local stableHits = 0

    while true do
        Wait(Config.WeatherWarning.checkInterval)

        local currentWeather = getWeatherName()
        lastKnownWeather = currentWeather
        local category = getWeatherCategory(currentWeather)

        if category == stableCategory then
            stableHits = stableHits + 1
        else
            stableCategory = category
            stableHits = 1
        end

        local isFirst = lastAnnouncedCategory == nil and Config.WeatherWarning.alertOnFirstCheck ~= false
        local categoryChanged = lastAnnouncedCategory ~= nil and category ~= lastAnnouncedCategory and stableHits >= 2

        if isFirst or categoryChanged then
            lastAnnouncedCategory = category
            showWeatherWarning(currentWeather)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(Config.SymptomAnimation.repeatInterval)

        if isSick and currentIllness then
            playSymptomAnimation()
        end
    end
end)

CreateThread(function()
    if not Config.HealthDrain.enabled then
        return
    end

    while true do
        Wait(Config.HealthDrain.interval)

        if isSick and currentIllness then
            local ped = PlayerPedId()
            if not IsEntityDead(ped) then
                local health = GetEntityHealth(ped)
                local nextHealth = math.max(Config.HealthDrain.minimumHealth, health - Config.HealthDrain.amount)

                if nextHealth < health then
                    SetEntityHealth(ped, nextHealth)
                end
            end
        end
    end
end)

CreateThread(function()
    if not Config.AutoSickness.enabled then
        return
    end

    while true do
        Wait(Config.AutoSickness.checkInterval)
        TriggerServerEvent('legends-cave-medical:server:weatherExposure', getWeatherName())
    end
end)
