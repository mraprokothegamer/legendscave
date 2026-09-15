--[[
    Registers ox_inventory client exports for Legends Hygiene items.
    Export names come from Config.Items (must match ox_inventory item IDs).
    Copy to: resources/[standalone]/fivem-hygiene/client/ox_inventory.lua
]]

for _, exportName in pairs(Config.Items) do
    local label = Config.Labels[exportName] or exportName

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
