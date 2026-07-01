---@class debuggingPage : mcmPage
local this = {}

---@public
---@param template mwseMCMTemplate
---@param services serviceCollection
function this.initialize(template, services)
    local translations = services.translations
    local keys = services.enums.translationKey

    local page = template:createSideBarPage({
        label = translations.get(keys.debuggingPage)
    })

    page:createOnOffButton {
        label = translations.get(keys.debugModeEnabled),
        description = translations.get(keys.debugModeEnabledDescription),
        variable = mwse.mcm.createTableVariable { id = "debuggingEnabled", table = services.settings }
    }

    page:createKeyBinder {
        label = translations.get(keys.debugPauseKey),
        description = translations.get(keys.debugPauseKeyDescription),
        allowCombinations = true,
        variable = mwse.mcm.createTableVariable { id = "debugPauseKey", table = services.settings }
    }

    page:createKeyBinder {
        label = translations.get(keys.debugStepKey),
        description = translations.get(keys.debugStepKeyDescription),
        allowCombinations = true,
        variable = mwse.mcm.createTableVariable { id = "debugStepKey", table = services.settings }
    }
end

return this
