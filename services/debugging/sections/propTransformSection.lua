---@class propTransformSection : debugSection
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type events
this.events = nil

---@private
---@type settings
this.settings = nil

---@private
---@type guiBuilder
this.guiBuilder = nil

---@private
---@type debugSectionBuilder
this.debugSectionBuilder = nil

---@private
---@type debugSliderSection
this.debugSliderSection = nil

---@private
---@type animationLoader
this.animationLoader = nil

---@private
---@type translations
this.translations = nil

---@private
---@type translationKey
this.translationKey = nil

---@private
---@type tes3uiElement|nil
this.block = nil

---@private
---@type niNode
this.node = nil

---@private
---@type string|nil
this.dialogueId = nil

---@private
---@type eventHandlers
this.eventHandlers = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.events = services.enums.events
    this.settings = services.settings
    this.guiBuilder = services.guiBuilder
    this.debugSectionBuilder = services.debugSectionBuilder
    this.debugSliderSection = services.debugSliderSection
    this.animationLoader = services.animationLoader
    this.translations = services.translations
    this.translationKey = services.enums.translationKey

    this.eventHandlers = {
        [this.events.propSpawned] = this.onPropSpawned,
        [this.events.propDespawned] = this.onPropDespawned,
        [this.events.dialogueEnded] = this.onDialogueEnded,
    }

    this.eventRegistrar.register(this.eventHandlers)

    return true, nil
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers)
end

---@public
---@param params debugSection.build.param
function this.build(params)
    this.block = params.parent

    this.buildContent()
end

---@public
function this.destroy()
    this.block = nil
end

---@private
---@param e propSpawnedEventData
function this.onPropSpawned(e)
    if not this.settings.debuggingEnabled then
        return
    end

    this.node = e.node
    this.dialogueId = e.dialogueId
    this.rebuild()
end

---@private
function this.onPropDespawned()
    this.node = nil
    this.dialogueId = nil
    this.rebuild()
end

---@private
function this.onDialogueEnded()
    this.node = nil
    this.dialogueId = nil
end

---@private
function this.rebuild()
    if not this.block then
        return
    end

    this.block:destroyChildren()
    this.buildContent()
    this.block:getTopLevelMenu():updateLayout()
end

---@private
function this.buildContent()
    local section = this.debugSectionBuilder.create({
        parent = this.block,
        title = this.translations.get(this.translationKey.debugPropSection),
    })

    if not this.node then
        this.debugSectionBuilder.createHint({
            parent = section,
            text = this.translations.get(this.translationKey.debugNoPropSpawned),
        })

        return
    end

    this.buildTranslationSection(section)
    this.buildRotationSection(section)
    this.buildScaleSection(section)
    this.buildSaveButton(section)
end

---@private
---@param parent tes3uiElement
function this.buildTranslationSection(parent)
    local node = this.node
    local t = node.translation:copy()

    local function apply()
        node.translation = tes3vector3.new(t.x, t.y, t.z)
        node:update()
    end

    this.debugSliderSection.create({
        parent = parent,
        title = this.translations.get(this.translationKey.debugTranslationSection),
        onCopy = function()
            return string.format('{ "x": %.4f, "y": %.4f, "z": %.4f }', t.x, t.y, t.z)
        end,
        sliders = {
            {
                label = "X",
                min = -50,
                max = 50,
                step = 0.1,
                default = t.x,
                onChange = function(v)
                    t.x = v
                    apply()
                end
            },
            {
                label = "Y",
                min = -50,
                max = 50,
                step = 0.1,
                default = t.y,
                onChange = function(v)
                    t.y = v
                    apply()
                end
            },
            {
                label = "Z",
                min = -50,
                max = 50,
                step = 0.1,
                default = t.z,
                onChange = function(v)
                    t.z = v
                    apply()
                end
            },
        },
    })
end

