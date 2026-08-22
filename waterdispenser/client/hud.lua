Hud = {}

local function resolveHudIntegration()
    local setting = Config.Hud

    if setting == 'default' or setting == 'none' then
        return nil
    end

    if setting == '17mov_Hud' then
        return Config.HudResource or '17mov_Hud'
    end

    if setting == 'auto' then
        local resource = Config.HudResource or '17mov_Hud'
        if GetResourceState(resource) == 'started' then
            return resource
        end
    end

    return nil
end

local function update17movHud(hunger, thirst)
    local resource = resolveHudIntegration()

    if not resource or GetResourceState(resource) ~= 'started' then
        return
    end

    local ok, err = pcall(function()
        exports[resource]:UpdateComponentValue('hunger', hunger / 100)
        exports[resource]:UpdateComponentValue('thirst', thirst / 100)
    end)

    if not ok and Config.Debug then
        print(('[waterdispenser] HUD sync failed: %s'):format(err))
    end
end

RegisterNetEvent('waterdispenser:client:syncNeeds', function(hunger, thirst)
    update17movHud(hunger, thirst)
end)

function Hud.syncNeeds(hunger, thirst)
    update17movHud(hunger, thirst)
end
