---@meta

---@class trackBinding
---@field public target niNode
---@field public controller niTimeController

---@class trackRestBone
---@field public target niNode
---@field public rotation tes3matrix33

---@class track
---@field public source niNode? The cloned animation mesh whose controllers were bound; held for the track's lifetime.
---@field public controllers trackBinding[]
---@field public count integer
---@field public rest trackRestBone[]
---@field public restCount integer
---@field public phase number
---@field public start number
---@field public stop number
---@field public looping boolean
