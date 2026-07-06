---@meta

---@class headBobWave
---@field public frequency1 number
---@field public frequency2 number
---@field public phase1 number
---@field public phase2 number

---@class headBobWander
---@field public from number
---@field public to number
---@field public value number
---@field public elapsed number
---@field public duration number

---@class headBobAxis
---@field public maxAngle number Peak offset in radians when motion and strength align.
---@field public frequency1 number Base wave frequency (rad/s); jittered per dialogue.
---@field public frequency2 number Base wave frequency (rad/s); jittered per dialogue.
---@field public wave? headBobWave This dialogue's jittered frequencies and random phases.
---@field public wander? headBobWander Slow random wander mixed in by the Randomness setting.

---@class headBobSpeech
---@field public activity number Eases 0..1 as talking starts/stops; the steady part of the strength.
---@field public loudness number Slow-smoothed lipsync level; accents the strength.
---@field public holdTimer number
---@field public isTalking boolean True while speaking or holding; bob time only advances then.

---@class headBobBasePose
---@field public tracked boolean
---@field public x number Bob-free euler the offsets ride on.
---@field public y number
---@field public z number
---@field public writtenX number Euler written last frame; if it still matches, no other animator moved the head.
---@field public writtenY number
---@field public writtenZ number
