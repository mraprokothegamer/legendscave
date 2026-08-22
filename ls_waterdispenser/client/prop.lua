Prop = {}

local cupEntity = nil
local loadedModel = nil

-- Red / plastic cup models (validated before spawn)
local FALLBACK_MODELS = {
    `prop_plastic_cup_02`,
    `apa_prop_cs_plastic_cup_01`,
    `ng_proc_sodacup_01a`,
    `ng_proc_sodacup_01b`,
    `ng_proc_sodacup_01c`,
    `p_amb_coffeecup_01`,
}

-- Try left-hand bones in order (prop hand then skeleton hand)
local LEFT_HAND_BONES = {
    60309, -- PH_L_Hand (best for props)
    18905, -- SKEL_L_Hand
    14201, -- IK_L_Hand
}

local function debugPrint(message)
    if Config.Debug then
        print(('[ls_waterdispenser] %s'):format(message))
    end
end

local function resolveModel(model)
    if type(model) == 'string' then
        model = joaat(model)
    end
    if type(model) ~= 'number' or model == 0 then
        return nil
    end
    if not IsModelInCdimage(model) then
        return nil
    end
    return model
end

local function loadModelSafe(model)
    if HasModelLoaded(model) then
        return true
    end

    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) do
        if GetGameTimer() > timeout then
            return false
        end
        Wait(0)
    end
    return true
end

local function tryAttachOne(model, ped, boneId)
    if not loadModelSafe(model) then
        return nil
    end

    local coords = GetEntityCoords(ped)
    local boneIndex = GetPedBoneIndex(ped, boneId)

    -- Local object only (networked cups often never appear for the local player)
    local cup = CreateObjectNoOffset(model, coords.x, coords.y, coords.z + 0.25, false, false, false)

    if not cup or cup == 0 or not DoesEntityExist(cup) then
        SetModelAsNoLongerNeeded(model)
        return nil
    end

    SetEntityAsMissionEntity(cup, true, true)
    SetEntityCollision(cup, false, false)
    SetEntityCompletelyDisableCollision(cup, true, true)
    SetEntityVisible(cup, true, false)
    SetEntityAlpha(cup, 255, false)
    ResetEntityAlpha(cup)

    local ox = (Config.CupOffset and Config.CupOffset.x) or 0.12
    local oy = (Config.CupOffset and Config.CupOffset.y) or 0.028
    local oz = (Config.CupOffset and Config.CupOffset.z) or 0.001
    local rx = (Config.CupRotation and Config.CupRotation.x) or 10.0
    local ry = (Config.CupRotation and Config.CupRotation.y) or 175.0
    local rz = (Config.CupRotation and Config.CupRotation.z) or 0.0

    AttachEntityToEntity(
        cup,
        ped,
        boneIndex,
        ox, oy, oz,
        rx, ry, rz,
        true, true, false, true, 1, true
    )

    Wait(0)

    if not IsEntityAttachedToEntity(cup, ped) then
        DeleteEntity(cup)
        SetModelAsNoLongerNeeded(model)
        return nil
    end

    return cup
end

function Prop.cleanup()
    if cupEntity and DoesEntityExist(cupEntity) then
        DetachEntity(cupEntity, true, true)
        SetEntityAsMissionEntity(cupEntity, true, true)
        DeleteEntity(cupEntity)
    end
    cupEntity = nil

    if loadedModel then
        SetModelAsNoLongerNeeded(loadedModel)
        loadedModel = nil
    end
end

function Prop.attachCup()
    local ok, result = pcall(function()
        Prop.cleanup()

        local ped = PlayerPedId()

        local models = {}
        local seen = {}
        local function push(m)
            local r = resolveModel(m)
            if r and not seen[r] then
                seen[r] = true
                models[#models + 1] = r
            end
        end

        push(Config.CupModel)
        push(Config.CupModelFallback)
        for i = 1, #FALLBACK_MODELS do
            push(FALLBACK_MODELS[i])
        end

        local bones = { Config.CupBone or 60309 }
        for i = 1, #LEFT_HAND_BONES do
            local b = LEFT_HAND_BONES[i]
            local exists = false
            for j = 1, #bones do
                if bones[j] == b then exists = true break end
            end
            if not exists then bones[#bones + 1] = b end
        end

        for b = 1, #bones do
            for i = 1, #models do
                local cup = tryAttachOne(models[i], ped, bones[b])
                if cup then
                    cupEntity = cup
                    loadedModel = models[i]
                    debugPrint(('Cup attached LEFT model=%s bone=%s'):format(models[i], bones[b]))
                    return cup
                end
            end
        end

        debugPrint('All cup models/bones failed')
        return nil
    end)

    if not ok then
        debugPrint(('attachCup error: %s'):format(tostring(result)))
        return nil
    end

    return result
end

function Prop.getEntity()
    return cupEntity
end
