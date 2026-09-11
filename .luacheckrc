-- Luacheck config for the legendscave FiveM/Qbox resources.
--
-- These resources run inside the CitizenFX (FXServer) Lua 5.4 runtime with
-- ox_lib and qbx_core, so a large number of engine natives and framework
-- helpers are legitimate globals. They are whitelisted below so luacheck can
-- focus on real problems (typos, unused vars, shadowing, syntax errors).

std = "lua54"

-- Config tables are declared in each resource's config.lua and read by the
-- client/server scripts.
globals = {
    "Config",
}

read_globals = {
    -- CitizenFX / shared runtime
    "exports", "lib", "cache", "source", "promise", "Citizen",
    "json", "msgpack", "vector2", "vector3", "vector4", "vec2", "vec3", "vec4",
    "quat", "Entity", "Player", "GetHashKey", "joaat",

    -- Events
    "AddEventHandler", "RegisterNetEvent", "RemoveEventHandler",
    "TriggerEvent", "TriggerServerEvent", "TriggerClientEvent",
    "GetCurrentResourceName", "GetInvokingResource",

    -- Threads / timing
    "CreateThread", "Wait", "SetTimeout",

    -- NUI
    "SendNUIMessage", "SetNuiFocus", "RegisterNUICallback", "SetNuiFocusKeepInput",

    -- Players / peds
    "PlayerId", "PlayerPedId", "GetPlayerName", "GetPlayerPed",
    "GetPlayerServerId", "GetPlayerIdentifierByType",
    "NetworkGetPlayerIndexFromPed", "IsPedAPlayer", "IsPedInAnyVehicle",
    "IsPedDeadOrDying", "IsEntityDead",

    -- Entities / world
    "GetEntityCoords", "GetEntityHealth", "SetEntityHealth",
    "CreateObject", "DoesEntityExist", "DeleteEntity", "SetEntityAsNoLongerNeeded",
    "GetPedBoneIndex", "AttachEntityToEntity", "DetachEntity",
    "IsModelInCdimage", "IsModelValid", "SetModelAsNoLongerNeeded",
    "GetPrevWeatherTypeHashName",

    -- Animations
    "RequestAnimDict", "HasAnimDictLoaded", "RemoveAnimDict",
    "TaskPlayAnim", "ClearPedTasks",

    -- Markers / on-screen text
    "DrawMarker",
    "SetTextScale", "SetTextFont", "SetTextProportional", "SetTextColour",
    "SetTextCentre", "SetTextOutline",
    "BeginTextCommandDisplayText", "EndTextCommandDisplayText",
    "AddTextComponentSubstringPlayerName", "SetDrawOrigin", "ClearDrawOrigin",
}

-- fxmanifest.lua is a manifest DSL, not runtime Lua; the web UI lives in html/.
exclude_files = {
    "**/fxmanifest.lua",
    "**/html/**",
}
