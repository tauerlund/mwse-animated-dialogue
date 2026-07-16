---@class failureReporter : initializedService
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type eventHandlerGroups
this.eventHandlers = nil

---@private
---@type translations
this.translations = nil

---@private
---@type translationKey
this.translationKey = nil

---@private
---@type boolean
this.validationFailed = false

---@private
---@type boolean
this.initializationFailed = false

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.translations = services.translations
    this.translationKey = services.enums.translationKey
    this.validationFailed = false
    this.initializationFailed = false

    local events = services.enums.events

    this.eventHandlers = {
        lifetime = {
            [events.validationFailed] = this.onValidationFailed,
            [events.initializationFailed] = this.onInitializationFailed,
            [tes3.event.loaded] = { this.onLoaded, { doOnce = true } },
        }
    }

    this.eventRegistrar.register(this.eventHandlers.lifetime)

    return true, nil
end

---@private
function this.onValidationFailed()
    this.validationFailed = true
end

---@private
function this.onInitializationFailed()
    this.initializationFailed = true
end

---@private
---@param _ loadedEventData
function this.onLoaded(_)
    local key = this.resolveMessageKey()
    if not key then
        return
    end

    tes3.messageBox({
        message = this.translations.get(key),
        buttons = { this.translations.get(this.translationKey.ok) },
    })
end

---@private
---@return string|nil
function this.resolveMessageKey()
    if this.initializationFailed then
        return this.translationKey.initializationFailed
    end

    if this.validationFailed then
        return this.translationKey.validationFailed
    end

    return nil
end

return this
