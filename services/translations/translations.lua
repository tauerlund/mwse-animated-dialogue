---@class translations
local this = {}

---@private
---@type fun(key: string, data?: any):string
this.load = nil

---@public
---@param key string
function this.get(key)
    if not this.load then
        this.load = mwse.loadTranslations("tauer.animated-dialogue")
    end

    return this.load(key)
end

return this
