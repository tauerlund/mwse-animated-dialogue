---@class translations
local this = {}

---@private
---@type fun(key: string, data?: any):string
this.load = nil

---@public
---@param key string
---@param data? table Optional interpolation values, referenced as `%{name}` in the translation.
function this.get(key, data)
    if not this.load then
        this.load = mwse.loadTranslations("tauer.animated-dialogue")
    end

    return this.load(key, data)
end

return this
