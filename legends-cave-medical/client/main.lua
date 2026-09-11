local isSick = false
local currentIllness = nil
local lastScanResult = nil

local function notify(message, notifyType)
    lib.notify({
        description = message,
        type = notifyType or 'inform'
    })
end

local function hideScanUi()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'hideScan'
    })
end

local function openScanResult(scan)
    SetNuiFocus(true, true)
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
        history = scan.history
    })
end

local function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(25)
    end
end

local function getWeatherName()
    local weatherHash = GetPrevWeatherTypeHashName()
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
        'XMAS'
    }

    for _, weatherName in ipairs(weatherTypes) do
        if weatherHash == joaat(weatherName) then
            return weatherName
        end
    end

    return 'UNKNOWN'
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
end

local function scanPatient(entity)
    if not entity or not DoesEntityExist(entity) or not IsPedAPlayer(entity) then
        notify(Config.Messages.invalidPatient, 'error')
        return
    end

    local targetPlayer = NetworkGetPlayerIndexFromPed(entity)
    if targetPlayer == -1 then
        notify(Config.Messages.invalidPatient, 'error')
        return
    end

    local patientServerId = GetPlayerServerId(targetPlayer)
    local weatherName = getWeatherName()

    local finished = lib.progressCircle({
        duration = Config.ScanDuration,
        label = Config.Messages.severeScanning,
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

    lib.notify({
        title = Config.WeatherWarning.title,
        description = message,
        type = 'warning',
        duration = 8000
    })

    if Config.WeatherWarning.showInChat then
        TriggerEvent('chat:addMessage', {
            color = { 245, 158, 11 },
            multiline = true,
            args = { Config.WeatherWarning.title, message }
        })
    end
end

RegisterNetEvent('legends-cave-medical:client:setSickness', function(illness)
    isSick = illness ~= nil
    currentIllness = illness

    if isSick then
        notify(Config.Messages.becameSick, 'warning')
        playSymptomAnimation()
    else
        notify(Config.Messages.recovered, 'success')
        ClearPedTasks(PlayerPedId())
    end
end)

RegisterNetEvent('legends-cave-medical:client:showScanResult', function(scan)
    lastScanResult = scan

    if Config.Tablet.autoOpenAfterScan then
        openScanResult(scan)
    else
        notify('Scan complete. Open your MediScan Tablet to view the results.', 'success')
    end
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

exports('useTreatmentPill', function(data, slot)
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
end)

exports('useDoctorTablet', function(data, slot)
    if data and data.name ~= Config.Tablet.item then
        return
    end

    local allowed, message = lib.callback.await('legends-cave-medical:server:canUseTablet', false)
    if not allowed then
        notify(message or Config.Tablet.notAllowedMessage, 'error')
        return
    end

    if not lastScanResult then
        notify(Config.Tablet.noScanMessage, 'error')
        return
    end

    openScanResult(lastScanResult)
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

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

    local lastWeather = getWeatherName()

    while true do
        Wait(Config.WeatherWarning.checkInterval)

        local currentWeather = getWeatherName()
        if currentWeather ~= lastWeather then
            lastWeather = currentWeather
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
