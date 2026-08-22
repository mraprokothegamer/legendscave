local registeredModels = {}
local isDrinking = false

local function showFillNui(duration)
    SendNUIMessage({
        action = 'startFill',
        duration = duration,
    })
end

local function hideFillNui()
    SendNUIMessage({
        action = 'hideFill',
    })
end

local function loadModel(model)
    if not IsModelValid(model) then
        return false
    end

    RequestModel(model)

    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) do
        if GetGameTimer() > timeout then
            return false
        end
        Wait(10)
    end

    return true
end

local function loadAnimDict(dict)
    RequestAnimDict(dict)

    local timeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() > timeout then
            return false
        end
        Wait(10)
    end

    return true
end

local function playDrinkSequence()
    if isDrinking then
        return
    end

    isDrinking = true

    local allowed, message = lib.callback.await('waterdispenser:canDrink', false)

    if not allowed then
        lib.notify({
            type = 'error',
            description = message or 'You need to wait before drinking again.',
        })
        isDrinking = false
        return
    end

    local playerPed = PlayerPedId()

    if not loadModel(Config.CupModel) then
        lib.notify({
            type = 'error',
            description = 'Unable to load cup prop.',
        })
        isDrinking = false
        return
    end

    local coords = GetEntityCoords(playerPed)
    local cup = CreateObject(Config.CupModel, coords.x, coords.y, coords.z, true, true, false)

    if not DoesEntityExist(cup) then
        SetModelAsNoLongerNeeded(Config.CupModel)
        isDrinking = false
        return
    end

    AttachEntityToEntity(
        cup,
        playerPed,
        GetPedBoneIndex(playerPed, Config.CupBone),
        Config.CupOffset.x,
        Config.CupOffset.y,
        Config.CupOffset.z,
        Config.CupRotation.x,
        Config.CupRotation.y,
        Config.CupRotation.z,
        true,
        true,
        false,
        true,
        1,
        true
    )

    showFillNui(Config.FillDuration)
    PlaySoundFromEntity(-1, Config.PourSound.name, cup, Config.PourSound.bank, false, 0)

    if loadAnimDict(Config.AnimDict) then
        TaskPlayAnim(
            playerPed,
            Config.AnimDict,
            Config.AnimName,
            3.0,
            -1,
            Config.AnimDuration,
            49,
            0.0,
            false,
            false,
            false
        )
    end

    Wait(Config.FillDuration)
    hideFillNui()

    Wait(Config.SipDelay)
    PlaySoundFromEntity(-1, Config.SipSound.name, playerPed, Config.SipSound.bank, false, 0)

    local remark = lib.callback.await('waterdispenser:drinkWater', false)

    local remaining = Config.AnimDuration - Config.FillDuration - Config.SipDelay
    if remaining > 0 then
        Wait(remaining)
    end

    ClearPedSecondaryTask(playerPed)

    if DoesEntityExist(cup) then
        DeleteObject(cup)
    end

    SetModelAsNoLongerNeeded(Config.CupModel)

    if remark then
        lib.notify({
            type = 'inform',
            description = remark,
            duration = 5000,
        })
    end

    isDrinking = false
end

local function registerDispenser(model)
    if registeredModels[model] then
        return
    end

    registeredModels[model] = true

    exports.ox_target:addModel(model, {
        {
            name = 'drink_water',
            label = 'Drink Water',
            icon = 'fa-solid fa-glass-water',
            distance = 2.0,
            onSelect = function()
                playDrinkSequence()
            end,
        },
    })
end

local function modelMatchesKeyword(modelName)
    if not modelName or modelName == '' then
        return false
    end

    local lowerName = string.lower(modelName)

    for i = 1, #Config.ScanKeywords do
        if string.find(lowerName, Config.ScanKeywords[i], 1, true) then
            return true
        end
    end

    return false
end

local function registerKnownModels()
    for i = 1, #Config.KnownModels do
        registerDispenser(Config.KnownModels[i])
    end
end

local function scanWorldForDispensers()
    local handle, entity = FindFirstObject()
    if handle == -1 then
        return
    end

    local success = true

    repeat
        if DoesEntityExist(entity) then
            local model = GetEntityModel(entity)
            local modelName = GetEntityArchetypeName(entity)

            if model and model ~= 0 and modelMatchesKeyword(modelName) then
                registerDispenser(model)
            end
        end

        success, entity = FindNextObject(handle)
    until not success

    EndFindObject(handle)
end

CreateThread(function()
    registerKnownModels()

    Wait(Config.InitialScanDelay)
    scanWorldForDispensers()

    while true do
        Wait(Config.RescanInterval)
        scanWorldForDispensers()
    end
end)
