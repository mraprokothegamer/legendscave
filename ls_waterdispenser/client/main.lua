--[[
    ls_waterdispenser — simple client
    Drink from existing water coolers: anim + cup + NUI + thirst
]]

print('^2[ls_waterdispenser] v2.4.0 loaded^0')

local registeredModels = {}
local isDrinking = false
local cupEntity = nil

local CUP_MODELS = {
    `prop_plastic_cup_02`,
    `ng_proc_sodacup_01a`,
    `ng_proc_sodacup_01b`,
    `apa_prop_cs_plastic_cup_01`,
}

local function debugPrint(msg)
    if Config.Debug then
        print(('[ls_waterdispenser] %s'):format(msg))
    end
end

local function hideNui()
    SendNUIMessage({ action = 'hideFill' })
    SendNUIMessage({ action = 'forceHide' })
end

local function showNui(duration)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'startFill',
        duration = duration or Config.FillDuration or 10000,
    })
end

local function cleanupCup()
    if cupEntity and DoesEntityExist(cupEntity) then
        DetachEntity(cupEntity, true, true)
        SetEntityAsMissionEntity(cupEntity, true, true)
        DeleteEntity(cupEntity)
    end
    cupEntity = nil
end

local function requestModel(model)
    if type(model) == 'string' then
        model = joaat(model)
    end
    if not model or model == 0 then
        return false
    end
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

local function attachCup()
    cleanupCup()

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local bone = Config.CupBone or 60309
    local ox = (Config.CupOffset and Config.CupOffset.x) or 0.15
    local oy = (Config.CupOffset and Config.CupOffset.y) or 0.02
    local oz = (Config.CupOffset and Config.CupOffset.z) or -0.03
    local rx = (Config.CupRotation and Config.CupRotation.x) or -80.0
    local ry = (Config.CupRotation and Config.CupRotation.y) or 0.0
    local rz = (Config.CupRotation and Config.CupRotation.z) or -20.0

    local models = { Config.CupModel, Config.CupModelFallback }
    for i = 1, #CUP_MODELS do
        models[#models + 1] = CUP_MODELS[i]
    end

    local bones = { bone, 60309, 18905 }

    for b = 1, #bones do
        for m = 1, #models do
            local model = models[m]
            if type(model) == 'string' then
                model = joaat(model)
            end
            if model and model ~= 0 and requestModel(model) then
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
                        cup, ped, GetPedBoneIndex(ped, bones[b]),
                        ox, oy, oz, rx, ry, rz,
                        true, true, false, true, 1, true
                    )

                    Wait(50)

                    if DoesEntityExist(cup) and IsEntityAttachedToEntity(cup, ped) then
                        cupEntity = cup
                        SetModelAsNoLongerNeeded(model)
                        debugPrint(('cup attached bone=%s'):format(bones[b]))
                        return cup
                    end

                    DeleteEntity(cup)
                end
                SetModelAsNoLongerNeeded(model)
            end
        end
    end

    return nil
end

local function playAnim(ped)
    local dict = Config.AnimDict or 'mp_player_intdrink'
    local name = Config.AnimName or 'loop_bottle'

    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() > timeout then
            return false
        end
        Wait(10)
    end

    TaskPlayAnim(ped, dict, name, 8.0, -8.0, -1, 49, 0.0, false, false, false)
    return true
end

local function cleanup(ped)
    hideNui()
    if ped and DoesEntityExist(ped) then
        ClearPedSecondaryTask(ped)
        StopAnimTask(ped, Config.AnimDict or 'mp_player_intdrink', Config.AnimName or 'loop_bottle', 1.0)
    end
    cleanupCup()
    isDrinking = false
end

local function drink()
    if isDrinking then
        return
    end

    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
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
        local duration = Config.FillDuration or 10000

        local ok, err = pcall(function()
            playAnim(ped)
            Wait(200)

            local cup = attachCup()
            if not cup then
                Wait(100)
                cup = attachCup()
            end

            showNui(duration)

            if cup and DoesEntityExist(cup) then
                PlaySoundFromEntity(-1, Config.PourSound.name, cup, Config.PourSound.bank, false, 0)
            else
                PlaySoundFromEntity(-1, Config.PourSound.name, ped, Config.PourSound.bank, false, 0)
            end

            local started = GetGameTimer()
            while GetGameTimer() - started < duration do
                if IsEntityDead(ped) then
                    error('dead')
                end

                if not cupEntity or not DoesEntityExist(cupEntity) then
                    attachCup()
                end

                if not IsEntityPlayingAnim(ped, Config.AnimDict, Config.AnimName, 3) then
                    playAnim(ped)
                end

                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 44, true)
                Wait(0)
            end

            hideNui()
            Wait(Config.SipDelay or 500)
            PlaySoundFromEntity(-1, Config.SipSound.name, ped, Config.SipSound.bank, false, 0)

            remark = lib.callback.await('waterdispenser:drinkWater', false)
            Wait(800)
        end)

        if not ok then
            debugPrint(('drink error: %s'):format(tostring(err)))
            pcall(function()
                lib.callback.await('waterdispenser:cancelDrink', false)
            end)
        end

        cleanup(ped)

        if ok and remark then
            lib.notify({ type = 'inform', description = remark, duration = 5000 })
        elseif ok then
            lib.notify({
                type = 'success',
                description = ('You feel refreshed (+%s%% thirst).'):format(Config.ThirstRefill or 30),
            })
        end
    end)
end

local function registerModel(model)
    if registeredModels[model] then
        return
    end
    registeredModels[model] = true

    exports.ox_target:addModel(model, {
        {
            name = 'waterdispenser_drink_water',
            label = 'Drink Water',
            icon = 'fa-solid fa-glass-water',
            distance = Config.TargetDistance or 2.0,
            onSelect = drink,
        },
    })
end

CreateThread(function()
    while GetResourceState('ox_target') ~= 'started' do
        Wait(500)
    end

    for i = 1, #(Config.KnownModels or {}) do
        registerModel(Config.KnownModels[i])
    end
end)

RegisterCommand('testwater', function()
    drink()
end, false)

AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() then
        cleanup(PlayerPedId())
    end
end)
