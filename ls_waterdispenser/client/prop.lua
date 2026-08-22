--[[
    ls_waterdispenser cup prop module
    VERSION: 2.3.5 — optional; main.lua embeds the same Prop API if this file is missing
]]

print('^2[ls_waterdispenser] client/prop.lua v2.3.5 loaded (Prop module OK)^0')

Prop = {}

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

local function debugPrint(msg)
    if Config.Debug then
        print(('[ls_waterdispenser] %s'):format(msg))
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
        Wait(0)
    end
    return true
end

function Prop.cleanup()
    if cupEntity and DoesEntityExist(cupEntity) then
        DetachEntity(cupEntity, true, true)
        SetEntityAsMissionEntity(cupEntity, true, true)
        DeleteEntity(cupEntity)
    end
    cupEntity = nil
end

--- Attach red/plastic cup to LEFT hand. Returns entity or nil.
function Prop.attachCup()
    Prop.cleanup()

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
                -- Try local object first
                local cup = CreateObject(model, coords.x, coords.y, coords.z + 0.2, false, false, false)

                if (not cup or cup == 0 or not DoesEntityExist(cup)) then
                    -- Fallback networked
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
            else
                debugPrint(('Model failed to load: %s'):format(model))
            end
        end
    end

    debugPrint('FAILED to attach any cup to left hand')
    return nil
end

function Prop.getEntity()
    return cupEntity
end
