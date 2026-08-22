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

function Framework.init()
    activeFramework = detectFramework()

    if not activeFramework then
        print('^1[waterdispenser] No supported framework found. Set Config.Framework to qbox or esx.^0')
        return false
    end

    if activeFramework == 'qbox' then
        if GetResourceState('qbx_core') == 'started' then
            print('^2[waterdispenser] Using Qbox (qbx_core)^0')
        else
            QBCore = exports['qb-core']:GetCoreObject()
            print('^2[waterdispenser] Using Qbox (qb-core)^0')
        end
    end

    if activeFramework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
        print('^2[waterdispenser] Using ESX^0')
    end

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

function Framework.addThirst(source, player, refillPercent)
    if activeFramework == 'qbox' then
        local current = player.PlayerData.metadata.thirst or 0
        local newThirst = math.min(100, current + refillPercent)

        player.Functions.SetMetaData('thirst', newThirst)

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
