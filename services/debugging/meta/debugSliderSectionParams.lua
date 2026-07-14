---@meta
---@class debugSliderDefinition
---@field public label string
---@field public min number
---@field public max number
---@field public step number
---@field public default number
---@field public onChange fun(value: number)

---@class debugSliderRow
---@field public slider tes3uiElement
---@field public valueLabel tes3uiElement
---@field public defaultStep integer
---@field public definition debugSliderDefinition

---@class debugSliderSection.create.param
---@field public parent tes3uiElement
---@field public title string
---@field public sliders debugSliderDefinition[]
---@field public onCopy (fun(): string)|nil
