---@meta

--- The line a configuration is being filtered against, supplied only by callers
--- that have one. Rules keyed on the actor alone ignore it.
---@class dialogueLine
---@field public info tes3dialogueInfo Never read its `text` field — that re-raises infoGetText and stack-overflow-CTDs. Use `text` below.
---@field public text string The line text, forwarded safely by dialogueController. Empty for a debug-triggered line.