---@private
---@param parent tes3uiElement
function this.buildRotationSection(parent)
    local node = this.node
    local euler = node.rotation:toEulerXYZ()
    local rx, ry, rz = euler.x, euler.y, euler.z

    local function apply()
        local m = tes3matrix33.new()
        m:fromEulerXYZ(rx, ry, rz)
        node.rotation = m
        node:update()
    end

    this.debugSliderSection.create({
        parent = parent,
        title = this.translations.get(this.translationKey.debugRotationSection),
        onCopy = function()
            return string.format('{ "x": %.4f, "y": %.4f, "z": %.4f }', rx, ry, rz)
        end,
        sliders = {
            {
                label = "X",
                min = -math.pi,
                max = math.pi,
                step = 0.01,
                default = rx,
                onChange = function(v)
                    rx = v
                    apply()
                end
            },
            {
                label = "Y",
                min = -math.pi,
                max = math.pi,
                step = 0.01,
                default = ry,
                onChange = function(v)
                    ry = v
                    apply()
                end
            },
            {
                label = "Z",
                min = -math.pi,
                max = math.pi,
                step = 0.01,
                default = rz,
                onChange = function(v)
                    rz = v
                    apply()
                end
            },
        },
    })
end

---@private
---@param parent tes3uiElement
function this.buildScaleSection(parent)
    local node = this.node

    this.debugSliderSection.create({
        parent = parent,
        title = this.translations.get(this.translationKey.debugScaleSection),
        onCopy = function()
            return string.format("%.4f", node.scale)
        end,
        sliders = {
            {
                label = "S",
                min = 0.01,
                max = 5,
                step = 0.01,
                default = node.scale,
                onChange = function(v)
                    node.scale = v
                    node:update()
                end
            },
        },
    })
end

---@private
---@param parent tes3uiElement
function this.buildSaveButton(parent)
    local configuration = this.resolveConfiguration()
    if not configuration then
        return
    end

    this.guiBuilder.createDivider({ parent = parent })
        :build()

    local button = this.guiBuilder.createButton({ parent = parent })
        :withText(this.translations.get(this.translationKey.debugSaveTransform, { source = configuration.source }))
        :build()

    button:registerBefore(tes3.uiEvent.mouseClick, this.confirmSaveTransform)
end

---@private
function this.confirmSaveTransform()
    local configuration = this.resolveConfiguration()
    if not configuration then
        return
    end

    tes3ui.showMessageMenu({
        message = this.translations.get(this.translationKey.debugSaveTransformConfirm, { source = configuration.source }),
        cancels = true,
        leaveMenuMode = false,
        buttons = {
            {
                text = this.translations.get(this.translationKey.debugSave),
                callback = this.saveTransform,
            },
        },
    })
end

---@private
function this.saveTransform()
    local configuration = this.resolveConfiguration()
    if not configuration then
        return
    end

    configuration.prop.transform = this.readTransform()

    if not this.animationLoader.saveOverrideConfiguration(configuration) then
        return
    end

    tes3.messageBox(this.translations.get(this.translationKey.debugTransformSaved, { source = configuration.source }))
end

---@private
---@return overrideAnimationConfiguration|nil
function this.resolveConfiguration()
    if not this.node or not this.dialogueId then
        return nil
    end

    local configuration = this.animationLoader.getOverrideConfigurations()[this.dialogueId]
    if not configuration or not configuration.prop then
        return nil
    end

    return configuration
end

---@private
---@return transformOverride
function this.readTransform()
    local node = this.node

    return {
        translation = this.readVector(node.translation),
        rotation = this.readVector(node.rotation:toEulerXYZ()),
        scale = this.round(node.scale),
    }
end

---@private
---@param vector tes3vector3
---@return { x: number, y: number, z: number }
function this.readVector(vector)
    return {
        x = this.round(vector.x),
        y = this.round(vector.y),
        z = this.round(vector.z),
    }
end

---@private
---@param value number
---@return number?
function this.round(value)
    return tonumber(string.format("%.4f", value))
end

return this
