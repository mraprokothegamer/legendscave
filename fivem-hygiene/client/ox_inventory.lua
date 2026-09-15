--[[
    Registers ox_inventory client exports for Legends Hygiene items.
    Fixes: "No such export hygiene_bodywash in resource fivem-hygiene"
    Copy to: resources/[standalone]/fivem-hygiene/client/ox_inventory.lua
]]

local items = {
    hygiene_soap = 'Aproko Soap',
    hygiene_bodywash = 'Aproko Body Wash',
    hygiene_deodorant = 'Aproko Deodorant',
    hygiene_perfume = 'Aproko Perfume',
}

for exportName, label in pairs(items) do
    exports(exportName, function(data, slot)
        exports.ox_inventory:useItem(data, function(used)
            if not used then return end

            lib.notify({
                title = 'APROKO Hygiene',
                description = ('Used %s'):format(label),
                type = 'success',
            })

            TriggerServerEvent('fivem-hygiene:server:useItem', exportName)
        end)
    end)
end
