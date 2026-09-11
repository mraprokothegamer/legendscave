local activeIllnesses = {}
local exposureCooldowns = {}
local patientHistories = {}
local scanCounter = 0

local function notify(source, message, notifyType)
    TriggerClientEvent('ox_lib:notify', source, {
        description = message,
        type = notifyType or 'inform'
    })
end

local function isAmbulance(source)
    return exports.qbx_core:HasPrimaryGroup(source, Config.AmbulanceJob)
end

local function getPatientName(source)
    local player = exports.qbx_core:GetPlayer(source)
    if player and player.PlayerData and player.PlayerData.charinfo then
        local charinfo = player.PlayerData.charinfo
        return ('%s %s'):format(charinfo.firstname or 'Unknown', charinfo.lastname or '')
    end

    return GetPlayerName(source) or 'Unknown Patient'
end

local function getPlayerDetails(source)
    local player = exports.qbx_core:GetPlayer(source)
    local charinfo = player and player.PlayerData and player.PlayerData.charinfo or {}

    return {
        id = source,
        citizenid = player and player.PlayerData and player.PlayerData.citizenid or ('server-%s'):format(source),
        name = getPatientName(source),
        birthdate = charinfo.birthdate or 'Unknown',
        gender = charinfo.gender or charinfo.sex or 'Unknown',
        phone = charinfo.phone or 'Unknown'
    }
end

local function rollInt(range)
    return math.random(range.min, range.max)
end

local function rollDecimal(range)
    local minValue = math.floor(range.min * 10)
    local maxValue = math.floor(range.max * 10)
    return math.random(minValue, maxValue) / 10
end

local function buildVitals(condition)
    return {
        temperature = rollDecimal(condition.vitals.temperature),
        heartRate = rollInt(condition.vitals.heartRate),
        oxygen = rollInt(condition.vitals.oxygen),
        bloodPressure = rollInt(condition.vitals.bloodPressure)
    }
end

