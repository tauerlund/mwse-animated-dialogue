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

    local presetsCategory = page:createCategory({
        label = translations.get(keys.presetsCategory)
    })

    local options = this.buildPresetOptions(services.cameraPresetLoader)

    presetsCategory:createDropdown({
        label = translations.get(keys.cameraPresetFirstPerson),
        description = translations.get(keys.cameraPresetFirstPersonDescription),
        options = options,
        variable = mwse.mcm.createTableVariable({
            id = "cameraPresetFirstPerson",
            table = services.settings
        }),
    })

    presetsCategory:createDropdown({
        label = translations.get(keys.cameraPresetThirdPerson),
        description = translations.get(keys.cameraPresetThirdPersonDescription),
        options = options,
        variable = mwse.mcm.createTableVariable({
            id = "cameraPresetThirdPerson",
            table = services.settings
        }),
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

---@private
---@param cameraPresetLoader cameraPresetLoader
---@return mwseMCMDropdownOption[]
function this.buildPresetOptions(cameraPresetLoader)
    local options = {}

    for _, id in ipairs(cameraPresetLoader.getIds()) do
        table.insert(options, {
            label = cameraPresetLoader.getPreset(id).name or id,
            value = id
        })
    end

    return options
end

return this
