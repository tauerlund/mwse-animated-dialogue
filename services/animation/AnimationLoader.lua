local Logger = require("tauer.animated-dialogue.shared.Logger").Create("AnimationLoader")
local BipNodeService = require("tauer.animated-dialogue.services.nodes.BipNodeService")

---@class AnimationLoader
local this = {}

---@type { [string]: Animation }
this.cache = {}

---@public
---@param parameters LoadAnimationParameters
---@return Animation|nil
function this.Load(parameters)
    local cachedAnimation = this.tryGetCached(parameters.AnimationPath, parameters.SequenceName)
    if cachedAnimation then
        Logger:debug("Using cached animation")
        cachedAnimation.NonLooping = parameters.NonLooping
        return cachedAnimation
    end

    local loadedAnimation = this.load(parameters)
    if loadedAnimation then
        this.addToCache(loadedAnimation, parameters.SequenceName)
    end
    return loadedAnimation
end

---@private
---@param parameters LoadAnimationParameters
---@return Animation|nil
function this.load(parameters)
    Logger:debug("Loading new animation")
    local mesh = tes3.loadMesh(parameters.AnimationPath) --[[@as niNode]]

    local bipNode = mesh:getObjectByName("Bip01") --[[@as niNode]]
    local keyframeData = bipNode.extraData --[[@as niTextKeyExtraData]]
    if not keyframeData:isOfType(ni.type.NiTextKeyExtraData) then
        Logger:error("%s does not contain keyframe data!")
        return nil
    end

    local startKey, stopKey = this.getStartAndStopKeys(keyframeData, parameters.SequenceName)
    if not startKey then
        Logger:error("%s does not contain a start key for %s", parameters.AnimationPath, parameters.SequenceName)
        return nil
    end

    if not stopKey then
        Logger:error("%s does not contain a stop key for %s", parameters.AnimationPath, parameters.SequenceName)
        return nil
    end

    ---@type Animation
    return {
        StartTime = startKey.time,
        EndTime = stopKey.time,
        Path = parameters.AnimationPath,
        NodeKeyFrames = this.getKeyFrameData(mesh, startKey.time, stopKey.time),
        NonLooping = parameters.NonLooping
    }
end

---@private
---@param keyframeData niTextKeyExtraData
---@param sequenceName string
---@return niTextKey, niTextKey
function this.getStartAndStopKeys(keyframeData, sequenceName)
    local startKey = nil
    local stopKey = nil
    for _, key in pairs(keyframeData.keys) do
        if startKey and stopKey then
            break
        end
        if key.text:lower():trim() == string.format("%s: start", sequenceName):lower() then
            startKey = key
        end
        if key.text:lower():trim() == string.format("%s: stop", sequenceName):lower() then
            stopKey = key
        end
    end
    return startKey --[[@as niTextKey]], stopKey --[[@as niTextKey]]
end

---@private
---@param mesh niNode
---@param startTime number
---@param stopTime number
---@return { [string]: KeyFrames }
function this.getKeyFrameData(mesh, startTime, stopTime)
    ---@type { [string]: KeyFrames }
    local nodeKeyFrames = {}
    local bipNodes = BipNodeService.GetAllBipNodes(mesh, { IncludeParent = false })
    for _, node in pairs(bipNodes) do
        local controller = node.controller
        if controller and controller:isInstanceOfType(ni.type.NiKeyframeController) then
            local data = controller.data

            local rawPositionKeys = this.getKeysInTimeframe(data.positionKeys, startTime, stopTime)
            local positionKeyFrames = this.convertToKeyFrames(rawPositionKeys) --[[@as PositionKeyFrameData]]

            local rawRotationKeys = this.getKeysInTimeframe(data.rotationKeys, startTime, stopTime)
            local rotationKeyFrames = this.convertToKeyFrames(rawRotationKeys) --[[@as RotationFrameData]]

            local rawScaleKeys = this.getKeysInTimeframe(data.scaleKeys, startTime, stopTime)
            local scaleKeyFrames = this.convertToKeyFrames(rawScaleKeys) --[[@as ScaleKeyFrameData]]

            ---@type KeyFrames
            local keyFrames = {
                Position = positionKeyFrames,
                Rotation = rotationKeyFrames,
                Scale = scaleKeyFrames
            }
            nodeKeyFrames[node.name] = keyFrames
        end
    end
    return nodeKeyFrames
end

---@private
---@param originalKeys niAnimationKey[]
---@param startTime number
---@param stopTime number
function this.getKeysInTimeframe(originalKeys, startTime, stopTime)
    ---@type niAnimationKey[]
    local newKeys = {}
    for _, key in pairs(originalKeys) do
        if key.timing >= startTime and key.timing <= stopTime then
            table.insert(newKeys, key)
        end
    end
    return newKeys
end

---@private
---@param keys niAnimationKey[]
---@return KeyFrameData
function this.convertToKeyFrames(keys)
    ---@type KeyFrameLinkedList
    local head = nil
    -- Iterate over the table in reverse order to maintain the order in the list
    for i = #keys, 1, -1 do
        ---@type KeyFrameLinkedList
        local node = {
            Value = keys[i],
            Next = head,
        }
        -- Update the head to the new node
        head = node
    end

    ---@type KeyFrameData
    local keyframeData = {
        Origin = head,
        Key = head,
        NumberOfKeys = #keys
    }
    return keyframeData
end

---@private
---@param animationPath string
---@param sequenceName string
function this.tryGetCached(animationPath, sequenceName)
    return this.cache[string.format("%s-%s", animationPath, sequenceName)]
end

---@private
---@param animation Animation
---@param sequenceName string
function this.addToCache(animation, sequenceName)
    this.cache[string.format("%s-%s", animation.Path, sequenceName)] = animation
end

return this
