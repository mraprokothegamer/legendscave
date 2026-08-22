local registeredModels = {}
local isDrinking = false
local cupEntity = nil

local function debugPrint(message)
    if Config.Debug then
        print(('[waterdispenser] %s'):format(message))
    end
end

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

local function cleanupCup()
    if cupEntity and DoesEntityExist(cupEntity) then
        DeleteObject(cupEntity)
    end

    cupEntity = nil
    SetModelAsNoLongerNeeded(Config.CupModel)
end

local function cancelDrinkSequence()
    hideFillNui()
    ClearPedSecondaryTask(PlayerPedId())
    cleanupCup()
    lib.callback.await('waterdispenser:cancelDrink', false)
    isDrinking = false
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

    CreateThread(function()
        local playerPed = PlayerPedId()
        local completed = false

        local function finish()
            if completed then
                return
            end

            completed = true
            hideFillNui()
            ClearPedSecondaryTask(playerPed)
            cleanupCup()
            isDrinking = false
        end

        if not loadModel(Config.CupModel) then
            lib.notify({
                type = 'error',
                description = 'Unable to load cup prop.',
            })
            lib.callback.await('waterdispenser:cancelDrink', false)
            isDrinking = false
            return
        end

        local coords = GetEntityCoords(playerPed)
        cupEntity = CreateObject(Config.CupModel, coords.x, coords.y, coords.z, true, true, false)

        if not cupEntity or not DoesEntityExist(cupEntity) then
            cleanupCup()
            lib.callback.await('waterdispenser:cancelDrink', false)
            isDrinking = false
            return
        end

        AttachEntityToEntity(
            cupEntity,
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
        PlaySoundFromEntity(-1, Config.PourSound.name, cupEntity, Config.PourSound.bank, false, 0)

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

        local fillStarted = GetGameTimer()
        while GetGameTimer() - fillStarted < Config.FillDuration do
            if IsEntityDead(playerPed) then
                cancelDrinkSequence()
                return
            end

            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 44, true)
            Wait(0)
        end

        hideFillNui()

        Wait(Config.SipDelay)
        PlaySoundFromEntity(-1, Config.SipSound.name, playerPed, Config.SipSound.bank, false, 0)

        local remark = lib.callback.await('waterdispenser:drinkWater', false)

        local remaining = Config.AnimDuration - Config.FillDuration - Config.SipDelay
        if remaining > 0 then
            Wait(remaining)
        end

        finish()

        if remark then
            lib.notify({
                type = 'inform',
                description = remark,
                duration = 5000,
            })
        end
    end)
end

local function registerDispenser(model)
    if registeredModels[model] then
        return
    end

    registeredModels[model] = true

    exports.ox_target:addModel(model, {
        {
            name = 'waterdispenser_drink_water',
            label = Config.TargetLabel or 'Drink Water',
            icon = 'fa-solid fa-glass-water',
            distance = Config.TargetDistance or 2.0,
            onSelect = function()
                playDrinkSequence()
            end,
        },
    })

    debugPrint(('Registered dispenser model: %s'):format(model))
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

local function waitForTarget()
    while GetResourceState('ox_target') ~= 'started' do
        Wait(500)
    end
end

CreateThread(function()
    waitForTarget()
    registerKnownModels()

    Wait(Config.InitialScanDelay)
    scanWorldForDispensers()

    debugPrint('Initial dispenser scan complete.')

    while true do
        Wait(Config.RescanInterval)
        scanWorldForDispensers()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    hideFillNui()
    cleanupCup()
    isDrinking = false
end)
