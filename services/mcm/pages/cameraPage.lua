---@class optionsPage : mcmPage
local this = {}

---@public
---@param template mwseMCMTemplate
---@param services serviceCollection
function this.initialize(template, services)
    local translations = services.translations
    local keys = services.enums.translationKey

    local page = template:createSideBarPage({
        label = translations.get(keys.cameraPage)
    })

    page:createOnOffButton({
        label = translations.get(keys.cameraEnabled),
        description = translations.get(keys.cameraEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "cameraEnabled",
            table = services.settings
        }),
    })

    local positionCategory = page:createCategory({
        label = translations.get(keys.positionCategory)
    })

    positionCategory:createSlider({
        label = translations.get(keys.distance),
        description = translations.get(keys.distanceDescription),
        variable = mwse.mcm.createTableVariable({
            id = "distance",
            table = services.settings
        }),
        min = 0,
        max = 500,
        step = 5,
        jump = 50,
    })

    positionCategory:createSlider({
        label = translations.get(keys.horizontalOffset),
        description = translations.get(keys.horizontalOffsetDescription),
        variable = mwse.mcm.createTableVariable({
            id = "horizontalOffset",
            table = services.settings
        }),
        min = -200,
        max = 200,
        step = 5,
        jump = 20,
    })

    positionCategory:createSlider({
        label = translations.get(keys.verticalOffset),
        description = translations.get(keys.verticalOffsetDescription),
        variable = mwse.mcm.createTableVariable({
            id = "verticalOffset",
            table = services.settings
        }),
        min = -200,
        max = 200,
        step = 5,
        jump = 20,
    })

    local rotationCategory = page:createCategory({
        label = translations.get(keys.rotationCategory)
    })

    rotationCategory:createSlider({
        label = translations.get(keys.pitchOffset),
        description = translations.get(keys.pitchOffsetDescription),
        variable = mwse.mcm.createTableVariable({
            id = "pitchOffset",
            table = services.settings
        }),
        min = -45,
        max = 45,
        step = 1,
        jump = 5,
    })

    rotationCategory:createSlider({
        label = translations.get(keys.yawOffset),
        description = translations.get(keys.yawOffsetDescription),
        variable = mwse.mcm.createTableVariable({
            id = "yawOffset",
            table = services.settings
        }),
        min = -45,
        max = 45,
        step = 1,
        jump = 5,
    })

    rotationCategory:createSlider({
        label = translations.get(keys.rollOffset),
        description = translations.get(keys.rollOffsetDescription),
        variable = mwse.mcm.createTableVariable({
            id = "rollOffset",
            table = services.settings
        }),
        min = -45,
        max = 45,
        step = 1,
        jump = 5,
    })

    local timingCategory = page:createCategory({
        label = translations.get(keys.timingCategory)
    })

    timingCategory:createSlider({
        label = translations.get(keys.animationDuration),
        description = translations.get(keys.animationDurationDescription),
        variable = mwse.mcm.createTableVariable({
            id = "animationDuration",
            table = services.settings
        }),
        min = 0,
        max = 5,
        step = 0.1,
        jump = 0.5,
        decimalPlaces = 1,
    })

    local swayCategory = page:createCategory({
        label = translations.get(keys.swayCategory)
    })

    swayCategory:createOnOffButton({
        label = translations.get(keys.swayEnabled),
        description = translations.get(keys.swayEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "swayEnabled",
            table = services.settings
        }),
    })

    swayCategory:createSlider({
        label = translations.get(keys.swayAmplitude),
        description = translations.get(keys.swayAmplitudeDescription),
        variable = mwse.mcm.createTableVariable({
            id = "swayAmplitude",
            table = services.settings
        }),
        min = 0,
        max = 3,
        step = 0.1,
        jump = 0.5,
        decimalPlaces = 1,
    })

    swayCategory:createSlider({
        label = translations.get(keys.swayFrequency),
        description = translations.get(keys.swayFrequencyDescription),
        variable = mwse.mcm.createTableVariable({
            id = "swayFrequency",
            table = services.settings
        }),
        min = 0.05,
        max = 1.0,
        step = 0.05,
        jump = 0.2,
        decimalPlaces = 2,
    })

end

return this
