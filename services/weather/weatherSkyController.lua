---@class weatherSkyController : initializedService
local this = {}

-- UV units scrolled per second, per point of the weather's cloudsSpeed.
-- Matches OpenMW's cloud scroll (sky.cpp: `cloudDelta = duration * mCloudSpeed / 400`).
---@private
---@type number
this.scrollRate = 1 / 400

---@private
---@type settings
this.settings = nil

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type eventHandlerGroups
this.eventHandlers = {
    lifetime = {},
    dialogue = {}
}

---@private
---@type boolean
this.paused = false

---@private
---@type niTriShape[]
this.cloudShapes = {}

---@private
---@type number
this.cloudsSpeed = 0

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.settings = services.settings
    this.eventRegistrar = services.eventRegistrar

    local events = services.enums.events

    this.eventHandlers = {
        lifetime = {
            [events.dialogueStarted] = this.onDialogueStarted,
            [events.dialogueEnded] = this.onDialogueEnded,
        },
        dialogue = {
            [tes3.event.enterFrame] = this.onEnterFrame,
            [events.gamePaused] = this.onGamePaused,
            [events.gameUnpaused] = this.onGameUnpaused,
        },
    }

    this.eventRegistrar.register(this.eventHandlers.lifetime)

    return true, nil
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers.lifetime)
end

---@private
---@param node niNode?
function this.resolveCloudShapes(node)
    if not node then
        return
    end

    for shape in node:traverse({ type = ni.type.NiTriShape }) do
        this.cloudShapes[#this.cloudShapes + 1] = shape --[[@as niTriShape]]
    end
end

---@private
---@param _ dialogueStartedEventData
function this.onDialogueStarted(_)
    if not this.settings.cloudsEnabled then
        return
    end

    local weatherController = tes3.getWorldController().weatherController

    local cloudsNode = weatherController.sceneClouds
    if not cloudsNode then
        return
    end

    this.cloudShapes = {}
    this.resolveCloudShapes(cloudsNode)

    if #this.cloudShapes == 0 then
        return
    end

    this.cloudsSpeed = weatherController.currentWeather.cloudsSpeed
    this.paused = false

    this.eventRegistrar.register(this.eventHandlers.dialogue)
end

---@private
function this.onGamePaused()
    this.paused = true
end

---@private
function this.onGameUnpaused()
    this.paused = false
end

---@private
function this.onDialogueEnded()
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)

    this.cloudShapes = {}
    this.cloudsSpeed = 0
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    if this.paused then
        return
    end

    local step = this.cloudsSpeed * this.scrollRate * e.delta

    for i = 1, #this.cloudShapes do
        local data = this.cloudShapes[i].data
        if data then
            local coords = data.texCoords

            for j = 1, #coords do
                coords[j].y = coords[j].y + step
            end

            data:markAsChanged()
        end
    end
end

return this
