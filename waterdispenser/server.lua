RegisterNetEvent('waterdispenser:buyWater', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    local price = Config.WaterPrice
    local refill = Config.ThirstRefill

    if xPlayer.getMoney() < price then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'Not enough money to buy water!',
        })
        return
    end

    xPlayer.removeMoney(price)

    local thirstAmount = math.floor((refill / 100) * Config.ThirstMax)
    TriggerClientEvent('esx_status:add', src, 'thirst', thirstAmount)

    TriggerClientEvent('ox_lib:notify', src, {
        type = 'success',
        description = ('You paid $%s and refilled thirst by %s%%!'):format(price, refill),
    })
end)
