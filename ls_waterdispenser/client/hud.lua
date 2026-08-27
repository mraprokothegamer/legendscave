Hud = {}

-- 17mov_Hud (and most QB/Qbox HUDs) already listen to hud:client:UpdateNeeds.
-- Do NOT call UpdateComponentValue — many 17mov_Hud builds do not export it.

RegisterNetEvent('waterdispenser:client:syncNeeds', function(hunger, thirst)
    TriggerEvent('hud:client:UpdateNeeds', hunger, thirst)
end)

function Hud.syncNeeds(hunger, thirst)
    TriggerEvent('hud:client:UpdateNeeds', hunger, thirst)
end
