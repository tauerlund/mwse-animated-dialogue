---@class effectsPage : mcmPage
local this = {}

---@public
---@param template mwseMCMTemplate
---@param services serviceCollection
function this.initialize(template, services)
    local translations = services.translations
    local keys = services.enums.translationKey

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

    local lightingParticlesCategory = page:createCategory({
        label = translations.get(keys.lightingParticlesCategory)
    })

    lightingParticlesCategory:createOnOffButton({
        label = translations.get(keys.lightEnabled),
        description = translations.get(keys.lightEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "lightEnabled",
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

    local effectModes = services.enums.effectModes

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

return this
