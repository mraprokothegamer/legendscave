if not Framework.init() then
    return
end

local drinkHistory = {}

local function pruneOldDrinks(timestamps, now)
    local pruned = {}

    for i = 1, #timestamps do
        if (now - timestamps[i]) < Config.CooldownWindow then
            pruned[#pruned + 1] = timestamps[i]
        end
    end

    return pruned
end

local function getCooldownMessage(remainingSeconds)
    local totalMinutes = math.ceil(remainingSeconds / 60)

    if totalMinutes <= 1 then
        return 'You can drink again in about a minute.'
    end

    return ('You can drink again in about %s minutes.'):format(totalMinutes)
end

local function getDrinkStatus(playerKey)
    local now = os.time()
    local timestamps = drinkHistory[playerKey] or {}
    timestamps = pruneOldDrinks(timestamps, now)

    if #timestamps >= Config.MaxDrinksPerHour then
        local oldest = timestamps[1]
        local remaining = Config.CooldownWindow - (now - oldest)

        if remaining > 0 then
            return false, getCooldownMessage(remaining), timestamps
        end

        timestamps = pruneOldDrinks(timestamps, now)
    end

    return true, nil, timestamps
end

lib.callback.register('waterdispenser:canDrink', function(source)
    if not Framework.isReady() then
        return false, 'Dispenser system is unavailable.'
    end

    local player = Framework.getPlayer(source)

    if not player then
        return false, 'Unable to use the dispenser right now.'
    end

    local playerKey = Framework.getPlayerKey(player)
    local allowed, message = getDrinkStatus(playerKey)

    return allowed, message
end)

lib.callback.register('waterdispenser:drinkWater', function(source)
    if not Framework.isReady() then
        return nil
    end

    local player = Framework.getPlayer(source)

    if not player then
        return nil
    end

    local playerKey = Framework.getPlayerKey(player)
    local allowed, message, timestamps = getDrinkStatus(playerKey)

    if not allowed then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = message,
        })
        return nil
    end

    timestamps[#timestamps + 1] = os.time()
    drinkHistory[playerKey] = timestamps

    Framework.addThirst(source, player, Config.ThirstRefill)

    local remark = Config.Remarks[math.random(#Config.Remarks)]

    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = ('You feel refreshed (+ %s%% thirst).'):format(Config.ThirstRefill),
    })

    return remark
end)

AddEventHandler('playerDropped', function()
    local player = Framework.getPlayer(source)

    if player then
        drinkHistory[Framework.getPlayerKey(player)] = nil
    end
end)
