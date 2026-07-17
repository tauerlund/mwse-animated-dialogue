---@class mcmInitializer : initializedService
local this = {}

--- @private
--- @type mcmPage[]
this.pages = {
	require("tauer.animated-dialogue.services.mcm.pages.generalPage"),
	require("tauer.animated-dialogue.services.mcm.pages.cameraPage"),
	require("tauer.animated-dialogue.services.mcm.pages.presetsPage"),
	require("tauer.animated-dialogue.services.mcm.pages.actorPage"),
	require("tauer.animated-dialogue.services.mcm.pages.actorBlacklistPage"),
	require("tauer.animated-dialogue.services.mcm.pages.playerPage"),
	require("tauer.animated-dialogue.services.mcm.pages.effectsPage"),
	require("tauer.animated-dialogue.services.mcm.pages.weatherPage"),
	require("tauer.animated-dialogue.services.mcm.pages.debuggingPage"),
}

---@private
---@type mcmSettings
this.mcmSettings = nil

---@private
---@type events
this.events = nil

---@private
this.headerImagePath = "textures\\tauer\\animated-dialogue\\header.tga"

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
	this.mcmSettings = services.mcmSettings
	this.events = services.constants.events

	local template = mwse.mcm.createTemplate({
		name = services.translations.get(services.constants.translationKey.modName),
		headerImagePath = this.headerImagePath,
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
