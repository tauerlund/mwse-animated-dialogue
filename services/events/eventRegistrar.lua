---Provides abstractions for safely registering and unregistering multiple event handlers
---@class eventRegistrar : service
local this = {}

---@private
this.logger = mwse.Logger.new()

---Registers a collection of event handlers
---@public
---@param handlers eventHandlers The handlers to register
---@see event.register
---@see event.register.options
function this.register(handlers)
    for evt, entry in pairs(handlers) do
        for _, subEntry in ipairs(this.normalize(entry)) do
            this.registerSingle(evt, subEntry)
        end
    end
end

---@private
function this.registerSingle(evt, entry)
    local handler, options = this.resolveEntry(entry)
    if handler then
        if not event.isRegistered(evt, handler, options) then
            event.register(evt, handler, options)
        end
    end
end

---Unregisters a collection of event handlers
---@public
---@param handlers eventHandlers The handlers to unregister
---@see event.unregister
function this.unregister(handlers)
    for evt, entry in pairs(handlers) do
        for _, subEntry in ipairs(this.normalize(entry)) do
            this.unregisterSingle(evt, subEntry)
        end
    end
end

---@private
function this.unregisterSingle(evt, entry)
    local handler, options = this.resolveEntry(entry)
    if handler then
        if event.isRegistered(evt, handler, options) then
            event.unregister(evt, handler, options)
        end
    end
end

---Flattens an event entry into a list of sub-entries, each a callback or callbackWithOptions.
---Accepts a bare function, a single { handler, options } pair, or an array of
---{ handler, options } sub-entries ({ { fn1 }, { fn2, opts } }).
---@private
---@param entry callback|callbackWithOptions|callbackWithOptions[]
---@return (callback|callbackWithOptions)[]
function this.normalize(entry)
    if type(entry) ~= "table" then
        return { entry }
    end

    if type(entry[1]) == "table" then
        return entry
    end

    return { entry }
end

---@private
---@param entry callback|callbackWithOptions
---@return callback?, table?
function this.resolveEntry(entry)
    local entryType = type(entry)

    if entryType == "function" then
        return entry, nil
    elseif entryType == "table" then
        local handler = this.resolveType(entry[1], "function")
        local options = this.resolveType(entry[2], "table")

        return handler, options
    end

    this.logger:error("Invalid type '%s'", entryType)
end

---@generic T
---@private
---@param entry any
---@param expected `T`
---@return T|nil
function this.resolveType(entry, expected)
    if entry and type(entry) == expected then
        return entry
    end
    return nil
end

return this
