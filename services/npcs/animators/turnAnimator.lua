---@class npcTurnAnimator : initializedService, npcAnimator
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type settings
this.settings = nil

---@private
---@type tes3reference
this.npc = nil

---@private
---@type number
this.originalYaw = nil

---@private
---@type number
this.targetYaw = nil

---@private
---@type number
this.turnTime = 0

---@private
this.eventHandlers = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.settings       = services.settings

    local events        = services.enums.events
    this.eventHandlers  = {
        [events.dialogueStarted] = this.onDialogueStarted,
        [events.dialogueEnded]   = this.onDialogueEnded,
    }

    this.eventRegistrar.register(this.eventHandlers)

    return true, nil
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers)
end

---@private
---@param event dialogueStartedEventData
function this.onDialogueStarted(event)
    this.npc             = event.npc
    this.turnTime        = 0
    this.originalYaw     = event.npc.orientation.z

    local playerPosition = tes3.player.position
    local deltaX         = playerPosition.x - event.npc.position.x
    local deltaY         = playerPosition.y - event.npc.position.y

    this.targetYaw       = math.atan2(deltaX, deltaY)
end

---@private
function this.onDialogueEnded()
    this.npc         = nil
    this.originalYaw = nil
    this.targetYaw   = nil
end

---@public
---@param delta number
function this.update(delta)
    local duration       = this.settings.turnDuration
    this.turnTime        = math.min(this.turnTime + delta, duration)

    local progress       = math.ease.smoothstep(this.turnTime / duration)
    local yaw            = this.lerpAngle(this.originalYaw, this.targetYaw, progress)
    local orientation    = this.npc.orientation:copy()

    orientation.z        = yaw
    this.npc.orientation = orientation
end

---@private
---@param fromAngle number
---@param toAngle number
---@param progress number
---@return number
function this.lerpAngle(fromAngle, toAngle, progress)
    local diff = toAngle - fromAngle
    if diff > math.pi then
        diff = diff - 2 * math.pi
    end
    if diff < -math.pi then
        diff = diff + 2 * math.pi
    end
    return fromAngle + diff * progress
end

return this
