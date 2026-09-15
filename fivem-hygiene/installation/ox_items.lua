-- Add these inside ox_inventory/data/items.lua (inside the items table).
-- client.export must match fivem-hygiene client_exports.

	['hygiene_soap'] = {
		label = 'Aproko Soap',
		weight = 100,
		stack = true,
		close = true,
		consume = 1,
		description = 'Cleaner today, stronger tomorrow. Use at a shower to get clean.',
		client = {
			image = 'soap.png',
			export = 'fivem-hygiene.hygiene_soap',
		},
	},

	['hygiene_bodywash'] = {
		label = 'Aproko Body Wash',
		weight = 100,
		stack = true,
		close = true,
		consume = 1,
		description = 'Deep clean, feel better. Use at a shower to wash up.',
		client = {
			image = 'bodywash.png',
			export = 'fivem-hygiene.hygiene_bodywash',
		},
	},

	['hygiene_deodorant'] = {
		label = 'Aproko Deodorant',
		weight = 100,
		stack = true,
		close = true,
		consume = 1,
		description = 'Stay fresh through the day.',
		client = {
			image = 'deodorant.png',
			export = 'fivem-hygiene.hygiene_deodorant',
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
