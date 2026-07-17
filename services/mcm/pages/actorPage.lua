---@class actorPage : mcmPage
local this = {}

---@public
---@param template mwseMCMTemplate
---@param services serviceCollection
function this.initialize(template, services)
    local translations = services.translations
    local keys = services.constants.translationKey

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

    bodyCategory:createSlider({
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

    bodyCategory:createOnOffButton({
        label = translations.get(keys.actorAnimEnabled),
        description = translations.get(keys.actorAnimEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorAnimEnabled",
            table = services.settings
        }),
    })

    bodyCategory:createSlider({
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

    bodyCategory:createPercentageSlider({
        label = translations.get(keys.actorTalkAnimChance),
        description = translations.get(keys.actorTalkAnimChanceDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorTalkAnimChance",
            table = services.settings
        }),
        min = 0,
        max = 1,
        step = 0.01,
        jump = 0.1,
        decimalPlaces = 0,
    })

    bodyCategory:createOnOffButton({
        label = translations.get(keys.actorGreetingEnabled),
        description = translations.get(keys.actorGreetingEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorGreetingEnabled",
            table = services.settings
        }),
    })

    bodyCategory:createOnOffButton({
        label = translations.get(keys.actorIdleVariationEnabled),
        description = translations.get(keys.actorIdleVariationEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorIdleVariationEnabled",
            table = services.settings
        }),
    })

    bodyCategory:createSlider({
        label = translations.get(keys.actorIdleVariationInterval),
        description = translations.get(keys.actorIdleVariationIntervalDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorIdleVariationInterval",
            table = services.settings
        }),
        min = 3,
        max = 30,
        step = 1,
        jump = 5,
        decimalPlaces = 0,
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
        label = translations.get(keys.actorSimulatedVoiceEnabled),
        description = translations.get(keys.actorSimulatedVoiceEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorSimulatedVoiceEnabled",
            table = services.settings
        }),
    })

    headCategory:createSlider({
        label = translations.get(keys.actorSimulatedVoiceSpeed),
        description = translations.get(keys.actorSimulatedVoiceSpeedDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorSimulatedVoiceSpeed",
            table = services.settings
        }),
        min = 0.5,
        max = 5,
        step = 0.1,
        jump = 0.5,
        decimalPlaces = 1,
    })

    headCategory:createSlider({
        label = translations.get(keys.actorSimulatedVoiceMaxDuration),
        description = translations.get(keys.actorSimulatedVoiceMaxDurationDescription),
        variable = mwse.mcm.createTableVariable({
            id = "actorSimulatedVoiceMaxDuration",
            table = services.settings
        }),
        min = 1,
        max = 20,
        step = 1,
        jump = 5,
        decimalPlaces = 0,
    })

    local lookAtModes = services.constants.lookAtModes

    headCategory:createCycleButton({
        label = translations.get(keys.actorHeadLookAtModeFirstPerson),
        description = translations.get(keys.actorHeadLookAtModeFirstPersonDescription),
        options = {
            { text = translations.get(keys.actorHeadLookAtModeCamera), value = lookAtModes.camera },
            { text = translations.get(keys.actorHeadLookAtModePlayer), value = lookAtModes.player },
            { text = translations.get(keys.actorHeadLookAtModeOff),    value = lookAtModes.off },
        },
        variable = mwse.mcm.createTableVariable({
            id = "actorHeadLookAtModeFirstPerson",
            table = services.settings
        }),
    })

    headCategory:createCycleButton({
        label = translations.get(keys.actorHeadLookAtModeThirdPerson),
        description = translations.get(keys.actorHeadLookAtModeThirdPersonDescription),
        options = {
            { text = translations.get(keys.actorHeadLookAtModeCamera), value = lookAtModes.camera },
            { text = translations.get(keys.actorHeadLookAtModePlayer), value = lookAtModes.player },
            { text = translations.get(keys.actorHeadLookAtModeOff),    value = lookAtModes.off },
        },
        variable = mwse.mcm.createTableVariable({
            id = "actorHeadLookAtModeThirdPerson",
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
end

return this
