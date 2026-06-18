local Logger = require("tauer.animated-dialogue.shared.Logger").Create("CameraAnimator")
local EventManager = require("tauer.shared.events.EventManager")
local Events = require("tauer.animated-dialogue.shared.Events")
local Settings = require("tauer.animated-dialogue.shared.Settings")
local Constants = require("tauer.animated-dialogue.shared.Constants")

---@class CameraAnimator
local this = {}

---@enum AnimatorName
local AnimatorName = {
    Camera = "cameraAnimator",
    Sky = "skyAnimator"
}

---@private
---@type niNode
this.cameraAnimator = nil

---@private
---@type niNode
this.skyAnimator = nil

---@private
---@type tes3vector3
this.target = nil

---@private
---@type number
this.originalDistance = 0

---@private
---@type tes3vector3
this.originalCameraPosition = nil

---@private
---@type tes3vector3
this.originalAnimatorPosition = nil

---@private
---@type number
this.cameraSpeed = 800

---@private
---@type boolean
this.paused = false

---@public
function this.Initialize()
    local camera = this.getCamera()
    local sceneSky = this.getSceneSky()

    this.cameraAnimator = this.createAnimator(camera, AnimatorName.Camera)
    this.skyAnimator = this.createAnimator(sceneSky, AnimatorName.Sky)
end

---@public
function this.Stop()
    if this.cameraAnimator and this.originalAnimatorPosition then
        this.cameraAnimator.translation = this.originalAnimatorPosition
        this.cameraAnimator:update()
    end
    EventManager.Unregister(tes3.event.enterFrame, this.onEnterFrame)
    EventManager.Unregister(Events.CameraReachedTargetDistance, this.Stop)

    if tes3.mobilePlayer then
        tes3.mobilePlayer.controlsDisabled = false
        tes3.mobilePlayer.mouseLookDisabled = false
    end
end

---@public
---@param target tes3vector3
function this.Start(target)
    if tes3.mobilePlayer then
        tes3.mobilePlayer.controlsDisabled = true
        tes3.mobilePlayer.mouseLookDisabled = true
    end

    local cameraPosition = tes3.getCameraPosition()

    this.originalCameraPosition = cameraPosition:copy()
    this.originalAnimatorPosition = this.cameraAnimator.translation:copy()

    local offsetTarget = this.calculateOffsetTarget(target)

    this.target = offsetTarget
    this.originalDistance = this.cameraDistanceTo(offsetTarget)

    EventManager.Register(tes3.event.enterFrame, this.onEnterFrame)
    EventManager.Register(Events.CameraReachedTargetDistance, this.pause)

    this.resume()
end

function this.Reset()
    EventManager.Unregister(Events.CameraReachedTargetDistance, this.pause)
    -- EventManager.Register(CustomEvents.CameraReachedMinimumDistance, this.Stop)
    -- this.target = this.originalCameraPosition
    -- this.resume()
    this.Stop()
end

function this.resume()
    this.paused = false
end

function this.pause()
    this.paused = true
end

---@private
---@param e simulateEventData
function this.onEnterFrame(e)
    if this.paused then
        return
    end

    local targetDistance = 1

    local distance = this.cameraDistanceTo(this.target)
    if math.isclose(distance, targetDistance, 1) then
        Logger:info("Reached min distance")
        event.trigger(Events.CameraReachedTargetDistance)
    end

    local cameraPosition = this.cameraAnimator.translation
    local relativeTarget = this.relativeToCamera(this.cameraAnimator.translation + this.target)

    local direction = (relativeTarget - cameraPosition):normalized()

    local transition = math.remap(distance, targetDistance, this.originalDistance, 0, 1) * (this.cameraSpeed * e.delta)

    local newPosition = (cameraPosition):lerp(cameraPosition + direction, math.clamp(transition, 0, 1))

    this.cameraAnimator.translation = newPosition
    this.cameraAnimator:update()
end

---@private
---@param target tes3vector3
---@return tes3vector3
function this.calculateOffsetTarget(target)
    local cameraPosition = tes3.getCameraPosition()
    local direction = (this.originalCameraPosition - target)

    local length = direction:length()
    if length == 0 then
        return cameraPosition
    end

    local forward = direction / length

    local right = forward:cross(Constants.WorldUp):normalized()
    local up = right:cross(forward):normalized()

    local forwardDisplacement = forward * Settings.Mcm.CameraDistance
    local verticalDisplacement = up * Settings.Mcm.CameraVerticalOffset
    local horizontalDisplacement = right * -Settings.Mcm.CameraHorizontalOffset

    local offset = forwardDisplacement + verticalDisplacement + horizontalDisplacement

    return target + offset
end

---@private
---@param vector tes3vector3
---@return tes3vector3
function this.relativeToCamera(vector)
    local cameraPosition = tes3.getCameraPosition()
    return vector - cameraPosition
end

---@private
---@param vector tes3vector3
---@return number
function this.cameraDistanceTo(vector)
    local cameraPosition = tes3.getCameraPosition()
    return cameraPosition:distance(vector)
end

---@private
---@param target niNode
---@param name AnimatorName
---@return niNode
function this.createAnimator(target, name)
    local animator = target.parent
    if animator.name == name then
        return animator
    end
    animator = niNode.new()
    animator.name = name

    local parent = target.parent

    animator:attachChild(target, true)
    parent:attachChild(animator, true)

    animator:update()
    return animator
end

---@private
---@param target niNode
---@param animator niNode
function this.removeAnimator(target, animator)
   target.parent:detachChild(animator)
end

---@private
---@return niNode
function this.getCamera()
    return tes3.worldController.worldCamera.cameraRoot
end

---@private
---@return niNode
function this.getSceneSky()
    return tes3.worldController.weatherController.sceneSkyRoot
end

return this