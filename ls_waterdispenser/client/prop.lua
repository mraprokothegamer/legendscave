Prop = {}

local cupEntity = nil

-- Known-valid Rockstar cup/mug props (paper cup is invalid on some builds)
local FALLBACK_MODELS = {
    `prop_plastic_cup_02`,
    `p_amb_coffeecup_01`,
    `prop_mug_02`,
    `v_ret_fh_mug1`,
    `prop_cs_paper_cup`,
}

local function debugPrint(message)
    if Config.Debug then
        print(('[ls_waterdispenser] %s'):format(message))
    end
end

local function resolveModel(model)
    if model == nil then
        return nil
    end

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

local function getCupModelList()
    local list = {}
    local seen = {}

    local function push(model)
        local resolved = resolveModel(model)
        if resolved and not seen[resolved] then
            seen[resolved] = true
            list[#list + 1] = resolved
        end
    end

    push(Config.CupModel)
    push(Config.CupModelFallback)

    for i = 1, #FALLBACK_MODELS do
        push(FALLBACK_MODELS[i])
    end

    return list
end

--- Attach a cup to the player's RIGHT hand (bone 57005).
---@return number|nil cup entity handle
local function attachCup()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local models = getCupModelList()

    if #models == 0 then
        debugPrint('No valid cup models available in this game build.')
        return nil
    end

    for i = 1, #models do
        local model = models[i]

        -- Never call lib.requestModel on an invalid hash (it throws)
        local ok = pcall(function()
            lib.requestModel(model, 5000)
        end)

        if ok and HasModelLoaded(model) then
            local cup = CreateObject(model, coords.x, coords.y, coords.z + 0.2, true, true, false)

            if cup and cup ~= 0 and DoesEntityExist(cup) then
                AttachEntityToEntity(
                    cup,
                    ped,
                    GetPedBoneIndex(ped, Config.CupBone or 57005),
                    Config.CupOffset.x,
                    Config.CupOffset.y,
                    Config.CupOffset.z,
                    Config.CupRotation.x,
                    Config.CupRotation.y,
                    Config.CupRotation.z,
                    true,
                    true,
                    false,
                    true,
                    1,
                    true
                )

                SetModelAsNoLongerNeeded(model)
                debugPrint(('Cup attached to RIGHT hand with model hash %s'):format(model))
                return cup
            end

            if cup and DoesEntityExist(cup) then
                DeleteObject(cup)
            end

            SetModelAsNoLongerNeeded(model)
        else
            debugPrint(('Skipped invalid/unloadable cup model: %s'):format(model))
            if HasModelLoaded(model) then
                SetModelAsNoLongerNeeded(model)
            end
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

--- Spawn and attach cup to right hand. Returns the cup entity.
---@return number|nil
function Prop.attachCup()
    Prop.cleanup()

    local cup = attachCup()

    if not cup then
        debugPrint('Failed to attach cup to right hand (all models failed).')
        return nil
    end

    cupEntity = cup
    return cup
end

function Prop.spawnInHand()
    return Prop.attachCup() ~= nil
end

function Prop.getEntity()
    return cupEntity
end
