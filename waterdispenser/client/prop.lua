Prop = {}

local CUP_MODEL = `prop_cs_paper_cup`
local cupEntity = nil

local function debugPrint(message)
    if Config.Debug then
        print(('[waterdispenser] %s'):format(message))
    end
end

--- Attach paper cup to the player's RIGHT hand (bone 57005).
---@return number|nil cup entity handle
local function attachCup()
    local model = Config.CupModel or CUP_MODEL

    lib.requestModel(model)

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local cup = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)

    if not cup or cup == 0 or not DoesEntityExist(cup) then
        SetModelAsNoLongerNeeded(model)
        return nil
    end

    -- 57005 = SKEL_R_Hand (right hand)
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
    return cup
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
        debugPrint('Failed to attach cup to right hand.')
        return nil
    end

    cupEntity = cup
    debugPrint('Cup attached to RIGHT hand (bone 57005)')
    return cup
end

function Prop.spawnInHand()
    return Prop.attachCup() ~= nil
end

function Prop.getEntity()
    return cupEntity
end
