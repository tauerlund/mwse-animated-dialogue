---@meta

--- A per-creature idle override, keyed by the creature's baseObject id. Used
--- when the heuristic would pick the wrong idle among a creature's own idles.
---@class creatureAnimationConfiguration
---@field id string The creature's baseObject id (e.g. "dagoth_ur_1").
---@field group string A tes3.animationGroup key name to force (e.g. "idle3").
