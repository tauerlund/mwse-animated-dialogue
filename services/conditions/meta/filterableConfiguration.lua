---@meta

--- Anything the condition rules can filter: a configuration carrying an
--- optional condition block, a weight for the weighted pick, and whichever
--- discriminant its own kind uses to identify itself.
---@class filterableConfiguration
---@field public conditions? conditions
---@field public weight? number
---@field public id? string
---@field public source? string
