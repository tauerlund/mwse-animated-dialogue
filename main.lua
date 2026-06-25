---@class AnimatedDialogue
local this = {}

---@private
this.tests = require("tauer.animated-dialogue.tests")

---@private
this.services = require("tauer.animated-dialogue.services")

---@private
this.initializer = require("tauer.animated-dialogue.initializer")

---@package
---@param _ modConfigReadyEventData
function this.initializeMcm(_)
	this.services.mcmInitializer.initialize(this.services)
end

---@package
---@param _ initializedEventData
function this.initializeMod(_)
	if this.tests.enabled then
		this.tests.run()
	end

	local services = this.services

	---@type initializedService[]
	local initializedServices = {
		services.eventLogger,
		services.dialogueActivator,
		services.dialogueAnimationResolver,
		services.renderingController,
		services.npcController,
		services.npcTurnAnimator,
		services.npcControllersAnimator,
		services.npcHeadMorphAnimator,
		services.npcHeadLookAtAnimator,
		services.npcParticlesAnimator,
		services.cameraController,
		services.cameraStartAnimator,
		services.cameraSwayAnimator,
	}

	this.initializer.initialize(services, initializedServices)
end

event.register(tes3.event.modConfigReady, this.initializeMcm)
event.register(tes3.event.initialized, this.initializeMod)
