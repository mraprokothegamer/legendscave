--[[
    ls_waterdispenser — client
    Uses EXISTING Rockstar water cooler props via ox_target (no cooler spawning).
    Cup attaches to RIGHT hand (bone 57005).
]]

local registeredModels = {}
local isDrinking = false
local cupEntity = nil

-- Valid Rockstar cup props (prop_cs_paper_cup is INVALID on many builds)
local CUP_MODELS = {
    `prop_plastic_cup_02`,
    `p_amb_coffeecup_01`,
    `prop_mug_02`,
    `v_ret_fh_mug1`,
}

local function debugPrint(msg)
    if Config.Debug then
        print(('[ls_waterdispenser] %s'):format(msg))
    end
end

--- Attach cup to RIGHT hand. Never calls requestModel on an invalid hash.
local function attachCup()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    local candidates = {}
    local function addModel(model)
        if type(model) == 'string' then
            model = joaat(model)
        end
        if type(model) == 'number' and model ~= 0 and IsModelInCdimage(model) and IsModelValid(model) then
            candidates[#candidates + 1] = model
        end
    end

    addModel(Config.CupModel)
    addModel(Config.CupModelFallback)
    for i = 1, #CUP_MODELS do
        addModel(CUP_MODELS[i])
    end

    for i = 1, #candidates do
        local model = candidates[i]
        local loaded = false

        -- Manual load — avoid ox_lib requestModel throw on bad hashes
        RequestModel(model)
        local timeout = GetGameTimer() + 5000
        while not HasModelLoaded(model) do
            if GetGameTimer() > timeout then
                break
            end
            Wait(10)
        end
        loaded = HasModelLoaded(model)

        if loaded then
            local cup = CreateObject(model, coords.x, coords.y, coords.z + 0.2, true, true, false)

            if cup and cup ~= 0 and DoesEntityExist(cup) then
                AttachEntityToEntity(
                    cup,
                    ped,
                    GetPedBoneIndex(ped, Config.CupBone or 57005),
                    (Config.CupOffset and Config.CupOffset.x) or 0.12,
                    (Config.CupOffset and Config.CupOffset.y) or 0.02,
                    (Config.CupOffset and Config.CupOffset.z) or -0.02,
                    (Config.CupRotation and Config.CupRotation.x) or -80.0,
                    (Config.CupRotation and Config.CupRotation.y) or 0.0,
                    (Config.CupRotation and Config.CupRotation.z) or 10.0,
                    true,
                    true,
                    false,
                    true,
                    1,
                    true
                )
                SetModelAsNoLongerNeeded(model)
                debugPrint(('Cup on RIGHT hand, model=%s'):format(model))
                return cup
            end

            if cup and DoesEntityExist(cup) then
                DeleteObject(cup)
            end
            SetModelAsNoLongerNeeded(model)
        end
    end

    debugPrint('No valid cup model could be loaded')
    return nil
end

local function cleanupCup()
    if cupEntity and DoesEntityExist(cupEntity) then
        DetachEntity(cupEntity, true, true)
        DeleteObject(cupEntity)
    end
    cupEntity = nil
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
        if GetGameTimer() > timeout then
            return false
        end
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

local function cancelDrink()
    hideFillNui()
    ClearPedSecondaryTask(PlayerPedId())
    cleanupCup()
    lib.callback.await('waterdispenser:cancelDrink', false)
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
        playDrinkAnim(ped)
        showFillNui(Config.FillDuration or 7000)
        Wait(350)

        local cup = attachCup()
        cupEntity = cup

        if cup and DoesEntityExist(cup) then
            PlaySoundFromEntity(-1, Config.PourSound.name, cup, Config.PourSound.bank, false, 0)
        else
            PlaySoundFromEntity(-1, Config.PourSound.name, ped, Config.PourSound.bank, false, 0)
        end

        local fillStarted = GetGameTimer()
        local fillDuration = Config.FillDuration or 7000

        while GetGameTimer() - fillStarted < fillDuration do
            if IsEntityDead(ped) then
                cancelDrink()
                return
            end
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 44, true)
            Wait(0)
        end

        hideFillNui()
        Wait(Config.SipDelay or 400)
        PlaySoundFromEntity(-1, Config.SipSound.name, ped, Config.SipSound.bank, false, 0)

        local remark = lib.callback.await('waterdispenser:drinkWater', false)

        local remaining = (Config.AnimDuration or (fillDuration + 2500)) - fillDuration - (Config.SipDelay or 400)
        if remaining > 0 then
            Wait(remaining)
        end

        ClearPedSecondaryTask(ped)
        cleanupCup()
        isDrinking = false

        if remark then
            lib.notify({ type = 'inform', description = remark, duration = 5000 })
        end
    end)
end

-- ─── Existing Rockstar water cooler props (no spawning) ─────────────

local function registerDispenser(model)
    if registeredModels[model] then
        return
    end
    registeredModels[model] = true

    exports.ox_target:addModel(model, {
        {
            name = 'waterdispenser_drink_water',
            label = getDrinkLabel(),
            icon = 'fa-solid fa-glass-water',
            distance = Config.TargetDistance or 2.0,
            onSelect = function()
                drink()
            end,
        },
    })

    debugPrint(('Registered existing cooler model: %s'):format(model))
end

local function modelMatchesKeyword(modelName)
    if not modelName or modelName == '' then
        return false
    end
    local lower = string.lower(modelName)
    for i = 1, #(Config.ScanKeywords or {}) do
        if string.find(lower, Config.ScanKeywords[i], 1, true) then
            return true
        end
    end
    return false
end

CreateThread(function()
    while GetResourceState('ox_target') ~= 'started' do
        Wait(500)
    end

    -- Register known Rockstar cooler models that already exist in the map
    for i = 1, #(Config.KnownModels or {}) do
        registerDispenser(Config.KnownModels[i])
    end

    Wait(Config.InitialScanDelay or 5000)

    -- Scan for any other cooler variants already in the world
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

    debugPrint('Water cooler registration complete (existing map props only).')
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
        drink()
    end, false)
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end
    hideFillNui()
    cleanupCup()
    isDrinking = false
end)
