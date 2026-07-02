---@class arrays : service
local this = {}

---@public
---@param strings string[]
---@param value string
---@return boolean contains
function this.contains(strings, value)
	for _, v in ipairs(strings) do
		if v:lower() == value:lower() then
			return true
		end
	end
	return false
end

---@public
---@generic T
---@param items T[]
---@param weightSelector fun(item: T): number
---@return T?
function this.weightedChoice(items, weightSelector)
	local total = 0
	for _, item in ipairs(items) do
		total = total + math.max(0, weightSelector(item))
	end

	if total <= 0 then
		return (table.choice(items))
	end

	local roll = math.random() * total
	local last = nil
	for _, item in ipairs(items) do
		local weight = math.max(0, weightSelector(item))
		if weight > 0 then
			last = item
			roll = roll - weight
			if roll <= 0 then
				return item
			end
		end
	end

	return last
end

return this
