-- Copy PASTE_1, PASTE_2, PASTE_3 into your live ox_inventory/data/items.lua.
-- This file is the same structure after those pastes (only the items we have).

local items = {
	['police_grappler'] = {
		label = 'Police Grappler',
		client = {
			export = 'legends-cave-police.useGrappler',
		},
	},

	['police_helmet'] = {
		label = 'Police Helmet',
		weight = 1800,
		stack = false,
		close = true,
		consume = 0,
		description = 'Department helmet with ballistic head protection.',
		client = {
			export = 'legends-police-helmet.usePoliceHelmet',
		},
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
	},
}

for _, v in pairs(items) do
	if type(v) == 'table' and type(v.weight) == 'number' and v.weight < 500 then
		v.weight = 500
	end
end

return items
