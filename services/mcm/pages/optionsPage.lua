---@class optionsPage : mcmPage
local this = {}

---@public
---@param template mwseMCMTemplate
---@param services serviceCollection
function this.initialize(template, services)
    local translations = services.translations
    local keys = services.enums.translationKey

    local page = template:createSideBarPage({
        label = translations.get(keys.modName)
    })

    local cameraCategory = page:createCategory({
        label = translations.get(keys.cameraCategory)
    })

    cameraCategory:createSlider({
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

    cameraCategory:createSlider({
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
end

return this
