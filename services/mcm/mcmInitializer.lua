---@class mcmInitializer : initializedService
local this = {}

--- @private
--- @type mcmPage[]
this.pages = {
	require("tauer.animated-dialogue.services.mcm.pages.optionsPage"),
}

---@private
--this.headerImagePath = "textures\\tauer\\modern-lockpicking\\logo.tga"

---@private
---@type mcmSettings
this.mcmSettings = nil

---@private
---@type events
this.events = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
	this.mcmSettings = services.mcmSettings
	this.events = services.enums.events

	local template = mwse.mcm.createTemplate({
		name = services.translations.get(services.enums.translationKey.modName),
		--headerImagePath = this.headerImagePath,
		onClose = this.onClose
	})

	for _, page in ipairs(this.pages) do
		page.initialize(template, services)
	end

	template:register()

	return true, nil
end

---@private
function this.onClose()
	this.mcmSettings.save()
	event.trigger(this.events.settingsUpdated)
end

return this
