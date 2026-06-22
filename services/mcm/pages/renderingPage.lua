---@class renderingPage : mcmPage
local this = {}

---@public
---@param template mwseMCMTemplate
---@param services serviceCollection
function this.initialize(template, services)
    local translations = services.translations
    local keys = services.enums.translationKey

    local page = template:createSideBarPage({
        label = translations.get(keys.renderingPage)
    })

    page:createOnOffButton({
        label = translations.get(keys.dofEnabled),
        description = translations.get(keys.dofEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "dofEnabled",
            table = services.settings
        }),
    })

    page:createSlider({
        label = translations.get(keys.dofStrength),
        description = translations.get(keys.dofStrengthDescription),
        variable = mwse.mcm.createTableVariable({
            id = "dofStrength",
            table = services.settings
        }),
        min = 1,
        max = 20,
        step = 1,
        jump = 5,
    })
end

return this
