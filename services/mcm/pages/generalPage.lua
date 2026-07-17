---@class generalPage : mcmPage
local this = {}

---@public
---@param template mwseMCMTemplate
---@param services serviceCollection
function this.initialize(template, services)
    local translations = services.translations
    local keys = services.constants.translationKey

    local page = template:createSideBarPage({
        label = translations.get(keys.generalPage)
    })

    page:createOnOffButton {
        label = translations.get(keys.modEnabled),
        description = translations.get(keys.modEnabledDescription),
        variable = mwse.mcm.createTableVariable { id = "enabled", table = services.settings }
    }

    page:createOnOffButton {
        label = translations.get(keys.disableInCombat),
        description = translations.get(keys.disableInCombatDescription),
        variable = mwse.mcm.createTableVariable { id = "disableInCombat", table = services.settings }
    }

    page:createOnOffButton {
        label = translations.get(keys.limitDialogueDistance),
        description = translations.get(keys.limitDialogueDistanceDescription),
        variable = mwse.mcm.createTableVariable { id = "limitDialogueDistance", table = services.settings }
    }

    page:createSlider {
        label = translations.get(keys.maxDialogueDistance),
        description = translations.get(keys.maxDialogueDistanceDescription),
        variable = mwse.mcm.createTableVariable { id = "maxDialogueDistance", table = services.settings },
        min = 256,
        max = 8192,
        step = 128,
        jump = 512,
    }

    page:createLogLevelOptions {
        config = services.settings,
        configKey = "logLevel",
    }
end

return this
