---@class npcPage : mcmPage
local this = {}

---@public
---@param template mwseMCMTemplate
---@param services serviceCollection
function this.initialize(template, services)
    local translations = services.translations
    local keys = services.enums.translationKey

    local page = template:createSideBarPage({
        label = translations.get(keys.npcPage)
    })

    page:createOnOffButton({
        label = translations.get(keys.npcTurnEnabled),
        description = translations.get(keys.npcTurnEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "npcTurnEnabled",
            table = services.settings
        }),
    })

    page:createOnOffButton({
        label = translations.get(keys.npcAnimEnabled),
        description = translations.get(keys.npcAnimEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "npcAnimEnabled",
            table = services.settings
        }),
    })

    page:createOnOffButton({
        label = translations.get(keys.npcHeadAnimEnabled),
        description = translations.get(keys.npcHeadAnimEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "npcHeadAnimEnabled",
            table = services.settings
        }),
    })

    local timingCategory = page:createCategory({
        label = translations.get(keys.timingCategory)
    })

    timingCategory:createSlider({
        label = translations.get(keys.turnDuration),
        description = translations.get(keys.turnDurationDescription),
        variable = mwse.mcm.createTableVariable({
            id = "turnDuration",
            table = services.settings
        }),
        min = 0,
        max = 5,
        step = 0.1,
        jump = 0.5,
        decimalPlaces = 1,
    })
end

return this
