---@meta
---@class bodyAnimator : actorAnimator
---@field handles fun(reference: tes3reference): boolean
---@field create fun(): bodyAnimator
---@field begin fun(self: bodyAnimator, reference: tes3reference)
---@field onDialogueInfo? fun(self: bodyAnimator, info: tes3dialogueInfo)
---@field overridesLookAt? fun(self: bodyAnimator): boolean
---@field play? fun(self: bodyAnimator, params: clipBodyAnimator.play.param)
---@field stop fun(self: bodyAnimator)
---@field suppressesTurn? boolean

--- Which strategies a participant will accept, keyed by the selector's gate name.
---@class bodyAnimatorGates
---@field creature boolean
---@field native boolean
---@field clip boolean

---@class bodyAnimatorStrategy
---@field gate string
---@field animator bodyAnimator
