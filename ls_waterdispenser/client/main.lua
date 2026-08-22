local isDrinking = false
local cupObject = nil

local function resolveCupModel()
    local candidates = { Config.Cup.model, Config.Cup.fallback }
    for i = 1, #candidates do
        local name = candidates[i]
        if name and name ~= false then
            local hash = type(name) == 'number' and name or joaat(name)
            if IsModelInCdimage(hash) and IsModelValid(hash) then
                return hash
            end
        end
    end
    return nil
end

local function attachCup()
    if not Config.Cup.model then return end

    local model = resolveCupModel()
    if not model then
        print('^1[ls_waterdispenser]^7 No valid cup model (tried Config.Cup.model / fallback). Skipping held prop.')
        return
    end

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

    -- Hold the cup in the left hand and play the drinking animation while the
    -- middle-right NUI fills the cup with water. The player stays in the
    -- animation for the whole duration, until the water is full.
    attachCup()
    playAnim()

    SendNUIMessage({
        action = 'startFill',
        duration = Config.DrinkDuration,
        sound = Config.Sound.enabled and Config.Sound.file or nil,
        volume = Config.Sound.volume,
    })

    Wait(Config.DrinkDuration)

    stopAnim()
    removeCup()
    SendNUIMessage({ action = 'stopFill' })

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
