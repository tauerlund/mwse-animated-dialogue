---@meta

---@class animationDefinition
---@field public file string
---@field public group string

---@class animationConditions
---@field public class string[]?
---@field public sex ("male"|"female")?
---@field public beast boolean?
---@field public torchCompatible boolean?
---@field public shieldCompatible boolean?

---@class baseAnimationConfiguration
---@field public id string
---@field public conditions animationConditions?
---@field public weight number?
---@field public idle animationDefinition
---@field public talk animationDefinition[]?
