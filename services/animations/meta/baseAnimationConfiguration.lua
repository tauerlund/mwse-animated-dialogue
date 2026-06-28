---@meta

---@class animationDefinition
---@field public file string
---@field public group string

---@class animationConditions
---@field public class string[]? Matches if the NPC's class is any of these; omit for any class.
---@field public sex ("male"|"female")? Matches the NPC's sex; omit for any sex.

---@class baseAnimationConfiguration
---@field public conditions animationConditions
---@field public idle animationDefinition
---@field public talk animationDefinition[]
