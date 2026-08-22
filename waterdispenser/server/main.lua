if not Framework.init() then
    return
end

local drinkHistory = {}
local activeSessions = {}

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

local function clearSession(source)
    activeSessions[source] = nil
end

local function beginSession(source)
    activeSessions[source] = os.time()
end

local function sessionIsValid(source)
    local startedAt = activeSessions[source]

    if not startedAt then
        return false
    end

    local maxDuration = math.ceil((Config.FillDuration + Config.SipDelay + 5000) / 1000)

    if (os.time() - startedAt) > maxDuration then
        clearSession(source)
        return false
    end

    return true
end

lib.callback.register('waterdispenser:canDrink', function(source)
    if not Framework.isReady() then
        return false, 'Dispenser system is unavailable.'
    end

    if activeSessions[source] then
        return false, 'You are already filling a cup.'
    end

    local player = Framework.getPlayer(source)

    if not player then
        return false, 'Unable to use the dispenser right now.'
    end

    local playerKey = Framework.getPlayerKey(player)
    local allowed, message = getDrinkStatus(playerKey)

    if not allowed then
        return false, message
    end

    beginSession(source)
    return true
end)

lib.callback.register('waterdispenser:drinkWater', function(source)
    if not Framework.isReady() then
        clearSession(source)
        return nil
    end

    if not sessionIsValid(source) then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Your drink session expired. Try again.',
        })
        return nil
    end

    local player = Framework.getPlayer(source)

    if not player then
        clearSession(source)
        return nil
    end

    local playerKey = Framework.getPlayerKey(player)
    local allowed, message, timestamps = getDrinkStatus(playerKey)

    if not allowed then
        clearSession(source)
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = message,
        })
        return nil
    end

    timestamps[#timestamps + 1] = os.time()
    drinkHistory[playerKey] = timestamps

    if not Framework.addThirst(source, player, Config.ThirstRefill) then
        clearSession(source)
        return nil
    end

    clearSession(source)

    local remark = Config.Remarks[math.random(#Config.Remarks)]

    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = ('You feel refreshed (+ %s%% thirst).'):format(Config.ThirstRefill),
    })

    return remark
end)

lib.callback.register('waterdispenser:cancelDrink', function(source)
    clearSession(source)
    return true
end)

AddEventHandler('playerDropped', function()
    clearSession(source)

    local player = Framework.getPlayer(source)

    if player then
        drinkHistory[Framework.getPlayerKey(player)] = nil
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    drinkHistory = {}
    activeSessions = {}
end)
