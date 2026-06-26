---@class miscPage : mcmPage
local this = {}

---@public
---@param template mwseMCMTemplate
---@param services serviceCollection
function this.initialize(template, services)
    local translations = services.translations
    local keys = services.enums.translationKey

    local page = template:createSideBarPage({
        label = translations.get(keys.miscPage)
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
