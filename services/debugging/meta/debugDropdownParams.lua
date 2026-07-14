---@meta
---@class debugDropdownEntry
---@field public label string

---@class debugDropdown.create.param
---@field public parent tes3uiElement
---@field public hint string|nil
---@field public entries debugDropdownEntry[]
---@field public onSelect fun(entry: debugDropdownEntry)
---@field public onHelp (fun(entry: debugDropdownEntry))|nil

---@class dropdown
---@field public entries debugDropdownEntry[]
---@field public header tes3uiElement
---@field public optionsBlock tes3uiElement
---@field public open boolean
---@field public onSelect fun(entry: debugDropdownEntry)
---@field public onHelp (fun(entry: debugDropdownEntry))|nil
