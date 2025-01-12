---@meta

---@class Animation
---@field public StartTime number
---@field public EndTime number
---@field public Path string
---@field public NodeKeyFrames { [string]: KeyFrames }
---@field public NonLooping? boolean
---@field public NextAnimation? LoadAnimationParameters

---@class KeyFrames
---@field public Position PositionKeyFrameData
---@field public Rotation RotationFrameData
---@field public Scale ScaleKeyFrameData

---@class KeyFrameData
---@field Origin KeyFrameLinkedList
---@field Key KeyFrameLinkedList
---@field NumberOfKeys number

---@class PositionKeyFrameData : KeyFrameData
---@field Key PositionKey

---@class RotationFrameData : KeyFrameData
---@field Key RotationKey

---@class ScaleKeyFrameData : KeyFrameData
---@field Key ScaleKey

---@class KeyFrameLinkedList
---@field Value niAnimationKey
---@field Next KeyFrameLinkedList|nil

---@class PositionKey : KeyFrameLinkedList
---@field Value niPosKey
---@field Next PositionKey|nil

---@class RotationKey : KeyFrameLinkedList
---@field Value niRotKey
---@field Next RotationKey|nil

---@class ScaleKey : KeyFrameLinkedList
---@field Value niFloatKey
---@field Next ScaleKey|nil