--[[
  Local prop jukebox client
  - ox_target on existing world props (no items)
  - xSound PlayUrlPos per prop coords
  - One shared draw loop for markers + 3D text (lightweight)
  - Fade in / fade out for "Now Playing" label
]]

local xSound = exports.xsound

--- Active jukeboxes keyed by stable sound id
--- { coords = vector3, title = string, alpha = number, fading = 'in'|'out'|nil }
local activeProps = {}
local openCoords = nil
local drawRunning = false

local function roundCoord(n)
    return math.floor(n * 100 + 0.5) / 100
end

local function soundIdFromCoords(coords)
    return ('jukebox_%.2f_%.2f_%.2f'):format(roundCoord(coords.x), roundCoord(coords.y), roundCoord(coords.z))
end

local function coordsPayload(coords)
    return {
        x = roundCoord(coords.x),
        y = roundCoord(coords.y),
        z = roundCoord(coords.z),
    }
end

local function vectorFromPayload(c)
    return vector3(c.x + 0.0, c.y + 0.0, c.z + 0.0)
end

local function DrawText3D(x, y, z, text, alpha)
    if alpha < 1 then return end
    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 0, alpha)
    SetTextCentre(true)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(x, y, z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

local function ensureDrawLoop()
    if drawRunning then return end
    drawRunning = true

    CreateThread(function()
        while next(activeProps) ~= nil do
            local ped = PlayerPedId()
            local pcoords = GetEntityCoords(ped)
            local sleep = 500

            for _, prop in pairs(activeProps) do
                local dist = #(pcoords - prop.coords)
                if dist <= Config.MarkerDrawDistance then
                    sleep = 0
                    local m = Config.Marker
                    DrawMarker(
                        m.type,
                        prop.coords.x, prop.coords.y, prop.coords.z + m.offsetZ,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        m.scale, m.scale, m.scale,
                        m.r, m.g, m.b, m.a,
                        false, true, 2, false, nil, nil, false
                    )
                    DrawText3D(
                        prop.coords.x, prop.coords.y, prop.coords.z + Config.Text.offsetZ,
                        ('Now Playing: %s'):format(prop.title),
                        prop.alpha
                    )
                end
            end

            Wait(sleep)
        end

        drawRunning = false
    end)
end

local function fadeIn(soundId)
    CreateThread(function()
        local prop = activeProps[soundId]
        if not prop then return end
        prop.fading = 'in'
        prop.alpha = 0
        while activeProps[soundId] and activeProps[soundId].fading == 'in' do
            local p = activeProps[soundId]
            p.alpha = math.min(Config.Text.maxAlpha, p.alpha + Config.Text.fadeStep)
            if p.alpha >= Config.Text.maxAlpha then
                p.fading = nil
                break
            end
            Wait(Config.Text.fadeWait)
        end
    end)
end

local function fadeOutAndClear(soundId)
    CreateThread(function()
        local prop = activeProps[soundId]
        if not prop then return end
        prop.fading = 'out'
        while activeProps[soundId] and activeProps[soundId].fading == 'out' do
            local p = activeProps[soundId]
            p.alpha = math.max(0, p.alpha - Config.Text.fadeStep)
            if p.alpha <= 0 then
                activeProps[soundId] = nil
                break
            end
            Wait(Config.Text.fadeWait)
        end
    end)
end

-- ox_target: existing world models only
CreateThread(function()
    exports.ox_target:addModel(Config.MusicProps, {
        {
            name = 'legendscave_jukebox_open',
            icon = Config.Target.icon,
            label = Config.Target.label,
            distance = Config.Target.distance,
            onSelect = function(data)
                local entity = data.entity
                if not entity or entity == 0 then return end
                local coords = GetEntityCoords(entity)
                openCoords = coordsPayload(coords)
                SetNuiFocus(true, true)
                SendNUIMessage({
                    action = 'open',
                    coords = openCoords,
                    playlist = Config.Playlist,
                })
            end,
        },
    })
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    openCoords = nil
    cb({ ok = true })
end)

RegisterNUICallback('playTrack', function(data, cb)
    local coords = data.coords or openCoords
    if not coords then
        cb({ ok = false, error = 'no_coords' })
        return
    end
    TriggerServerEvent('legendscave-jukebox:playTrack', {
        url = data.url,
        id = data.id,
        title = data.title,
        artist = data.artist,
        duration = data.duration,
        coords = coords,
    })
    cb({ ok = true })
end)

RegisterNUICallback('stopTrack', function(data, cb)
    local coords = data.coords or openCoords
    if not coords then
        cb({ ok = false })
        return
    end
    TriggerServerEvent('legendscave-jukebox:stopTrack', coords)
    cb({ ok = true })
end)

RegisterNUICallback('nextTrack', function(data, cb)
    local coords = data.coords or openCoords
    TriggerServerEvent('legendscave-jukebox:nextTrack', coords)
    cb({ ok = true })
end)

RegisterNUICallback('prevTrack', function(data, cb)
    local coords = data.coords or openCoords
    TriggerServerEvent('legendscave-jukebox:prevTrack', coords)
    cb({ ok = true })
end)

RegisterNetEvent('legendscave-jukebox:playTrack', function(payload)
    local coords = vectorFromPayload(payload.coords)
    local soundId = soundIdFromCoords(coords)
    local url = payload.url
    local title = payload.title or 'Unknown'
    local duration = payload.duration or 180

    if xSound:soundExists(soundId) then
        xSound:Destroy(soundId)
    end

    xSound:PlayUrlPos(soundId, url, Config.Volume, coords, false)
    xSound:Distance(soundId, Config.SoundDistance)

    activeProps[soundId] = {
        coords = coords,
        title = title,
        alpha = 0,
        fading = nil,
    }
    ensureDrawLoop()
    fadeIn(soundId)

    -- Only drive NUI progress if this client has the UI open on this prop
    if openCoords
        and math.abs(openCoords.x - payload.coords.x) < 0.05
        and math.abs(openCoords.y - payload.coords.y) < 0.05
        and math.abs(openCoords.z - payload.coords.z) < 0.05
    then
        SendNUIMessage({
            action = 'startProgress',
            duration = duration,
            title = title,
            artist = payload.artist,
        })
    end
end)

RegisterNetEvent('legendscave-jukebox:stopTrack', function(coordsPayloadIn)
    local coords = vectorFromPayload(coordsPayloadIn)
    local soundId = soundIdFromCoords(coords)

    if xSound:soundExists(soundId) then
        xSound:Destroy(soundId)
    end

    if activeProps[soundId] then
        fadeOutAndClear(soundId)
    end

    if openCoords
        and math.abs(openCoords.x - coordsPayloadIn.x) < 0.05
        and math.abs(openCoords.y - coordsPayloadIn.y) < 0.05
        and math.abs(openCoords.z - coordsPayloadIn.z) < 0.05
    then
        SendNUIMessage({ action = 'stopProgress' })
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    SetNuiFocus(false, false)
    for id in pairs(activeProps) do
        if xSound:soundExists(id) then
            xSound:Destroy(id)
        end
    end
    activeProps = {}
    pcall(function()
        exports.ox_target:removeModel(Config.MusicProps, 'legendscave_jukebox_open')
    end)
end)
