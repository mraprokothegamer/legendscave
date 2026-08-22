--[[
  Per-prop playlist state. Music is spatial on clients via xSound.
]]

local propState = {} -- [soundKey] = { index = n }

local function roundCoord(n)
    return math.floor(n * 100 + 0.5) / 100
end

local function soundKey(coords)
    return ('%.2f_%.2f_%.2f'):format(roundCoord(coords.x), roundCoord(coords.y), roundCoord(coords.z))
end

local function normalizeCoords(coords)
    if type(coords) ~= 'table' then return nil end
    if coords.x == nil or coords.y == nil or coords.z == nil then return nil end
    return {
        x = roundCoord(coords.x + 0.0),
        y = roundCoord(coords.y + 0.0),
        z = roundCoord(coords.z + 0.0),
    }
end

local function youtubeUrl(idOrUrl)
    if not idOrUrl or idOrUrl == '' then return nil end
    if idOrUrl:find('youtube%.com') or idOrUrl:find('youtu%.be') then
        return idOrUrl
    end
    -- strip accidental whitespace / query leftovers for bare ids
    local id = idOrUrl:match('([%w%-_]+)')
    if not id then return nil end
    return ('https://www.youtube.com/watch?v=%s'):format(id)
end

local function resolveTrack(data)
    if data and data.url and data.url ~= '' then
        local url = youtubeUrl(data.url)
        if not url then return nil end
        return {
            url = url,
            title = data.title or 'Custom Track',
            artist = data.artist or 'Unknown',
            duration = tonumber(data.duration) or 200,
        }
    end

    if data and data.id and data.id ~= '' then
        return {
            url = youtubeUrl(data.id),
            title = data.title or 'Track',
            artist = data.artist or 'Unknown',
            duration = tonumber(data.duration) or 200,
        }
    end

    local playlist = Config.Playlist
    if not playlist or #playlist == 0 then return nil end
    local track = playlist[1]
    return {
        url = youtubeUrl(track.id),
        title = track.title,
        artist = track.artist,
        duration = track.duration,
    }
end

local function broadcastPlay(coords, track)
    TriggerClientEvent('legendscave-jukebox:playTrack', -1, {
        url = track.url,
        title = track.title,
        artist = track.artist,
        duration = track.duration,
        coords = coords,
    })
end

RegisterNetEvent('legendscave-jukebox:playTrack', function(data)
    local coords = normalizeCoords(data and data.coords)
    if not coords then return end

    local track = resolveTrack(data)
    if not track or not track.url then return end

    local key = soundKey(coords)
    propState[key] = propState[key] or { index = 1 }

    -- If playing from playlist without explicit id/url, use stored index
    if (not data.url or data.url == '') and (not data.id or data.id == '') then
        local playlist = Config.Playlist
        local idx = propState[key].index
        local t = playlist[idx]
        if t then
            track = {
                url = youtubeUrl(t.id),
                title = t.title,
                artist = t.artist,
                duration = t.duration,
            }
        end
    end

    broadcastPlay(coords, track)
end)

RegisterNetEvent('legendscave-jukebox:stopTrack', function(coordsIn)
    local coords = normalizeCoords(coordsIn)
    if not coords then return end
    TriggerClientEvent('legendscave-jukebox:stopTrack', -1, coords)
end)

RegisterNetEvent('legendscave-jukebox:nextTrack', function(coordsIn)
    local coords = normalizeCoords(coordsIn)
    if not coords then return end

    local playlist = Config.Playlist
    if not playlist or #playlist == 0 then return end

    local key = soundKey(coords)
    local state = propState[key] or { index = 1 }
    state.index = (state.index % #playlist) + 1
    propState[key] = state

    local t = playlist[state.index]
    broadcastPlay(coords, {
        url = youtubeUrl(t.id),
        title = t.title,
        artist = t.artist,
        duration = t.duration,
    })
end)

RegisterNetEvent('legendscave-jukebox:prevTrack', function(coordsIn)
    local coords = normalizeCoords(coordsIn)
    if not coords then return end

    local playlist = Config.Playlist
    if not playlist or #playlist == 0 then return end

    local key = soundKey(coords)
    local state = propState[key] or { index = 1 }
    state.index = ((state.index - 2) % #playlist) + 1
    propState[key] = state

    local t = playlist[state.index]
    broadcastPlay(coords, {
        url = youtubeUrl(t.id),
        title = t.title,
        artist = t.artist,
        duration = t.duration,
    })
end)
