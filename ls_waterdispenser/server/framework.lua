Framework = {}

local activeFramework = nil
local ESX = nil
local QBCore = nil

local function detectFramework()
    local configured = Config.Framework

    if configured == 'qbox' then
        return 'qbox'
    end

    if configured == 'esx' then
        return 'esx'
    end

    if GetResourceState('qbx_core') == 'started' then
        return 'qbox'
    end

    if GetResourceState('qb-core') == 'started' then
        return 'qbox'
    end

    if GetResourceState('es_extended') == 'started' then
        return 'esx'
    end

    return nil
end

local function checkDependencies()
    local required = { 'ox_lib', 'ox_target' }
    local missing = {}

    for i = 1, #required do
        if GetResourceState(required[i]) ~= 'started' then
            missing[#missing + 1] = required[i]
        end
    end

    if #missing > 0 then
        print(('^1[waterdispenser] Missing dependencies: %s^0'):format(table.concat(missing, ', ')))
        return false
    end

    return true
end

function Framework.init()
    if not checkDependencies() then
        return false
    end

    activeFramework = detectFramework()

    if not activeFramework then
        print('^1[waterdispenser] No supported framework found. Set Config.Framework to qbox or esx.^0')
        return false
    end

    if activeFramework == 'qbox' then
        if GetResourceState('qbx_core') == 'started' then
            print('^2[waterdispenser] Framework: Qbox (qbx_core)^0')
        else
            QBCore = exports['qb-core']:GetCoreObject()
            print('^2[waterdispenser] Framework: Qbox (qb-core)^0')
        end
    end

    if activeFramework == 'esx' then
        if GetResourceState('esx_status') ~= 'started' then
            print('^3[waterdispenser] Warning: esx_status is not started.^0')
        end

        ESX = exports['es_extended']:getSharedObject()
        print('^2[waterdispenser] Framework: ESX^0')
    end

    if Config.Hud == '17mov_Hud' and GetResourceState(Config.HudResource) ~= 'started' then
        print(('^3[waterdispenser] Warning: %s is not started. HUD sync may not work until it loads.^0'):format(Config.HudResource))
    end

    print('^2[waterdispenser] Production build loaded successfully.^0')
    return true
end

function Framework.getPlayer(source)
    if activeFramework == 'qbox' then
        if GetResourceState('qbx_core') == 'started' then
            return exports.qbx_core:GetPlayer(source)
        end

        if QBCore then
            return QBCore.Functions.GetPlayer(source)
        end
    end

    if activeFramework == 'esx' and ESX then
        return ESX.GetPlayerFromId(source)
    end

    return nil
end

function Framework.getPlayerKey(player)
    if not player then
        return nil
    end

    if activeFramework == 'qbox' then
        return player.PlayerData.citizenid
    end

    if activeFramework == 'esx' then
        return player.identifier
    end

    return nil
end

function Framework.removeMoney(player, amount)
    if amount <= 0 then
        return true
    end

    if activeFramework == 'qbox' then
        local cash = player.PlayerData.money and player.PlayerData.money.cash or 0

        if cash < amount then
            return false
        end

        player.Functions.RemoveMoney('cash', amount, 'water-dispenser')
        return true
    end

    if activeFramework == 'esx' then
        if player.getMoney() < amount then
            return false
        end

        player.removeMoney(amount)
        return true
    end

    return false
end

function Framework.getMoney(player)
    if activeFramework == 'qbox' then
        return player.PlayerData.money and player.PlayerData.money.cash or 0
    end

    if activeFramework == 'esx' then
        return player.getMoney()
    end

    return 0
end

function Framework.addThirst(source, player, refillPercent)
    if activeFramework == 'qbox' then
        local current = player.PlayerData.metadata.thirst or 0
        local newThirst = math.min(100, current + refillPercent)

        player.Functions.SetMetaData('thirst', newThirst)

        if player.Functions.Save then
            player.Functions.Save()
        end

        local hunger = player.PlayerData.metadata.hunger or 100
        TriggerClientEvent('hud:client:UpdateNeeds', source, hunger, newThirst)
        TriggerClientEvent('waterdispenser:client:syncNeeds', source, hunger, newThirst)

        return true
    end

    if activeFramework == 'esx' then
        local thirstAmount = math.floor((refillPercent / 100) * Config.ThirstMax)
        TriggerClientEvent('esx_status:add', source, 'thirst', thirstAmount)
        return true
    end

    return false
end

function Framework.isReady()
    return activeFramework ~= nil
end

function Framework.getName()
    return activeFramework
end
