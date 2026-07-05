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
		services.ruleLoader,
		services.eventLogger,
		services.animationLoader,
		services.animationResolver,
		services.animationFilterer,
		services.dialogueController,
		services.renderingController,
		services.actorController,
		services.actorTurnAnimator,
		services.actorTrackBinder,
		services.creatureConfigLoader,
		services.creatureAnimationResolver,
		services.clipBodyAnimator,
		services.creatureBodyAnimator,
		services.overrideBodyAnimator,
		services.bodyAnimatorSelector,
		services.animationOrchestrator,
		services.actorHeadMorphAnimator,
		services.actorHeadLookAtAnimator,
		services.cameraController,
		services.cameraStartAnimator,
		services.cameraSwayAnimator,
		services.weatherPrecipitationController,
		services.weatherStormController,
		services.weatherSkyController,
		services.particleController,
		services.lightController,
		services.propSpawner,
		services.debuggingSliderPanel,
		services.debugController,
	}

	this.initializer.initialize(services, initializedServices)
end

event.register(tes3.event.modConfigReady, this.initializeMcm)
event.register(tes3.event.initialized, this.initializeMod)
