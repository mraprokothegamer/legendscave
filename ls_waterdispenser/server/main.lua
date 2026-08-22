-- Server-authoritative emergency water: enforces the rolling use limit and
-- applies thirst through Qbox. Nothing here trusts the client beyond the
-- request to use a dispenser.

-- [license] = { osTimestampSeconds, ... }
local usesByLicense = {}

local function getLicense(src)
    return GetPlayerIdentifierByType(src, 'license2')
        or GetPlayerIdentifierByType(src, 'license')
end

-- Drop entries outside the rolling window and return how many remain.
local function pruneAndCount(license)
    local now = os.time()
    local windowSec = Config.WindowMinutes * 60
    local list = usesByLicense[license] or {}
    local kept = {}

    for i = 1, #list do
        if now - list[i] < windowSec then
            kept[#kept + 1] = list[i]
        end
    end

    usesByLicense[license] = kept
    return #kept
end

lib.callback.register('ls_waterdispenser:server:tryUse', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then
        return false, 'Could not find your character.'
    end

    local license = getLicense(source)
    if not license then
        return false, 'Could not verify your identity.'
    end

    local used = pruneAndCount(license)
    if used >= Config.UsesPerHour then
        return false, 'No emergency water left right now. Try again later.'
    end

    -- Consume one use up front so rapid re-triggers can't slip past the limit.
    usesByLicense[license][#usesByLicense[license] + 1] = os.time()

    -- Apply thirst (additive, capped at 100).
    local metadata = player.PlayerData.metadata
    local current = metadata.thirst or 0
    local newThirst = math.min(100, current + Config.ThirstRestore)
    player.Functions.SetMetaData('thirst', newThirst)

    -- Refresh the HUD needs. qbx keeps this event for compatibility; if your
    -- HUD reads thirst differently, adjust this single line.
    TriggerClientEvent('hud:client:UpdateNeeds', source, metadata.hunger or 0, newThirst)

    local remaining = Config.UsesPerHour - #usesByLicense[license]
    return true, ('Emergency water left: %d'):format(remaining)
end)

-- Free memory when a player drops.
AddEventHandler('playerDropped', function()
    local license = getLicense(source)
    if license then
        usesByLicense[license] = nil
    end
end)
