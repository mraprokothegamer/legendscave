Prop = {}

local cupEntity = nil

local function debugPrint(message)
    if Config.Debug then
        print(('[waterdispenser] %s'):format(message))
    end
end

function Prop.cleanup()
    if cupEntity and DoesEntityExist(cupEntity) then
        DetachEntity(cupEntity, true, true)
        DeleteEntity(cupEntity)
    end

    cupEntity = nil
end

local function tryLoadModel(model)
    if not model or not IsModelValid(model) then
        return false
    end

    lib.requestModel(model, 5000)
    return HasModelLoaded(model)
end

local function createCupObject(model, ped)
    local coords = GetEntityCoords(ped)
    local object = CreateObject(model, coords.x, coords.y, coords.z + 0.2, false, false, false)

    if not object or object == 0 or not DoesEntityExist(object) then
        return nil
    end

    SetEntityAsMissionEntity(object, true, true)
    SetEntityCollision(object, false, false)
    SetEntityCompletelyDisableCollision(object, true, true)
    SetEntityVisible(object, true, false)
    SetEntityAlpha(object, 255, false)

    return object
end

local function attachCupToHand(object, ped)
    local boneIndex = GetPedBoneIndex(ped, Config.CupBone)

    AttachEntityToEntity(
        object,
        ped,
        boneIndex,
        Config.CupOffset.x,
        Config.CupOffset.y,
        Config.CupOffset.z,
        Config.CupRotation.x,
        Config.CupRotation.y,
        Config.CupRotation.z,
        false,
        false,
        false,
        false,
        2,
        true
    )
end

function Prop.spawnInHand(ped)
    Prop.cleanup()

    local models = { Config.CupModel, Config.CupModelFallback }

    for i = 1, #models do
        local model = models[i]

        if model and tryLoadModel(model) then
            local object = createCupObject(model, ped)

            if object then
                attachCupToHand(object, ped)
                cupEntity = object
                SetModelAsNoLongerNeeded(model)
                debugPrint(('Cup attached to left hand using model hash: %s'):format(model))
                return true
            end

            SetModelAsNoLongerNeeded(model)
        end
    end

    debugPrint('Failed to spawn cup prop.')
    return false
end

function Prop.getEntity()
    return cupEntity
end
