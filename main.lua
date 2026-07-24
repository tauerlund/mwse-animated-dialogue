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
		services.failureReporter,
		services.ruleLoader,
		services.eventLogger,
		services.cameraPresetValidator,
		services.cameraPresetLoader,
		services.cameraPresetResolver,
		services.conditionsValidator,
		services.conditionFilterer,
		services.animationConditionsValidator,
		services.animationDefinitionValidator,
		services.propDefinitionValidator,
		services.animationValidator,
		services.animationFilterer,
		services.animationLoader,
		services.animationResolver,
		services.voiceValidator,
		services.voiceLoader,
		services.voiceResolver,
		services.voiceController,
		services.dialogueController,
		services.dialogueCircuitBreaker,
		services.renderingController,
		services.playerController,
		services.hudController,
		services.actorController,
		services.actorTurnAnimator,
		services.actorTrackBinder,
		services.bodySkeletonTicker,
		services.creatureConfigValidator,
		services.creatureConfigLoader,
		services.creatureAnimationResolver,
		services.clipBodyAnimator,
		services.creatureBodyAnimator,
		services.overrideBodyAnimator,
		services.bodyAnimatorSelector,
		services.headMorphAnimator,
		services.headBobAnimator,
		services.lipsyncController,
		services.cameraController,
		services.cameraStartAnimator,
		services.cameraSwayAnimator,
		services.weatherPrecipitationController,
		services.weatherStormController,
		services.weatherSkyController,
		services.particleController,
		services.lightFlickerController,
		services.lightFillController,
		services.propSpawner,
		services.debugSliderSection,
		services.debugDropdown,
		services.debugSectionBuilder,
		services.debugTooltip,
		services.debugStatusHud,
		services.baseConfigurationSection,
		services.previewAnimationSection,
		services.triggerOverrideSection,
		services.propTransformSection,
		services.cameraPresetSection,
		services.fillLightSection,
		services.debugWindow,
		services.debugController,
	}

	this.initializer.initialize(services, initializedServices)
end

event.register(tes3.event.modConfigReady, this.initializeMcm)
event.register(tes3.event.initialized, this.initializeMod, { priority = 200 })
