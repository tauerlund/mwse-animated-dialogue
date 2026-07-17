---@class ruleLoader : initializedService
local this = {}

---@private
---@type fileLoader
this.fileLoader = nil

---@private
---@type serviceCollection
this.services = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
	this.services = services

	return true, nil
end

---@public
---@param directory string
---@return rule[] rules
function this.loadRules(directory)
	local services = this.services

	local fullPath = string.format("data files\\mwse\\mods\\tauer\\animated-dialogue\\%s", directory)

	local rules = {}

	local files = services.fileLoader.loadAll({
		directory = fullPath,
		fileType = ".lua",
		requireNotEmpty = true
	})

	if not files then
		return rules
	end

	for _, file in pairs(files) do
		local rule = this.loadRule(file, directory)
		if rule.initialize then
			rule.initialize(services)
		end
		table.insert(rules, rule)
	end

	return rules
end

---@private
---@param fileName string
---@param directory string
---@return rule
function this.loadRule(fileName, directory)
	local ruleName = fileName:gsub("%.lua$", "")
	local basePath = string.format("tauer.animated-dialogue.%s", directory:gsub("\\", "."))

	---@type rule
	local rule = require(string.format("%s.%s", basePath, ruleName))
	rule.name = ruleName

	return rule
end

return this
