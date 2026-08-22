Prop = {}

local cupEntity = nil

-- Prefer red/plastic cup look; validate before load (paper cup invalid on some builds)
local FALLBACK_MODELS = {
    `apa_prop_cs_plastic_cup_01`,
    `prop_plastic_cup_02`,
    `prop_cs_paper_cup`,
    `p_amb_coffeecup_01`,
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
    if not IsModelInCdimage(model) or not IsModelValid(model) then
        return nil
    end
    return model
end

local function loadModelSafe(model)
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
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

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

    local bone = Config.CupBone or 18905 -- LEFT hand

    for i = 1, #models do
        local model = models[i]
        if loadModelSafe(model) then
            local cup = CreateObject(model, coords.x, coords.y, coords.z + 0.2, true, true, false)
            if cup and cup ~= 0 and DoesEntityExist(cup) then
                AttachEntityToEntity(
                    cup,
                    ped,
                    GetPedBoneIndex(ped, bone),
                    Config.CupOffset.x, Config.CupOffset.y, Config.CupOffset.z,
                    Config.CupRotation.x, Config.CupRotation.y, Config.CupRotation.z,
                    true, true, false, true, 1, true
                )
                SetModelAsNoLongerNeeded(model)
                debugPrint(('Cup on LEFT hand model=%s bone=%s'):format(model, bone))
                return cup
            end
            if cup and DoesEntityExist(cup) then DeleteObject(cup) end
            SetModelAsNoLongerNeeded(model)
        end
    end

    return nil
end

function Prop.cleanup()
    if cupEntity and DoesEntityExist(cupEntity) then
        DetachEntity(cupEntity, true, true)
        DeleteObject(cupEntity)
    end
    cupEntity = nil
end

function Prop.attachCup()
    Prop.cleanup()
    local cup = attachCup()
    if not cup then return nil end
    cupEntity = cup
    return cup
end

function Prop.spawnInHand()
    return Prop.attachCup() ~= nil
end

function Prop.getEntity()
    return cupEntity
end
