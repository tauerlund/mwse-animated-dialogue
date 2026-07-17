local cameraAnchors = require("tauer.animated-dialogue.services.camera.presets.enums.cameraAnchors")
local ranges = require("tauer.animated-dialogue.services.camera.presets.enums.cameraPresetRanges")

---@class presetsPage : mcmPage
local this = {}

---@private
---@type mwseMCMTemplate
this.template = nil

---@private
---@type mwseMCMSideBarPage
this.page = nil

---@private
---@type cameraPresetLoader
this.loader = nil

---@private
---@type translations
this.translations = nil

---@private
---@type translationKey
this.keys = nil

---@private
---@type settings
this.settings = nil

---@private
---@type string
this.editingId = nil

---@private
---@type mwseMCMDropdown
this.editTargetDropdown = nil

---@private
---@type mwseMCMDropdown
this.anchorDropdown = nil

---@public
---@param template mwseMCMTemplate
---@param services serviceCollection
function this.initialize(template, services)
    this.template = template
    this.loader = services.cameraPresetLoader
    this.translations = services.translations
    this.keys = services.enums.translationKey
    this.settings = services.settings

    this.editingId = this.resolveInitialId()

    this.page = template:createSideBarPage({
        label = this.translations.get(this.keys.presetsPage)
    })

    this.build()
end

---@private
---@return string
function this.resolveInitialId()
    local preferred = this.settings.cameraPresetFirstPerson
    if this.loader.hasPreset(preferred) then
        return preferred
    end

    return this.loader.getIds()[1]
end

---@private
---@return cameraPreset|nil
function this.getCurrent()
    return this.loader.getPreset(this.editingId)
end

---@private
function this.build()
    local page = this.page
    local t = this.translations
    local keys = this.keys

    this.editTargetDropdown = page:createDropdown({
        label = t.get(keys.presetEditTarget),
        description = t.get(keys.presetEditTargetDescription),
        options = this.buildTargetOptions(),
        variable = mwse.mcm.createCustom({
            getter = function()
                return this.editingId
            end,
            setter = function(_, value)
                this.editingId = value
            end,
        }),
        callback = function()
            this.refresh()
        end,
    })

    page:createTextField({
        label = t.get(keys.presetName),
        description = t.get(keys.presetNameDescription),
        variable = this.fieldVariable("name"),
    })

    local positionCategory = page:createCategory({
        label = t.get(keys.positionCategory)
    })

    this.anchorDropdown = positionCategory:createDropdown({
        label = t.get(keys.presetAnchor),
        description = t.get(keys.presetAnchorDescription),
        options = {
            { label = t.get(keys.presetAnchorActor),  value = cameraAnchors.actor },
            { label = t.get(keys.presetAnchorPlayer), value = cameraAnchors.player },
        },
        variable = this.fieldVariable("anchor"),
    })

    positionCategory:createPercentageSlider({
        label = t.get(keys.presetVerticalAnchor),
        description = t.get(keys.presetVerticalAnchorDescription),
        variable = this.fieldVariable("verticalAnchor"),
        min = ranges.verticalAnchor.min,
        max = ranges.verticalAnchor.max,
        step = 0.01,
        jump = 0.1,
        decimalPlaces = 0,
    })

    positionCategory:createSlider({
        label = t.get(keys.distance),
        description = t.get(keys.distanceDescription),
        variable = this.fieldVariable("distance"),
        min = ranges.distance.min,
        max = ranges.distance.max,
        step = 1,
        jump = 10,
        decimalPlaces = 0,
    })

    positionCategory:createSlider({
        label = t.get(keys.horizontalOffset),
        description = t.get(keys.horizontalOffsetDescription),
        variable = this.fieldVariable("horizontalOffset"),
        min = ranges.horizontalOffset.min,
        max = ranges.horizontalOffset.max,
        step = 1,
        jump = 10,
        decimalPlaces = 0,
    })

    positionCategory:createSlider({
        label = t.get(keys.verticalOffset),
        description = t.get(keys.verticalOffsetDescription),
        variable = this.fieldVariable("verticalOffset"),
        min = ranges.verticalOffset.min,
        max = ranges.verticalOffset.max,
        step = 1,
        jump = 10,
        decimalPlaces = 0,
    })

    local rotationCategory = page:createCategory({
        label = t.get(keys.rotationCategory)
    })

    rotationCategory:createSlider({
        label = t.get(keys.pitchOffset),
        description = t.get(keys.pitchOffsetDescription),
        variable = this.fieldVariable("pitchOffset"),
        min = ranges.pitchOffset.min,
        max = ranges.pitchOffset.max,
        step = 1,
        jump = 5,
        decimalPlaces = 0,
    })

    rotationCategory:createSlider({
        label = t.get(keys.yawOffset),
        description = t.get(keys.yawOffsetDescription),
        variable = this.fieldVariable("yawOffset"),
        min = ranges.yawOffset.min,
        max = ranges.yawOffset.max,
        step = 1,
        jump = 5,
        decimalPlaces = 0,
    })

    rotationCategory:createSlider({
        label = t.get(keys.rollOffset),
        description = t.get(keys.rollOffsetDescription),
        variable = this.fieldVariable("rollOffset"),
        min = ranges.rollOffset.min,
        max = ranges.rollOffset.max,
        step = 1,
        jump = 5,
        decimalPlaces = 0,
    })

    local timingCategory = page:createCategory({
        label = t.get(keys.timingCategory)
    })

    timingCategory:createSlider({
        label = t.get(keys.animationDuration),
        description = t.get(keys.animationDurationDescription),
        variable = this.fieldVariable("animationDuration"),
        min = ranges.animationDuration.min,
        max = ranges.animationDuration.max,
        step = 0.1,
        jump = 0.5,
        decimalPlaces = 1,
    })

    local actionsCategory = page:createCategory({
        label = t.get(keys.presetActionsCategory)
    })

    actionsCategory:createButton({
        buttonText = t.get(keys.presetSave),
        description = t.get(keys.presetSaveDescription),
        callback = function()
            this.confirmSave()
        end,
    })

    actionsCategory:createButton({
        buttonText = t.get(keys.presetClone),
        description = t.get(keys.presetCloneDescription),
        callback = function()
            this.clone()
        end,
    })

    actionsCategory:createButton({
        buttonText = t.get(keys.presetNew),
        description = t.get(keys.presetNewDescription),
        callback = function()
            this.new()
        end,
    })

    actionsCategory:createButton({
        buttonText = t.get(keys.presetDelete),
        description = t.get(keys.presetDeleteDescription),
        callback = function()
            this.confirmDelete()
        end,
    })
