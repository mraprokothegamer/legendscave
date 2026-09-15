-- PASTE 2 — replace ['hygiene_perfume'] through the broken ['facility_card']
-- (stop before the next ['other_item'] = { ).
-- Keep this inside the items table. Do not paste after the final }.

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
