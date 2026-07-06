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

    local bodyCategory = page:createCategory({
        label = translations.get(keys.bodyCategory)
    })

    bodyCategory:createOnOffButton({
        label = translations.get(keys.actorTurnEnabled),
        description = translations.get(keys.actorTurnEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorTurnEnabled",
            table = services.settings
        }),
    })

    bodyCategory:createOnOffButton({
        label = translations.get(keys.actorAnimEnabled),
        description = translations.get(keys.actorAnimEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorAnimEnabled",
            table = services.settings
        }),
    })

    bodyCategory:createOnOffButton({
        label = translations.get(keys.actorNativeAnimEnabled),
        description = translations.get(keys.actorNativeAnimEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorNativeAnimEnabled",
            table = services.settings
        }),
    })

    bodyCategory:createOnOffButton({
        label = translations.get(keys.creatureAnimEnabled),
        description = translations.get(keys.creatureAnimEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "creatureAnimEnabled",
            table = services.settings
        }),
    })

    bodyCategory:createOnOffButton({
        label = translations.get(keys.actorTalkAnimEnabled),
        description = translations.get(keys.actorTalkAnimEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorTalkAnimEnabled",
            table = services.settings
        }),
    })

    local headCategory = page:createCategory({
        label = translations.get(keys.headCategory)
    })

    headCategory:createOnOffButton({
        label = translations.get(keys.actorHeadMorphAnimEnabled),
        description = translations.get(keys.actorHeadMorphAnimEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorHeadMorphAnimEnabled",
            table = services.settings
        }),
    })

    headCategory:createOnOffButton({
        label = translations.get(keys.actorHeadLookAtEnabled),
        description = translations.get(keys.actorHeadLookAtEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorHeadLookAtEnabled",
            table = services.settings
        }),
    })

    local headBobCategory = page:createCategory({
        label = translations.get(keys.headBobCategory)
    })

    headBobCategory:createOnOffButton({
        label = translations.get(keys.actorHeadBobEnabled),
        description = translations.get(keys.actorHeadBobEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorHeadBobEnabled",
            table = services.settings
        }),
    })

    headBobCategory:createOnOffButton({
        label = translations.get(keys.actorHeadBobNodEnabled),
        description = translations.get(keys.actorHeadBobNodEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorHeadBobNodEnabled",
            table = services.settings
        }),
    })

    headBobCategory:createOnOffButton({
        label = translations.get(keys.actorHeadBobYawEnabled),
        description = translations.get(keys.actorHeadBobYawEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorHeadBobYawEnabled",
            table = services.settings
        }),
    })

    headBobCategory:createOnOffButton({
        label = translations.get(keys.actorHeadBobTiltEnabled),
        description = translations.get(keys.actorHeadBobTiltEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorHeadBobTiltEnabled",
            table = services.settings
        }),
    })

    headBobCategory:createSlider({
        label = translations.get(keys.actorHeadBobAmount),
        description = translations.get(keys.actorHeadBobAmountDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorHeadBobAmount",
            table = services.settings
        }),
        min = 0,
        max = 3,
        step = 0.1,
        jump = 0.5,
        decimalPlaces = 1,
    })

    headBobCategory:createSlider({
        label = translations.get(keys.actorHeadBobSpeed),
        description = translations.get(keys.actorHeadBobSpeedDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorHeadBobSpeed",
            table = services.settings
        }),
        min = 0,
        max = 3,
        step = 0.1,
        jump = 0.5,
        decimalPlaces = 1,
    })

    headBobCategory:createSlider({
        label = translations.get(keys.actorHeadBobRandomness),
        description = translations.get(keys.actorHeadBobRandomnessDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorHeadBobRandomness",
            table = services.settings
        }),
        min = 0,
        max = 1,
        step = 0.1,
        jump = 0.2,
        decimalPlaces = 1,
    })

    local propsCategory = page:createCategory({
        label = translations.get(keys.propsCategory)
    })

    propsCategory:createOnOffButton({
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
