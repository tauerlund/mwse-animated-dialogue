---@class effectsPage : mcmPage
local this = {}

---@public
---@param template mwseMCMTemplate
---@param services serviceCollection
function this.initialize(template, services)
    local translations = services.translations
    local keys = services.constants.translationKey

    local page = template:createSideBarPage({
        label = translations.get(keys.effectsPage)
    })

    local dofCategory = page:createCategory({
        label = translations.get(keys.dofCategory)
    })

    dofCategory:createOnOffButton({
        label = translations.get(keys.dofEnabled),
        description = translations.get(keys.dofEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "dofEnabled",
            table = services.settings
        }),
    })

    dofCategory:createSlider({
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

    local letterboxCategory = page:createCategory({
        label = translations.get(keys.letterboxCategory)
    })

    letterboxCategory:createOnOffButton({
        label = translations.get(keys.letterboxEnabled),
        description = translations.get(keys.letterboxEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "letterboxEnabled",
            table = services.settings
        }),
    })

    local hudCategory = page:createCategory({
        label = translations.get(keys.hudCategory)
    })

    hudCategory:createOnOffButton({
        label = translations.get(keys.hideHudEnabled),
        description = translations.get(keys.hideHudEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "hideHudEnabled",
            table = services.settings
        }),
    })

    this.createFillLightCategory(page, services)

    local lightingParticlesCategory = page:createCategory({
        label = translations.get(keys.lightingParticlesCategory)
    })

    lightingParticlesCategory:createOnOffButton({
        label = translations.get(keys.flickerEnabled),
        description = translations.get(keys.flickerEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "flickerEnabled",
            table = services.settings
        }),
    })

    lightingParticlesCategory:createOnOffButton({
        label = translations.get(keys.particlesEnabled),
        description = translations.get(keys.particlesEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "particlesEnabled",
            table = services.settings
        }),
    })

    local effectModes = services.constants.effectModes

    lightingParticlesCategory:createCycleButton({
        label = translations.get(keys.effectsMode),
        description = translations.get(keys.effectsModeDescription),
        options = {
            { text = translations.get(keys.effectsModeActor),       value = effectModes.actor },
            { text = translations.get(keys.effectsModeCurrentCell), value = effectModes.currentCell },
            { text = translations.get(keys.effectsModeActiveCells), value = effectModes.activeCells },
        },
        variable = mwse.mcm.createTableVariable({
            id = "effectsMode",
            table = services.settings
        }),
    })

    lightingParticlesCategory:createSlider({
        label = translations.get(keys.effectsCellDistance),
        description = translations.get(keys.effectsCellDistanceDescription),
        variable = mwse.mcm.createTableVariable({
            id = "effectsCellDistance",
            table = services.settings
        }),
        min = 256,
        max = 8192,
        step = 128,
        jump = 512,
    })
end

---@private
---@param page mwseMCMSideBarPage
---@param services serviceCollection
function this.createFillLightCategory(page, services)
    local translations = services.translations
    local keys = services.constants.translationKey
    local ranges = services.constants.fillLightRanges
    local fillLightModes = services.constants.fillLightModes

    local category = page:createCategory({
        label = translations.get(keys.fillLightCategory)
    })

    category:createCycleButton({
        label = translations.get(keys.fillLightMode),
        description = translations.get(keys.fillLightModeDescription),
        options = {
            { text = translations.get(keys.fillLightModeAlways),   value = fillLightModes.always },
            { text = translations.get(keys.fillLightModeAdaptive), value = fillLightModes.adaptive },
            { text = translations.get(keys.fillLightModeNever),    value = fillLightModes.never },
        },
        variable = mwse.mcm.createTableVariable({
            id = "fillLightMode",
            table = services.settings
        }),
    })

    category:createPercentageSlider({
        label = translations.get(keys.fillLightBrightness),
        description = translations.get(keys.fillLightBrightnessDescription),
        variable = mwse.mcm.createTableVariable({
            id = "fillLightBrightness",
            table = services.settings
        }),
        min = ranges.fillLightBrightness.min,
        max = ranges.fillLightBrightness.max,
        step = 0.01,
        jump = 0.1,
        decimalPlaces = 0,
    })

    category:createColorPickerButton({
        label = translations.get(keys.fillLightColor),
        description = translations.get(keys.fillLightColorDescription),
        variable = mwse.mcm.createTableVariable({
            id = "fillLightColor",
            table = services.settings
        }),
    })

    category:createSlider({
        label = translations.get(keys.fillLightRadius),
        description = translations.get(keys.fillLightRadiusDescription),
        variable = mwse.mcm.createTableVariable({
            id = "fillLightRadius",
            table = services.settings
        }),
        min = ranges.fillLightRadius.min,
        max = ranges.fillLightRadius.max,
        step = 16,
        jump = 64,
    })

    category:createSlider({
        label = translations.get(keys.fillLightDistance),
        description = translations.get(keys.fillLightDistanceDescription),
        variable = mwse.mcm.createTableVariable({
            id = "fillLightDistance",
            table = services.settings
        }),
        min = ranges.fillLightDistance.min,
        max = ranges.fillLightDistance.max,
        step = 1,
        jump = 10,
    })

    category:createSlider({
        label = translations.get(keys.fillLightHeight),
        description = translations.get(keys.fillLightHeightDescription),
        variable = mwse.mcm.createTableVariable({
            id = "fillLightHeight",
            table = services.settings
        }),
        min = ranges.fillLightHeight.min,
        max = ranges.fillLightHeight.max,
        step = 1,
        jump = 10,
    })
end

return this
