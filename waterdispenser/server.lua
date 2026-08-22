local drinkHistory = {}

local function getPlayerKey(xPlayer)
    return xPlayer.identifier
end

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
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        return false, 'Unable to use the dispenser right now.'
    end

    local playerKey = getPlayerKey(xPlayer)
    local allowed, message = getDrinkStatus(playerKey)

    return allowed, message
end)

lib.callback.register('waterdispenser:drinkWater', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        return nil
    end

    local playerKey = getPlayerKey(xPlayer)
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

    local thirstAmount = math.floor((Config.ThirstRefill / 100) * Config.ThirstMax)
    TriggerClientEvent('esx_status:add', source, 'thirst', thirstAmount)

    local remark = Config.Remarks[math.random(#Config.Remarks)]

    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = ('You feel refreshed (+ %s%% thirst).'):format(Config.ThirstRefill),
    })

    return remark
end)

AddEventHandler('playerDropped', function()
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer then
        drinkHistory[getPlayerKey(xPlayer)] = nil
    end
end)
