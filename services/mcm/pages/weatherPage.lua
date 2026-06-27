---@class weatherPage : mcmPage
local this = {}

---@public
---@param template mwseMCMTemplate
---@param services serviceCollection
function this.initialize(template, services)
    local translations = services.translations
    local keys = services.enums.translationKey

    local page = template:createSideBarPage({
        label = translations.get(keys.weatherPage)
    })

    page:createOnOffButton({
        label = translations.get(keys.precipitationEnabled),
        description = translations.get(keys.precipitationEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "precipitationEnabled",
            table = services.settings
        }),
    })

    page:createOnOffButton({
        label = translations.get(keys.stormsEnabled),
        description = translations.get(keys.stormsEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "stormsEnabled",
            table = services.settings
        }),
    })
end

return this
