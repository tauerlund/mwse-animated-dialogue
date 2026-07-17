---@meta
---@class overrideAnimationConfiguration
---@field public dialogueIds string[]
---@field public conditions? animationConditions
---@field public weight? number
---@field public animation animationDefinition
---@field public prop? propDefinition
---@field public source? string The JSON filename this was loaded from (set at load time, not authored).

--- An override configuration file is an array of these entries, so a single
--- JSON file can define more than one override.
---@alias overrideAnimationConfigurationFile overrideAnimationConfiguration[]

--- Either configuration kind, for the services that treat them uniformly
--- (the filtering rules, animationFilterer, and the weighted pick).
---@alias animationConfiguration baseAnimationConfiguration|overrideAnimationConfiguration
