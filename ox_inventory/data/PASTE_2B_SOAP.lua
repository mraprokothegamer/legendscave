-- PASTE 2B — replace ['hygiene_soap'] through the cut-off ['hygiene_bodywash']
-- Your bodywash item stopped at export = 'fivem-hygiene.hygiene_bodywash',
-- with no closing braces. Paste this whole block in that spot.

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
