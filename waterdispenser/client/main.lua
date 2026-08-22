--[[
    ls_waterdispenser client — drink flow + NUI
    VERSION: 2.3.4 — requires client/prop.lua (global Prop)
]]

print('^2[ls_waterdispenser] client/main.lua v2.3.4 loaded (expects Prop from prop.lua)^0')

if type(Prop) ~= 'table' or type(Prop.attachCup) ~= 'function' then
    print('^1[ls_waterdispenser] FATAL: client/prop.lua is missing or failed to load.^0')
    print('^1[ls_waterdispenser] DELETE the whole ls_waterdispenser folder and reinstall v2.3.4.^0')
end

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
        duration = duration or Config.FillDuration or 10000,
    })
end

local function hideFillNui()
    SendNUIMessage({ action = 'hideFill' })
    SendNUIMessage({ action = 'forceHide' })
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

    -- -1 duration = loop until we clear it
    TaskPlayAnim(ped, dict, name, 8.0, -8.0, -1, 49, 0.0, false, false, false)
    return true
end

local function hardCleanup(ped)
    hideFillNui()
    Wait(0)
    hideFillNui()

    if ped and DoesEntityExist(ped) then
        ClearPedSecondaryTask(ped)
        StopAnimTask(ped, Config.AnimDict or 'mp_player_intdrink', Config.AnimName or 'loop_bottle', 1.0)
    end

    Prop.cleanup()
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
        local remark = nil
        local fillDuration = Config.FillDuration or 10000

        local ok, err = pcall(function()
            -- 1) Start drinking animation
            playDrinkAnim(playerPed)
            Wait(200)

            -- 2) Put red cup in LEFT hand
            local cup = Prop.attachCup()
            if not cup then
                Wait(100)
                cup = Prop.attachCup()
            end

            if cup then
                debugPrint('Cup is in left hand')
            else
                debugPrint('WARNING: cup did not attach')
                lib.notify({ type = 'error', description = 'Cup prop failed to load.' })
            end

            -- 3) Show fill NUI (~10 seconds)
            showFillNui(fillDuration)

            if cup and DoesEntityExist(cup) then
                PlaySoundFromEntity(-1, Config.PourSound.name, cup, Config.PourSound.bank, false, 0)
            else
                PlaySoundFromEntity(-1, Config.PourSound.name, playerPed, Config.PourSound.bank, false, 0)
            end

            -- 4) Wait fill duration, keep anim + cup alive
            local fillStarted = GetGameTimer()
            while GetGameTimer() - fillStarted < fillDuration do
                if IsEntityDead(playerPed) then
                    error('player_dead')
                end

                local current = Prop.getEntity()
                if not current or not DoesEntityExist(current) then
                    Prop.attachCup()
                end

                if not IsEntityPlayingAnim(playerPed, Config.AnimDict, Config.AnimName, 3) then
                    playDrinkAnim(playerPed)
                end

                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 44, true)
                Wait(0)
            end

            -- 5) Hide NUI as soon as fill/drink time is done
            hideFillNui()
            Wait(50)
            hideFillNui()

            Wait(Config.SipDelay or 500)
            PlaySoundFromEntity(-1, Config.SipSound.name, playerPed, Config.SipSound.bank, false, 0)

            remark = lib.callback.await('waterdispenser:drinkWater', false)

            Wait(800)
        end)

        if not ok then
            debugPrint(('Drink error: %s'):format(tostring(err)))
            pcall(function()
                lib.callback.await('waterdispenser:cancelDrink', false)
            end)
        end

        -- 6) ALWAYS cleanup — NUI must disappear, cup removed, anim stopped
        hardCleanup(playerPed)

        if ok and remark then
            lib.notify({ type = 'inform', description = remark, duration = 5000 })
        elseif ok then
            lib.notify({
                type = 'success',
                description = ('You feel refreshed (+ %s%% thirst).'):format(Config.ThirstRefill or 30),
            })
        end
    end)
end

local function registerDispenser(model)
    if registeredModels[model] then return end
    registeredModels[model] = true

    exports.ox_target:addModel(model, {
        {
            name = 'waterdispenser_drink_water',
            label = 'Drink Water',
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

RegisterCommand('testcup', function()
    Config.Debug = true
    local cup = Prop.attachCup()
    print('[ls_waterdispenser] testcup:', cup)
    lib.notify({
        type = cup and 'success' or 'error',
        description = cup and 'Cup attached to LEFT hand for 8s' or 'Cup failed — check F8',
    })
    if cup then
        CreateThread(function()
            Wait(8000)
            Prop.cleanup()
        end)
    end
end, false)

RegisterCommand('testwater', function()
    Config.Debug = true
    playDrinkSequence()
end, false)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    hardCleanup(PlayerPedId())
end)
