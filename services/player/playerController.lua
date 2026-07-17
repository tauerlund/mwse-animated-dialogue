---@class playerController : initializedService
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type settings
this.settings = nil

---@private
---@type hidePlayerModes
this.hidePlayerModes = nil

---@private
this.eventHandlers = {
    lifetime = {}
}

---@private
---@type niNode|nil
this.hiddenNode = nil

---@private
---@type boolean
this.previousAppCulled = false

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.settings = services.settings
    this.hidePlayerModes = services.constants.hidePlayerModes

    local events = services.constants.events

    this.eventHandlers = {
        lifetime = {
            [events.dialogueStarted] = this.onDialogueStarted,
            [events.dialogueEnded] = this.onDialogueEnded,
        }
    }

    this.eventRegistrar.register(this.eventHandlers.lifetime)

    return true, nil
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers.lifetime)
end

---@private
function this.onDialogueStarted()
    if not this.shouldHidePlayer() then
        return
    end

    local node = this.resolvePlayerNode()

    if not node then
        return
    end

    this.hiddenNode = node
    this.previousAppCulled = node.appCulled
    node.appCulled = true
end

---@private
function this.onDialogueEnded()
    if not this.hiddenNode then
        return
    end

    this.hiddenNode.appCulled = this.previousAppCulled
    this.hiddenNode = nil
end

---@public
---@return boolean
function this.shouldHidePlayer()
    local mode = this.settings.hidePlayerMode
    local modes = this.hidePlayerModes

    if mode == modes.always then
        return true
    end

    if mode == modes.firstPerson then
        return not tes3.is3rdPerson()
    end

    if mode == modes.thirdPerson then
        return tes3.is3rdPerson()
    end

    return false
end

---@private
---@return niNode|nil
function this.resolvePlayerNode()
    local player = tes3.is3rdPerson() and tes3.player or tes3.player1stPerson

    return player and player.sceneNode or nil
end

return this
