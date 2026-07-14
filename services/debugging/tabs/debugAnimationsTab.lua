---@class debugAnimationsTab : debugTab
local this = {}

---@private
---@type guiBuilder
this.guiBuilder = nil

---@private
---@type translations
this.translations = nil

---@private
---@type translationKey
this.translationKey = nil

---@private
---@type debugSection[]
this.sections = nil

---@public
---@type string
this.title = nil

---@private
---@type tes3uiElement|nil
this.content = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.guiBuilder = services.guiBuilder
    this.translations = services.translations
    this.translationKey = services.enums.translationKey

    this.title = this.translations.get(this.translationKey.debugTabAnimations)

    this.sections = {
        services.previewAnimationSection,
        services.triggerOverrideSection,
        services.propTransformSection,
    }

    return true, nil
end

---@public
---@param params debugTab.build.param
function this.build(params)
    this.content = params.parent

    for _, section in ipairs(this.sections) do
        section.build({
            parent = this.createSectionBlock(),
            actor = params.actor,
        })
    end
end

---@public
function this.destroy()
    for _, section in ipairs(this.sections) do
        section.destroy()
    end

    this.content = nil
end

---@private
---@return tes3uiElement
function this.createSectionBlock()
    return this.guiBuilder.createBlock({ parent = this.content })
        :withFlowDirection(tes3.flowDirection.topToBottom)
        :withAutoSize()
        :withProportional({ width = 1.0 })
        :build()
end

return this
