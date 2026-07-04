---@class actorPage : mcmPage
local this = {}

---@public
---@param template mwseMCMTemplate
---@param services serviceCollection
function this.initialize(template, services)
    local translations = services.translations
    local keys = services.enums.translationKey

    local page = template:createSideBarPage({
        label = translations.get(keys.actorPage)
    })

    page:createOnOffButton({
        label = translations.get(keys.actorTurnEnabled),
        description = translations.get(keys.actorTurnEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorTurnEnabled",
            table = services.settings
        }),
    })

    page:createOnOffButton({
        label = translations.get(keys.actorAnimEnabled),
        description = translations.get(keys.actorAnimEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorAnimEnabled",
            table = services.settings
        }),
    })

    page:createOnOffButton({
        label = translations.get(keys.actorTalkAnimEnabled),
        description = translations.get(keys.actorTalkAnimEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorTalkAnimEnabled",
            table = services.settings
        }),
    })

    page:createOnOffButton({
        label = translations.get(keys.actorHeadMorphAnimEnabled),
        description = translations.get(keys.actorHeadMorphAnimEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorHeadMorphAnimEnabled",
            table = services.settings
        }),
    })

    page:createOnOffButton({
        label = translations.get(keys.actorHeadLookAtEnabled),
        description = translations.get(keys.actorHeadLookAtEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorHeadLookAtEnabled",
            table = services.settings
        }),
    })

    page:createOnOffButton({
        label = translations.get(keys.propsEnabled),
        description = translations.get(keys.propsEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "propsEnabled",
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

    timingCategory:createSlider({
        label = translations.get(keys.transitionDuration),
        description = translations.get(keys.transitionDurationDescription),
        variable = mwse.mcm.createTableVariable({
            id = "transitionDuration",
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
