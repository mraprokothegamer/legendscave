local registeredModels = {}
local isDrinking = false

local function debugPrint(message)
    if Config.Debug then
        print(('[ls_waterdispenser] %s'):format(message))
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
end

local function hideFillNui()
    SendNUIMessage({ action = 'hideFill' })
end

local function playDrinkAnim(ped)
    local dict = Config.AnimDict or 'mp_player_intdrink'
    local name = Config.AnimName or 'loop_bottle'

    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() > timeout then return false end
        Wait(10)
    end

    TaskPlayAnim(ped, dict, name, 8.0, -8.0, Config.AnimDuration or 9500, 49, 0.0, false, false, false)
    return true
end

local function getDrinkLabel()
    if Config.FreeWater or (Config.WaterPrice or 0) <= 0 then
        return 'Drink Water'
    end
    return ('Drink Water ($%s)'):format(Config.WaterPrice)
end

local function cancelDrinkSequence()
    hideFillNui()
    ClearPedSecondaryTask(PlayerPedId())
    Prop.cleanup()
    lib.callback.await('waterdispenser:cancelDrink', false)
    isDrinking = false
end

local function playDrinkSequence()
    if isDrinking then return end

    local playerPed = PlayerPedId()

    if IsPedInAnyVehicle(playerPed, false) then
        lib.notify({ type = 'error', description = 'You cannot drink while in a vehicle.' })
        return
    end

    isDrinking = true

    local allowed, message = lib.callback.await('waterdispenser:canDrink', false)
    if not allowed then
        lib.notify({ type = 'error', description = message or 'Cannot drink right now.' })
        isDrinking = false
        return
    end

    CreateThread(function()
        playDrinkAnim(playerPed)
        showFillNui(Config.FillDuration or 7000)
        Wait(350)

        local cup = Prop.attachCup()
        if cup and DoesEntityExist(cup) then
            PlaySoundFromEntity(-1, Config.PourSound.name, cup, Config.PourSound.bank, false, 0)
        else
            PlaySoundFromEntity(-1, Config.PourSound.name, playerPed, Config.PourSound.bank, false, 0)
        end

        local fillStarted = GetGameTimer()
        local fillDuration = Config.FillDuration or 7000

        while GetGameTimer() - fillStarted < fillDuration do
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
        Wait(Config.SipDelay or 400)
        PlaySoundFromEntity(-1, Config.SipSound.name, playerPed, Config.SipSound.bank, false, 0)

        local remark = lib.callback.await('waterdispenser:drinkWater', false)

        local remaining = (Config.AnimDuration or (fillDuration + 2500)) - fillDuration - (Config.SipDelay or 400)
        if remaining > 0 then Wait(remaining) end

        ClearPedSecondaryTask(playerPed)
        Prop.cleanup()
        isDrinking = false

        if remark then
            lib.notify({ type = 'inform', description = remark, duration = 5000 })
        end
    end)
end

-- Existing Rockstar water coolers only (does not spawn coolers)
local function registerDispenser(model)
    if registeredModels[model] then return end
    registeredModels[model] = true

    exports.ox_target:addModel(model, {
        {
            name = 'waterdispenser_drink_water',
            label = getDrinkLabel(),
            icon = 'fa-solid fa-glass-water',
            distance = Config.TargetDistance or 2.0,
            onSelect = function()
                playDrinkSequence()
            end,
        },
    })
end

local function modelMatchesKeyword(modelName)
    if not modelName or modelName == '' then return false end
    local lower = string.lower(modelName)
    for i = 1, #(Config.ScanKeywords or {}) do
        if string.find(lower, Config.ScanKeywords[i], 1, true) then
            return true
        end
    end
    return false
end

CreateThread(function()
    while GetResourceState('ox_target') ~= 'started' do Wait(500) end

    for i = 1, #(Config.KnownModels or {}) do
        registerDispenser(Config.KnownModels[i])
    end

    Wait(Config.InitialScanDelay or 5000)

    local handle, entity = FindFirstObject()
    if handle ~= -1 then
        local success = true
        repeat
            if DoesEntityExist(entity) then
                local model = GetEntityModel(entity)
                local name = GetEntityArchetypeName(entity)
                if model and model ~= 0 and modelMatchesKeyword(name) then
                    registerDispenser(model)
                end
            end
            success, entity = FindNextObject(handle)
        until not success
        EndFindObject(handle)
    end
end)

CreateThread(function()
    while true do
        Wait(Config.RescanInterval or 30000)
        local handle, entity = FindFirstObject()
        if handle ~= -1 then
            local success = true
            repeat
                if DoesEntityExist(entity) then
                    local model = GetEntityModel(entity)
                    local name = GetEntityArchetypeName(entity)
                    if model and model ~= 0 and modelMatchesKeyword(name) then
                        registerDispenser(model)
                    end
                end
                success, entity = FindNextObject(handle)
            until not success
            EndFindObject(handle)
        end
    end
end)

if Config.Debug then
    RegisterCommand('testwater', function()
        playDrinkSequence()
    end, false)
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    hideFillNui()
    Prop.cleanup()
    isDrinking = false
end)
