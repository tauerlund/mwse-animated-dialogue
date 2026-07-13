---@class playerPage : mcmPage
local this = {}

---@private
---@type animationLoader
this.animationLoader = nil

---@private
---@type translations
this.translations = nil

---@private
---@type translationKey
this.translationKey = nil

---@public
---@param template mwseMCMTemplate
---@param services serviceCollection
function this.initialize(template, services)
    this.animationLoader = services.animationLoader
    this.translations = services.translations
    this.translationKey = services.enums.translationKey

    local translations = services.translations
    local keys = services.enums.translationKey

    local page = template:createSideBarPage({
        label = translations.get(keys.playerPage),
        description = translations.get(keys.playerPageDescription)
    })

    local visibilityCategory = page:createCategory({
        label = translations.get(keys.visibilityCategory)
    })

    local hidePlayerModes = services.enums.hidePlayerModes

    visibilityCategory:createCycleButton({
        label = translations.get(keys.hidePlayerMode),
        description = translations.get(keys.hidePlayerModeDescription),
        options = {
            { text = translations.get(keys.hidePlayerModeFirstPerson), value = hidePlayerModes.firstPerson },
            { text = translations.get(keys.hidePlayerModeThirdPerson), value = hidePlayerModes.thirdPerson },
            { text = translations.get(keys.hidePlayerModeAlways),      value = hidePlayerModes.always },
            { text = translations.get(keys.hidePlayerModeNever),       value = hidePlayerModes.never },
        },
        variable = mwse.mcm.createTableVariable({
            id = "hidePlayerMode",
            table = services.settings
        }),
    })

    local bodyCategory = page:createCategory({
        label = translations.get(keys.bodyCategory)
    })

    bodyCategory:createOnOffButton({
        label = translations.get(keys.playerTurnEnabled),
        description = translations.get(keys.playerTurnEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "playerTurnEnabled",
            table = services.settings
        }),
    })

    bodyCategory:createOnOffButton({
        label = translations.get(keys.playerAnimEnabled),
        description = translations.get(keys.playerAnimEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "playerAnimEnabled",
            table = services.settings
        }),
    })

    bodyCategory:createDropdown({
        label = translations.get(keys.playerAnimation),
        description = translations.get(keys.playerAnimationDescription),
        options = this.buildAnimationOptions(),
        variable = mwse.mcm.createTableVariable({
            id = "playerAnimation",
            table = services.settings
        }),
        postCreate = this.refreshOptions,
    })

    local headCategory = page:createCategory({
        label = translations.get(keys.headCategory)
    })

    headCategory:createOnOffButton({
        label = translations.get(keys.playerHeadLookAtEnabled),
        description = translations.get(keys.playerHeadLookAtEnabledDescription),
        variable = mwse.mcm.createTableVariable({
            id = "playerHeadLookAtEnabled",
            table = services.settings
        }),
    })
end

---@private
---@param dropdown mwseMCMDropdown
function this.refreshOptions(dropdown)
    dropdown.options = this.buildAnimationOptions()
end

---@private
---@return mwseMCMDropdownOption[]
function this.buildAnimationOptions()
    local options = {
        {
            label = this.translations.get(this.translationKey.playerAnimationContextDriven),
            value = ""
        }
    }

    for _, configuration in ipairs(this.animationLoader.getBaseConfigurations()) do
        table.insert(options, {
            label = configuration.id,
            value = configuration.id
        })
    end

    return options
end

return this
