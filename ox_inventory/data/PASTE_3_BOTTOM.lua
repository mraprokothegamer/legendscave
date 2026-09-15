-- PASTE 3 — file BOTTOM
-- The items table must already be closed with a single }.
-- Delete a leftover "})" or "}) end" first, then paste this AFTER that }.

for _, v in pairs(items) do
	if type(v) == 'table' and type(v.weight) == 'number' and v.weight < 500 then
		v.weight = 500
	end
end

return items
