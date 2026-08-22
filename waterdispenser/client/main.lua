local registeredModels = {}
local isDrinking = false

local function debugPrint(message)
    if Config.Debug then
        print(('[waterdispenser] %s'):format(message))
    end
end

local function showFillNui(duration)
    SetNuiFocus(false, false)

    SendNUIMessage({
        action = 'startFill',
        duration = duration,
        position = Config.NuiPosition or 'bottom-right',
        paddingRight = Config.NuiPaddingRight or 4,
    })

    debugPrint('NUI fill started')
end

local function hideFillNui()
    SendNUIMessage({
        action = 'hideFill',
    })
end

local function loadAnimDict(dict)
    if not dict then
        return false
    end

    lib.requestAnimDict(dict, 5000)
    return HasAnimDictLoaded(dict)
end

local function playDrinkAnim(ped)
    if not loadAnimDict(Config.AnimDict) then
        return false
    end

    TaskPlayAnim(
        ped,
        Config.AnimDict,
        Config.AnimName,
        8.0,
        -8.0,
        Config.AnimDuration,
        49,
        0.0,
        false,
        false,
        false
    )

    return true
end

local function cancelDrinkSequence()
    hideFillNui()
    ClearPedSecondaryTask(PlayerPedId())
    Prop.cleanup()
    lib.callback.await('waterdispenser:cancelDrink', false)
    isDrinking = false
end

local function playDrinkSequence()
    if isDrinking then
        return
    end

    local playerPed = PlayerPedId()

    if IsPedInAnyVehicle(playerPed, false) then
        lib.notify({ type = 'error', description = 'You cannot drink while in a vehicle.' })
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
        local completed = false

        local function finish()
            if completed then
                return
            end

            completed = true
            hideFillNui()
            ClearPedSecondaryTask(playerPed)
            Prop.cleanup()
            isDrinking = false
        end

        playDrinkAnim(playerPed)

        -- Show NUI immediately (do not wait for cup prop — prop failure was hiding UI)
        showFillNui(Config.FillDuration)

        Wait(350)

        if not Prop.spawnInHand(playerPed) then
            debugPrint('Cup prop failed — NUI still running')
        end

        local cup = Prop.getEntity()

        if cup and DoesEntityExist(cup) then
            PlaySoundFromEntity(-1, Config.PourSound.name, cup, Config.PourSound.bank, false, 0)
        else
            PlaySoundFromEntity(-1, Config.PourSound.name, playerPed, Config.PourSound.bank, false, 0)
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
end)

CreateThread(function()
    while true do
        Wait(Config.RescanInterval)
        scanWorldForDispensers()
    end
end)

if Config.Debug then
    RegisterCommand('testwater', function()
        playDrinkSequence()
    end, false)

    RegisterCommand('testnui', function()
        showFillNui(5000)
        SetTimeout(5000, function()
            hideFillNui()
        end)
    end, false)
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    hideFillNui()
    Prop.cleanup()
    isDrinking = false
end)
