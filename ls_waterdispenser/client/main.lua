--[[
    ls_waterdispenser client — self-contained (cup + drink + NUI)
    No separate Prop file required.
    VERSION: 2.3.2
]]

print('^2[ls_waterdispenser] client/main.lua v2.3.2 loaded (self-contained, no Prop module)^0')

local registeredModels = {}
local isDrinking = false
local cupEntity = nil

local CUP_MODELS = {
    `prop_plastic_cup_02`,
    `ng_proc_sodacup_01a`,
    `ng_proc_sodacup_01b`,
    `ng_proc_sodacup_01c`,
    `apa_prop_cs_plastic_cup_01`,
    `p_amb_coffeecup_01`,
}

local LEFT_BONES = {
    60309, -- PH_L_Hand
    18905, -- SKEL_L_Hand
}

local function debugPrint(message)
    if Config.Debug then
        print(('[ls_waterdispenser] %s'):format(message))
    end
end

local function toHash(model)
    if type(model) == 'string' then
        return joaat(model)
    end
    return model
end

local function requestModel(model)
    if HasModelLoaded(model) then
        return true
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

local function cleanupCup()
    if cupEntity and DoesEntityExist(cupEntity) then
        DetachEntity(cupEntity, true, true)
        SetEntityAsMissionEntity(cupEntity, true, true)
        DeleteEntity(cupEntity)
    end
    cupEntity = nil
end

--- Attach red/plastic cup to LEFT hand
local function attachCup()
    cleanupCup()

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    local models = {}
    local seen = {}
    local function push(m)
        local h = toHash(m)
        if h and h ~= 0 and not seen[h] then
            seen[h] = true
            models[#models + 1] = h
        end
    end

    push(Config.CupModel)
    push(Config.CupModelFallback)
    for i = 1, #CUP_MODELS do
        push(CUP_MODELS[i])
    end

    local bones = { Config.CupBone or 60309 }
    for i = 1, #LEFT_BONES do
        local already = false
        for j = 1, #bones do
            if bones[j] == LEFT_BONES[i] then already = true break end
        end
        if not already then bones[#bones + 1] = LEFT_BONES[i] end
    end

    local ox = (Config.CupOffset and Config.CupOffset.x) or 0.15
    local oy = (Config.CupOffset and Config.CupOffset.y) or 0.02
    local oz = (Config.CupOffset and Config.CupOffset.z) or -0.03
    local rx = (Config.CupRotation and Config.CupRotation.x) or -80.0
    local ry = (Config.CupRotation and Config.CupRotation.y) or 0.0
    local rz = (Config.CupRotation and Config.CupRotation.z) or -20.0

    for _, bone in ipairs(bones) do
        for _, model in ipairs(models) do
            if requestModel(model) then
                local cup = CreateObject(model, coords.x, coords.y, coords.z + 0.2, false, false, false)
                if not cup or cup == 0 or not DoesEntityExist(cup) then
                    cup = CreateObject(model, coords.x, coords.y, coords.z + 0.2, true, true, false)
                end

                if cup and cup ~= 0 and DoesEntityExist(cup) then
                    SetEntityAsMissionEntity(cup, true, true)
                    SetEntityCollision(cup, false, false)
                    SetEntityVisible(cup, true, false)
                    ResetEntityAlpha(cup)

                    AttachEntityToEntity(
                        cup,
                        ped,
                        GetPedBoneIndex(ped, bone),
                        ox, oy, oz,
                        rx, ry, rz,
                        true, true, false, true, 1, true
                    )

                    Wait(50)

                    if DoesEntityExist(cup) and IsEntityAttachedToEntity(cup, ped) then
                        cupEntity = cup
                        SetModelAsNoLongerNeeded(model)
                        debugPrint(('LEFT hand cup OK model=%s bone=%s'):format(model, bone))
                        return cup
                    end

                    DeleteEntity(cup)
                end

                SetModelAsNoLongerNeeded(model)
            end
        end
    end

    debugPrint('FAILED to attach cup to left hand')
    return nil
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

    cleanupCup()
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
            playDrinkAnim(playerPed)
            Wait(200)

            local cup = attachCup()
            if not cup then
                Wait(100)
                cup = attachCup()
            end

            if not cup then
                lib.notify({ type = 'error', description = 'Cup prop failed to load.' })
            end

            showFillNui(fillDuration)

            if cup and DoesEntityExist(cup) then
                PlaySoundFromEntity(-1, Config.PourSound.name, cup, Config.PourSound.bank, false, 0)
            else
                PlaySoundFromEntity(-1, Config.PourSound.name, playerPed, Config.PourSound.bank, false, 0)
            end

            local fillStarted = GetGameTimer()
            while GetGameTimer() - fillStarted < fillDuration do
                if IsEntityDead(playerPed) then
                    error('player_dead')
                end

                if not cupEntity or not DoesEntityExist(cupEntity) then
                    cup = attachCup()
                end

                if not IsEntityPlayingAnim(playerPed, Config.AnimDict, Config.AnimName, 3) then
                    playDrinkAnim(playerPed)
                end

                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 44, true)
                Wait(0)
            end

            -- Fill/drink done — hide NUI immediately
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
    local cup = attachCup()
    lib.notify({
        type = cup and 'success' or 'error',
        description = cup and 'Cup on LEFT hand for 8s' or 'Cup failed — check F8',
    })
    if cup then
        CreateThread(function()
            Wait(8000)
            cleanupCup()
        end)
    end
end, false)

RegisterCommand('testwater', function()
    playDrinkSequence()
end, false)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    hardCleanup(PlayerPedId())
end)
