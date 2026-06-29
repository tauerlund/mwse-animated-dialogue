---@meta

---@class animationDefinition
---@field public file string
---@field public group string

---@class animationConditions
---@field public class string[]? Matches if the NPC's class is any of these; omit for any class.
---@field public sex ("male"|"female")? Matches the NPC's sex; omit for any sex.
---@field public beast boolean

---@class baseAnimationConfiguration
---@field public conditions animationConditions?
---@field public torchCompatible boolean?
---@field public shieldCompatible boolean?
---@field public idle animationDefinition
---@field public talk animationDefinition[]?
