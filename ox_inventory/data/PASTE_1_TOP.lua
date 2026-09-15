-- PASTE 1 — replace lines 1 through the police_helmet item
-- (through the closing }, after usePoliceHelmet).
-- Next line in your file should still be the following item.

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
