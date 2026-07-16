---@class values : service
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
---@param value any
---@return boolean
function this.isNonEmptyStringArray(value)
	if type(value) ~= "table" or #value == 0 then
		return false
	end

	for _, item in ipairs(value) do
		if type(item) ~= "string" then
			return false
		end
	end

	return true
end

---@public
---@param range conditionRange
---@param value number
---@return boolean withinRange
function this.withinRange(range, value)
	if range.min ~= nil and value < range.min then
		return false
	end

	if range.max ~= nil and value > range.max then
		return false
	end

	return true
end

---@public
---@param value any
---@return boolean
function this.isValidRange(value)
	if type(value) ~= "table" then
		return false
	end

	if value.min == nil and value.max == nil then
		return false
	end

	if value.min ~= nil and type(value.min) ~= "number" then
		return false
	end

	if value.max ~= nil and type(value.max) ~= "number" then
		return false
	end

	if value.min ~= nil and value.max ~= nil and value.min > value.max then
		return false
	end

	return true
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