local function getConditionForWeather(weatherName)
    local category = Config.WeatherSources[weatherName] or 'normal'
    local conditions = Config.Conditions[category] or Config.Conditions.normal

    if not conditions or #conditions == 0 then
        return nil, category
    end

    return conditions[math.random(#conditions)], category
end

local function isSevere(condition)
    return condition.severity == 'severe'
end

local function createIllnessState(condition, category, weatherName)
    return {
        name = condition.name,
        category = category,
        weather = weatherName,
        condition = condition,
        vitals = buildVitals(condition),
        severe = isSevere(condition),
        checkupComplete = not isSevere(condition),
        startedAt = os.time()
    }
end

local function setPatientIllness(patient, illness)
    activeIllnesses[patient] = illness
    TriggerClientEvent('legends-cave-medical:client:setSickness', patient, {
        name = illness.name,
        severe = illness.severe,
        symptom = illness.condition.symptom or Config.SymptomAnimation.defaultType
    })
end

local function clearPatientIllness(patient)
    activeIllnesses[patient] = nil
    TriggerClientEvent('legends-cave-medical:client:setSickness', patient, nil)
end

local function treatmentMatches(treatment, illnessName)
    for _, treatedIllness in ipairs(treatment.treats) do
        if treatedIllness == illnessName then
            return true
        end
    end

    return false
end

local function getRecommendedPrescription(illnessName)
    for itemName, treatment in pairs(Config.TreatmentItems) do
        if treatmentMatches(treatment, illnessName) then
            return {
                item = itemName,
                label = treatment.label
            }
        end
    end

    return {
        item = 'none',
        label = 'No matching prescription'
    }
end

local function getHistory(patient)
    patientHistories[patient] = patientHistories[patient] or {}
    return patientHistories[patient]
end

local function createScanRecord(patient, doctor, illness)
    scanCounter = scanCounter + 1

    local record = {
        id = scanCounter,
        timestamp = os.date('%Y-%m-%d %H:%M:%S'),
        doctor = getPatientName(doctor),
        illness = illness.name,
        severity = illness.severe and 'Severe' or 'Normal',
        weather = illness.weather,
        category = illness.category,
        prescription = getRecommendedPrescription(illness.name),
        note = '',
        status = illness.checkupComplete and 'Cleared for medication' or 'Awaiting check-up'
    }

    local history = getHistory(patient)
    table.insert(history, 1, record)

    if #history > 10 then
        table.remove(history)
    end

    return record, history
end

RegisterNetEvent('legends-cave-medical:server:weatherExposure', function(weatherName)
    local source = source
    if activeIllnesses[source] then
        return
    end

    local condition, category = getConditionForWeather(tostring(weatherName or 'UNKNOWN'))
    if not condition then
        return
    end

    local now = os.time()
    if exposureCooldowns[source] and exposureCooldowns[source] > now then
        return
    end

    exposureCooldowns[source] = now + Config.AutoSickness.cooldown

    local chance = Config.AutoSickness.chances[category] or 0
    if math.random(100) > chance then
        return
    end

    setPatientIllness(source, createIllnessState(condition, category, tostring(weatherName or 'UNKNOWN')))
end)

RegisterNetEvent('legends-cave-medical:server:scanPatient', function(patientServerId, weatherName)
    local source = source

    if not isAmbulance(source) then
        notify(source, Config.Messages.notAllowed, 'error')
        return
    end

    local patient = tonumber(patientServerId)
    if not patient or not GetPlayerName(patient) then
        notify(source, Config.Messages.invalidPatient, 'error')
        return
    end

    local sourcePed = GetPlayerPed(source)
    local patientPed = GetPlayerPed(patient)
    if sourcePed == 0 or patientPed == 0 then
        notify(source, Config.Messages.invalidPatient, 'error')
        return
    end

    local sourceCoords = GetEntityCoords(sourcePed)
    local patientCoords = GetEntityCoords(patientPed)
    if #(sourceCoords - patientCoords) > (Config.ScanDistance + 1.0) then
        notify(source, Config.Messages.tooFar, 'error')
        return
    end

    local illness = activeIllnesses[patient]
    local category = nil

    if not illness then
        local condition
        condition, category = getConditionForWeather(tostring(weatherName or 'UNKNOWN'))
        if not condition then
            notify(source, Config.Messages.noCondition, 'error')
            return
        end

        illness = createIllnessState(condition, category, tostring(weatherName or 'UNKNOWN'))
        setPatientIllness(patient, illness)
    end

    if illness.severe then
        illness.checkupComplete = true
    end

    local scanRecord, history = createScanRecord(patient, source, illness)

    TriggerClientEvent('legends-cave-medical:client:showScanResult', source, {
        patientId = patient,
        recordId = scanRecord.id,
        patient = getPlayerDetails(patient),
        patientName = getPatientName(patient),
        doctorName = getPatientName(source),
        scannedAt = scanRecord.timestamp,
        weather = illness.weather,
        category = illness.category,
        illness = illness.name,
        description = illness.condition.description,
        severity = illness.severe and 'Severe' or 'Normal',
        checkupComplete = illness.checkupComplete,
        requiredChecks = illness.condition.requiredChecks or {},
        vitals = illness.vitals,
        prescription = scanRecord.prescription,
        doctorNote = scanRecord.note,
        history = history
    })

    if illness.severe then
        notify(patient, 'Doctor check-up completed. Correct medication can now work.', 'success')
    end
end)

lib.callback.register('legends-cave-medical:server:canUseTreatment', function(source, itemName)
    local treatment = Config.TreatmentItems[itemName]
    if not treatment then
        return false, 'Invalid medication.'
    end

    local illness = activeIllnesses[source]
    if not illness then
        return false, 'You are not currently sick.'
    end

    if not treatmentMatches(treatment, illness.name) then
        return false, ('%s does not treat %s.'):format(treatment.label, illness.name)
    end

    if illness.severe and not illness.checkupComplete then
        return false, Config.Messages.severeNeedsScan
    end

    return true
end)

lib.callback.register('legends-cave-medical:server:canUseTablet', function(source)
    if Config.Tablet.requireAmbulanceJob and not isAmbulance(source) then
        return false, Config.Tablet.notAllowedMessage
    end

    return true
end)

RegisterNetEvent('legends-cave-medical:server:saveScanNote', function(patientId, recordId, note, prescription)
    local source = source

    if Config.Tablet.requireAmbulanceJob and not isAmbulance(source) then
        notify(source, Config.Tablet.notAllowedMessage, 'error')
        return
    end

    local patient = tonumber(patientId)
    local record = tonumber(recordId)
    if not patient or not record then
        return
    end

    local history = getHistory(patient)
    for _, item in ipairs(history) do
        if item.id == record then
            item.note = tostring(note or ''):sub(1, 500)
            local currentPrescription = item.prescription or {}
            item.prescription = {
                item = tostring(prescription and prescription.item or currentPrescription.item),
                label = tostring(prescription and prescription.label or currentPrescription.label)
            }
            item.status = 'Prescription issued'
            notify(source, 'Doctor note and prescription saved.', 'success')
            return
        end
    end
end)

RegisterNetEvent('legends-cave-medical:server:useTreatment', function(itemName)
    local source = source
    local treatment = Config.TreatmentItems[itemName]
    if not treatment then
        return
    end

    local illness = activeIllnesses[source]
    if not illness then
        notify(source, 'You are not currently sick.', 'inform')
        return
    end

    if not treatmentMatches(treatment, illness.name) then
        notify(source, ('%s does not treat %s.'):format(treatment.label, illness.name), 'error')
        return
    end

    if illness.severe and not illness.checkupComplete then
        notify(source, Config.Messages.severeNeedsScan, 'error')
        return
    end

    local curedIllness = illness.name
    clearPatientIllness(source)
    notify(source, ('%s treated successfully.'):format(curedIllness), 'success')
end)

AddEventHandler('playerDropped', function()
    activeIllnesses[source] = nil
    exposureCooldowns[source] = nil
end)