end

---@private
---@param field string
---@return mwseMCMCustomVariable
function this.fieldVariable(field)
    return mwse.mcm.createCustom({
        getter = function()
            local preset = this.getCurrent()
            if not preset then
                return nil
            end

            return preset[field]
        end,
        setter = function(_, value)
            local preset = this.getCurrent()
            if not preset then
                return
            end

            preset[field] = value
        end,
    })
end

---@private
---@return mwseMCMDropdownOption[]
function this.buildTargetOptions()
    local options = {}

    for _, id in ipairs(this.loader.getIds()) do
        table.insert(options, {
            label = this.loader.getPreset(id).name or id,
            value = id
        })
    end

    return options
end

---@private
function this.refresh()
    this.editTargetDropdown.options = this.buildTargetOptions()
    this.editTargetDropdown.selectedOption = nil
    this.anchorDropdown.selectedOption = nil
    this.template:clickTab(this.page)
end

---@private
function this.confirmSave()
    tes3ui.showMessageMenu({
        message = this.translations.get(this.keys.presetSaveConfirm),
        cancels = true,
        leaveMenuMode = false,
        buttons = {
            {
                text = this.translations.get(this.keys.presetSave),
                callback = function()
                    local preset = this.getCurrent()
                    if not preset then
                        return
                    end

                    this.loader.savePreset(preset)
                end,
            },
        },
    })
end

---@private
function this.clone()
    local editing = this.getCurrent()
    if not editing then
        return
    end

    local id = this.loader.clonePreset(editing.id, string.format("%s Copy", editing.name))
    if not id then
        return
    end

    this.editingId = id
    this.refresh()
end

---@private
function this.new()
    this.editingId = this.loader.createPreset(this.translations.get(this.keys.presetNewName))
    this.refresh()
end

---@private
function this.confirmDelete()
    if #this.loader.getIds() <= 1 then
        tes3.messageBox(this.translations.get(this.keys.presetDeleteLast))
        return
    end

    tes3ui.showMessageMenu({
        message = this.translations.get(this.keys.presetDeleteConfirm),
        cancels = true,
        leaveMenuMode = false,
        buttons = {
            {
                text = this.translations.get(this.keys.presetDelete),
                callback = function()
                    this.loader.deletePreset(this.editingId)
                    this.editingId = this.loader.getIds()[1]
                    this.refresh()
                end,
            },
        },
    })
end

return this
