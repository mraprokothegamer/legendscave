local function clamp(value, min, max)
    if value < min then
        return min
    end

    if value > max then
        return max
    end

    return value
end

CreateThread(function()
    Config.ThirstRefill = clamp(Config.ThirstRefill or 10, 1, 100)
    Config.MaxDrinksPerHour = clamp(Config.MaxDrinksPerHour or 2, 1, 10)
    Config.CooldownWindow = clamp(Config.CooldownWindow or 3600, 60, 86400)
    Config.FillDuration = clamp(Config.FillDuration or 7000, 5000, 10000)
    Config.SipDelay = clamp(Config.SipDelay or 400, 100, 2000)
    Config.RescanInterval = clamp(Config.RescanInterval or 30000, 10000, 120000)
    Config.InitialScanDelay = clamp(Config.InitialScanDelay or 5000, 1000, 30000)
    Config.AnimDuration = Config.FillDuration + 2500

    if not Config.Remarks or #Config.Remarks == 0 then
        Config.Remarks = {
            'That hit the spot.',
        }
    end

    if not Config.ScanKeywords or #Config.ScanKeywords == 0 then
        Config.ScanKeywords = { 'watercooler' }
    end

    if not Config.KnownModels or #Config.KnownModels == 0 then
        Config.KnownModels = { `prop_watercooler` }
    end
end)
