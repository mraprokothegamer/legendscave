local isDrinking = false
local cupObject = nil

local function attachCup()
    if not Config.Cup.model then return end

    local model = GetHashKey(Config.Cup.model)
    lib.requestModel(model)

    local coords = GetEntityCoords(cache.ped)
    cupObject = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)

    local bone = GetPedBoneIndex(cache.ped, Config.Cup.bone)
    local o = Config.Cup.offset
    local r = Config.Cup.rotation
    AttachEntityToEntity(cupObject, cache.ped, bone, o.x, o.y, o.z, r.x, r.y, r.z, true, true, false, true, 1, true)

    SetModelAsNoLongerNeeded(model)
end

local function removeCup()
    if cupObject and DoesEntityExist(cupObject) then
        DeleteEntity(cupObject)
    end
    cupObject = nil
end

local function playAnim()
    lib.requestAnimDict(Config.Anim.dict)
    TaskPlayAnim(
        cache.ped, Config.Anim.dict, Config.Anim.clip,
        8.0, -8.0, Config.DrinkDuration, Config.Anim.flag,
        0.0, false, false, false
    )
end

local function stopAnim()
    ClearPedTasks(cache.ped)
    RemoveAnimDict(Config.Anim.dict)
end

local function drink()
    if isDrinking then return end
    isDrinking = true

    -- Ask the server to validate the rolling limit and apply thirst. All the
    -- authoritative work happens there; the rest is cosmetic feedback.
    local ok, message = lib.callback.await('ls_waterdispenser:server:tryUse', false)
    if not ok then
        lib.notify({ type = 'error', description = message or 'You cannot drink right now.' })
        isDrinking = false
        return
    end

    -- Hold the cup in the left hand for the whole interaction.
    attachCup()

    -- Phase 1: fill the cup. Middle-right NUI + progress bar, no drink anim yet.
    SendNUIMessage({
        action = 'startFill',
        duration = Config.FillDuration,
        sound = Config.Sound.enabled and Config.Sound.file or nil,
        volume = Config.Sound.volume,
    })

    Wait(Config.FillDuration)

    SendNUIMessage({ action = 'stopFill' })

    -- Phase 2: drink. NUI is hidden; play the drinking animation with the cup.
    playAnim()
    Wait(Config.DrinkDuration)
    stopAnim()

    removeCup()

    lib.notify({ type = 'success', description = message })
    isDrinking = false
end

CreateThread(function()
    exports.ox_target:addModel(Config.Props, {
        {
            name = 'ls_waterdispenser_drink',
            label = Config.TargetLabel,
            icon = Config.TargetIcon,
            distance = Config.TargetDistance,
            canInteract = function()
                return not isDrinking
            end,
            onSelect = function()
                drink()
            end,
        },
    })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    exports.ox_target:removeModel(Config.Props, 'ls_waterdispenser_drink')
    if isDrinking then
        stopAnim()
        removeCup()
        SendNUIMessage({ action = 'stopFill' })
    end
end)
