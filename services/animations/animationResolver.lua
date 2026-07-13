---@class animationResolver : initializedService
local this = {}

---@private
---@type animationFilterer
this.animationFilterer = nil

---@private
---@type arrays
this.arrays = nil

---@private
---@type baseAnimationConfiguration
this.configuration = nil

---@private
---@type baseAnimationConfiguration[]
this.baseConfigurations = nil

---@private
---@type { [string]: overrideAnimationConfiguration }
this.overrideConfigurations = nil

---@private
this.logger = mwse.Logger.new()

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.animationFilterer = services.animationFilterer
    this.arrays = services.arrays

    local animationLoader = services.animationLoader

    this.baseConfigurations = animationLoader.getBaseConfigurations()
    this.overrideConfigurations = animationLoader.getOverrideConfigurations()

    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.animationLoader }
end

---@public
---@param actor tes3reference
---@param preferredId string|nil
---@return baseAnimationConfiguration|nil
function this.resolveBase(actor, preferredId)
    local configuration = this.resolvePreferredConfiguration(preferredId)
        or this.resolveBaseConfiguration(actor)

    if not configuration or not configuration.idle then
        return nil
    end

    return configuration
end

---@public
---@param dialogueId string
---@return overrideAnimationConfiguration|nil
function this.resolveOverride(dialogueId)
    return this.overrideConfigurations[dialogueId]
end

--- An explicit pick bypasses the filtering rules - the conditions on a config
--- describe which actors suit it, and must not veto what the user chose for
--- themselves. Only a stale id falls back to the context-driven pick.
---@private
---@param preferredId string|nil
---@return baseAnimationConfiguration|nil
function this.resolvePreferredConfiguration(preferredId)
    if not preferredId or preferredId == "" then
        return nil
    end

    local configuration = this.findBaseConfiguration(preferredId)
    if not configuration then
        this.logger:warn("Preferred animation '%s' does not exist, resolving from context", preferredId)
        return nil
    end

    return configuration
end

---@private
---@param id string
---@return baseAnimationConfiguration|nil
function this.findBaseConfiguration(id)
    for i = 1, #this.baseConfigurations do
        if this.baseConfigurations[i].id == id then
            return this.baseConfigurations[i]
        end
    end

    return nil
end

---@private
---@param actor tes3reference
---@return baseAnimationConfiguration|nil
function this.resolveBaseConfiguration(actor)
    local filtered = this.animationFilterer.filter(this.baseConfigurations, actor)
    if #filtered == 0 then
        this.logger:error("Could not resolve base animation")
        return nil
    end

    return this.arrays.weightedChoice(filtered, this.resolveWeight)
end

---@private
---@param configuration baseAnimationConfiguration
---@return number
function this.resolveWeight(configuration)
    return configuration.weight or 1
end

return this
