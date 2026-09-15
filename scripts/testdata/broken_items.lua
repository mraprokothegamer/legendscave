do return (function(t)
    for k, v in pairs(t) do
        if type(v) == 'table' and v.weight and type(v.weight) == 'number' and v.weight < 500 then
            v.weight = 500
        end
    end
    return t
end)({
    ['police_grappler'] = {
        label = 'Police Grappler',
        client = {
            export = 'legends-cave-police.useGrappler'
        }
    },
    ['hygiene_perfume'] = {
        label = 'Aproko Perfume',
        weight = 100,
        stack = true,
        close = true,
        consume = 1,
        description = 'Fresher you. Premium scent that lasts longer than deodorant.',
        client = {
            image = 'perfume.png',
            export = 'fivem-hygiene.hygiene_perfume',
        },
    },
    ['facility_card'] = {
		label = 'Facility Access Card',
		weight = 10,
		stack = false,
		close = true,
		consume = 0,
		description = 'Access card for a personal storage unit. Use it to open your locker.',
		client = {
			image = 'facility_card.png',
			event = 'facility:client:useCard',
		},
		buttons = {
			{
				label = 'Open locker',
				action = function(slot)
					TriggerEvent('facility:client:useCard', slot)
				end,
			},
    ['water'] = {
        label = 'Water',
        weight = 200,
    },
})
end
