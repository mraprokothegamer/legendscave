-- Luacheck config for the FiveM (CitizenFX) + ox_lib runtime.
std = "lua54"

-- Config is defined in config.lua and consumed by client/server.
globals = {
    "Config",
}

read_globals = {
    -- ox_lib / shared runtime globals
    "exports", "lib", "cache", "source",
    -- CitizenFX natives used by this resource
    "CreateThread", "Wait",
    "SendNUIMessage", "SetNuiFocus",
    "TriggerServerEvent", "TriggerClientEvent",
    "AddEventHandler", "RegisterNetEvent",
    "GetCurrentResourceName", "GetHashKey", "joaat",
    "GetEntityCoords", "CreateObject", "GetPedBoneIndex",
    "AttachEntityToEntity", "SetModelAsNoLongerNeeded",
    "DoesEntityExist", "DeleteEntity",
    "TaskPlayAnim", "ClearPedTasks", "RemoveAnimDict",
    "GetPlayerIdentifierByType",
}

-- fxmanifest.lua is a manifest DSL, not runtime Lua.
exclude_files = {
    "**/fxmanifest.lua",
}
