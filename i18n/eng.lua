local keys = require("tauer.animated-dialogue.services.translations.constants.translationKey")

return {
    [keys.modName] = "Animated Dialogue",
    [keys.generalPage] = "General",
    [keys.modEnabled] = "Enabled",
    [keys.modEnabledDescription] = "Enables the mod.",
    [keys.disableInCombat] = "Disable During Combat",
    [keys.disableInCombatDescription] =
    "Disables dialogue animation when talking to an actor in combat.",
    [keys.limitDialogueDistance] = "Limit By Distance",
    [keys.limitDialogueDistanceDescription] =
    "Disables dialogue animation when the actor is not nearby.",
    [keys.maxDialogueDistance] = "Maximum Distance",
    [keys.maxDialogueDistanceDescription] =
    "The furthest an actor can be, in game units, for dialogue animation to trigger.",
    [keys.cameraPage] = "Camera",
    [keys.cameraEnabled] = "Enable Camera Animation",
    [keys.cameraEnabledDescription] = "Enables the camera animation during dialogue.",
    [keys.actorPage] = "Actors",
    [keys.actorAnimEnabled] = "Enable Actor Animations",
    [keys.actorAnimEnabledDescription] = "Enables actor body animations during dialogue.",
    [keys.actorNativeAnimEnabled] = "Preserve Custom NPC Animations",
    [keys.actorNativeAnimEnabledDescription] =
    "Keeps an NPC's own custom animation playing during dialogue instead of replacing it.",
    [keys.creatureAnimEnabled] = "Animate Creatures",
    [keys.creatureAnimEnabledDescription] =
    "Keeps creatures animating during dialogue instead of freezing them.",
    [keys.actorTalkAnimEnabled] = "Enable Actor Talk Animations",
    [keys.actorTalkAnimEnabledDescription] =
    "Enables talking gestures played while an actor responds.",
    [keys.actorTalkAnimChance] = "Talk Animation Chance",
    [keys.actorTalkAnimChanceDescription] =
    "The chance a talking gesture plays on a given response.",
    [keys.actorGreetingEnabled] = "Enable Greeting Animations",
    [keys.actorGreetingEnabledDescription] =
    "Enables a gesture played once as a conversation opens.",
    [keys.actorIdleVariationEnabled] = "Enable Idle Variations",
    [keys.actorIdleVariationEnabledDescription] =
    "Enables occasional idle variations played while an actor is idling between lines.",
    [keys.actorIdleVariationInterval] = "Idle Variation Interval",
    [keys.actorIdleVariationIntervalDescription] =
    "The average number of seconds an actor idles before playing a variation.",
    [keys.actorTurnEnabled] = "Enable Actor Turning",
    [keys.actorTurnEnabledDescription] = "Turns the actor to face the player when dialogue starts.",
    [keys.actorHeadMorphAnimEnabled] = "Enable Head Morph Animations",
    [keys.actorHeadMorphAnimEnabledDescription] =
    "Enables actor blinking and lip syncing during dialogue.",
    [keys.actorSimulatedVoiceEnabled] = "Simulate Voice",
    [keys.actorSimulatedVoiceEnabledDescription] =
    "Synthesizes mouth and head movement from the response text for lines that have no voiceover.",
    [keys.actorSimulatedVoiceSpeed] = "Simulate Voice: Speed",
    [keys.actorSimulatedVoiceSpeedDescription] =
    "Scales how quickly the simulated speech articulates.",
    [keys.actorSimulatedVoiceMaxDuration] = "Simulate Voice: Max Duration",
    [keys.actorSimulatedVoiceMaxDurationDescription] =
    "The longest a simulated line keeps animating, in seconds.",
    [keys.actorHeadLookAtModeFirstPerson] = "Head Look-At (First Person)",
    [keys.actorHeadLookAtModeFirstPersonDescription] =
    "What the actor's head looks at in first person.\n\nCamera: looks into the camera.\n\nPlayer: looks at the player's head.\n\nOff: left to the body animation.",
    [keys.actorHeadLookAtModeThirdPerson] = "Head Look-At (Third Person)",
    [keys.actorHeadLookAtModeThirdPersonDescription] =
    "What the actor's head looks at in third person.\n\nCamera: looks into the camera.\n\nPlayer: looks at the player's head.\n\nOff: left to the body animation.",
    [keys.actorHeadLookAtModeCamera] = "Camera",
    [keys.actorHeadLookAtModePlayer] = "Player",
    [keys.actorHeadLookAtModeOff] = "Off",
    [keys.actorHeadBobEnabled] = "Enable Head Bob",
    [keys.actorHeadBobEnabledDescription] =
    "Enables subtle procedural head movement while the actor is speaking.",
    [keys.actorHeadBobNodEnabled] = "Head Bob: Nodding",
    [keys.actorHeadBobNodEnabledDescription] =
    "Enables the up-and-down nodding component of the head bob.",
    [keys.actorHeadBobYawEnabled] = "Head Bob: Turning",
    [keys.actorHeadBobYawEnabledDescription] =
    "Enables the side-to-side turning component of the head bob.",
    [keys.actorHeadBobTiltEnabled] = "Head Bob: Tilting",
    [keys.actorHeadBobTiltEnabledDescription] =
    "Enables the tilting (roll) component of the head bob.",
    [keys.actorHeadBobAmount] = "Head Bob: Amount",
    [keys.actorHeadBobAmountDescription] =
    "Scales how far the head moves during the bob.",
    [keys.actorHeadBobSpeed] = "Head Bob: Speed",
    [keys.actorHeadBobSpeedDescription] =
    "Scales how quickly the head bobs.",
    [keys.actorHeadBobRandomness] = "Head Bob: Randomness",
    [keys.actorHeadBobRandomnessDescription] =
    "How much random wander is blended into the motion.",
    [keys.propsEnabled] = "Enable Props",
    [keys.propsEnabledDescription] =
    "Enables actors holding props during dialogue.",
    [keys.blacklistedActorsTitleLabel] = "Blacklist",
    [keys.blacklistedActorsDescription] =
    "Actors on the blacklist are excluded from this mod entirely.",
    [keys.blacklistedActorsLeftLabel] = "Blacklisted",
    [keys.blacklistedActorsRightLabel] = "Actors",
    [keys.playerPage] = "Player",
    [keys.playerPageDescription] =
    "Animates the player during dialogue. Third person only.",
    [keys.playerAnimEnabled] = "Enable Player Animations",
    [keys.playerAnimEnabledDescription] =
    "Animates the player's body during dialogue.",
    [keys.playerAnimation] = "Animation",
    [keys.playerAnimationDescription] =
    "Which animation the player's body plays during dialogue.",
    [keys.playerAnimationContextDriven] = "Context-driven",
    [keys.playerTurnEnabled] = "Enable Player Turning",
    [keys.playerTurnEnabledDescription] =
    "Turns the player to face the actor during dialogue.",
    [keys.playerHeadLookAtEnabled] = "Enable Head Look-At",
    [keys.playerHeadLookAtEnabledDescription] =
    "Turns the player's head to look at the actor during dialogue.",
    [keys.visibilityCategory] = "Visibility",
    [keys.hidePlayerMode] = "Hide Player",
    [keys.hidePlayerModeDescription] =
    "Hides the player's model while dialogue is open.\n\nFirst Person: hides the first-person hands when dialogue starts in first person.\n\nThird Person: hides the player's body when dialogue starts in third person.\n\nAlways: hides in both perspectives.\n\nNever: leaves the player visible.",
    [keys.hidePlayerModeFirstPerson] = "First Person",
    [keys.hidePlayerModeThirdPerson] = "Third Person",
    [keys.hidePlayerModeAlways] = "Always",
    [keys.hidePlayerModeNever] = "Never",
    [keys.presetsCategory] = "Presets",
    [keys.cameraPresetFirstPerson] = "First Person Preset",
    [keys.cameraPresetFirstPersonDescription] =
    "The camera preset used when dialogue starts in first person.",
    [keys.cameraPresetThirdPerson] = "Third Person Preset",
    [keys.cameraPresetThirdPersonDescription] =
    "The camera preset used when dialogue starts in third person.",
    [keys.presetsPage] = "Presets",
    [keys.presetEditTarget] = "Editing Preset",
    [keys.presetEditTargetDescription] =
    "Which preset the fields below edit.",
    [keys.presetName] = "Name",
    [keys.presetNameDescription] = "The display name shown for this preset.",
    [keys.presetAnchor] = "Anchor",
    [keys.presetAnchorDescription] =
    "Whose horizontal position the camera anchors to.",
    [keys.presetAnchorActor] = "Actor",
    [keys.presetAnchorPlayer] = "Player",
    [keys.presetVerticalAnchor] = "Vertical Anchor",
    [keys.presetVerticalAnchorDescription] =
    "The camera's height, blended between the player's eye level (0%) and the actor's head height (100%).",
    [keys.presetActionsCategory] = "Actions",
    [keys.presetSave] = "Save",
    [keys.presetSaveDescription] = "Writes the current preset's values to its file.",
    [keys.presetSaveConfirm] = "Save this preset to disk, overwriting its file?",
    [keys.presetClone] = "Clone",
    [keys.presetCloneDescription] = "Creates a copy of the current preset.",
    [keys.presetNew] = "New",
    [keys.presetNewDescription] = "Creates a new preset with default values.",
    [keys.presetDelete] = "Delete",
    [keys.presetDeleteDescription] = "Deletes the current preset's file.",
    [keys.presetDeleteConfirm] = "Delete this preset from disk? This cannot be undone.",
    [keys.presetDeleteLast] = "You cannot delete the last remaining preset.",
    [keys.presetNewName] = "New Preset",
    [keys.positionCategory] = "Position",
    [keys.rotationCategory] = "Rotation",
    [keys.timingCategory] = "Timing",
    [keys.bodyCategory] = "Body",
    [keys.headCategory] = "Head",
    [keys.headBobCategory] = "Head Bob",
    [keys.propsCategory] = "Props",
    [keys.distance] = "Distance",
    [keys.distanceDescription] =
    "The minimum distance the camera keeps from the actor's head.",
    [keys.horizontalOffset] = "Horizontal Offset",
    [keys.horizontalOffsetDescription] =
    "Shifts the camera left or right relative to the actor.",
    [keys.verticalOffset] = "Vertical Offset",
    [keys.verticalOffsetDescription] =
    "Shifts the camera up or down relative to the actor's head.",
    [keys.pitchOffset] = "Pitch",
    [keys.pitchOffsetDescription] =
    "Tilts the camera up or down.",
    [keys.yawOffset] = "Yaw",
    [keys.yawOffsetDescription] =
    "Rotates the camera left or right.",
    [keys.rollOffset] = "Roll",
    [keys.rollOffsetDescription] =
    "Rolls the camera around the look direction.",
    [keys.animationDuration] = "Duration",
    [keys.animationDurationDescription] = "How long the camera zoom takes, in seconds.",
    [keys.turnDuration] = "Turn Duration",
    [keys.turnDurationDescription] =
    "How long the actor takes to turn and face the player, in seconds.",
    [keys.transitionDuration] = "Transition Duration",
    [keys.transitionDurationDescription] =
    "How long the actor's body takes to ease into the dialogue animation, in seconds.",
    [keys.effectsPage] = "Effects",
    [keys.dofCategory] = "Depth of Field",
    [keys.dofEnabled] = "Enable Depth of Field",
    [keys.dofEnabledDescription] =
    "Applies a depth of field effect during dialogue.",
    [keys.dofStrength] = "Blur Strength",
    [keys.dofStrengthDescription] = "How strongly out-of-focus areas are blurred.",
    [keys.letterboxCategory] = "Letterbox",
    [keys.letterboxEnabled] = "Enable Letterbox",
    [keys.letterboxEnabledDescription] =
    "Eases cinematic black bars in at the top and bottom of the screen during dialogue.",
    [keys.hudCategory] = "HUD",
    [keys.hideHudEnabled] = "Hide HUD",
    [keys.hideHudEnabledDescription] =
    "Hides the heads-up display while dialogue is open.",
    [keys.fillLightCategory] = "Fill Light",
    [keys.fillLightMode] = "Fill Light",
    [keys.fillLightModeDescription] =
    "Adds a light on the actor you are talking to, so they stay visible in dark places.\n\nAlways: the fill light is always added.\n\nAdaptive: the fill light is skipped when you or the actor already carries a light.\n\nNever: no fill light.",
    [keys.fillLightModeAlways] = "Always",
    [keys.fillLightModeAdaptive] = "Adaptive",
    [keys.fillLightModeNever] = "Never",
    [keys.fillLightBrightness] = "Brightness",
    [keys.fillLightBrightnessDescription] =
    "How strongly the fill light lights the actor.",
    [keys.fillLightColor] = "Colour",
    [keys.fillLightColorDescription] =
    "The colour of the fill light. A warm off-white reads as firelight; pure white reads as neutral.",
    [keys.fillLightRadius] = "Radius",
    [keys.fillLightRadiusDescription] =
    "How far the fill light reaches, in game units. Larger values light the actor more evenly.",
    [keys.fillLightDistance] = "Distance",
    [keys.fillLightDistanceDescription] =
    "How far in front of the actor the light sits, in game units, measured towards the camera. Negative values place it behind them.",
    [keys.fillLightHeight] = "Height",
    [keys.fillLightHeightDescription] =
    "How far above the actor's head the light sits, in game units.",
    [keys.lightingParticlesCategory] = "Lighting & Particles",
    [keys.flickerEnabled] = "Enable Light Animation",
    [keys.flickerEnabledDescription] =
    "Keeps flickering and pulsing lights animating during dialogue.",
    [keys.particlesEnabled] = "Enable Particle Effects",
    [keys.particlesEnabledDescription] =
    "Keeps particle effects animating during dialogue.",
    [keys.effectsMode] = "Animation Mode",
    [keys.effectsModeDescription] =
    "Actor: animates just the actor's lights and particle effects.\n\nCurrent cell: animates all lights and particle effects in the current cell.\n\nActive cells: like Current cell, but also includes neighboring loaded cells.",
    [keys.effectsModeActor] = "Actor",
    [keys.effectsModeCurrentCell] = "Current cell",
    [keys.effectsModeActiveCells] = "Active cells",
    [keys.effectsCellDistance] = "Cell Distance",
    [keys.effectsCellDistanceDescription] =
    "In the cell modes, the maximum distance a light or particle effect may be from the actor to animate.",
    [keys.weatherPage] = "Weather",
    [keys.precipitationEnabled] = "Enable Precipitation",
    [keys.precipitationEnabledDescription] =
    "Keeps rain and snow falling during dialogue.",
    [keys.stormsEnabled] = "Enable Storms",
    [keys.stormsEnabledDescription] =
    "Keeps ash, blight, and blizzard storms swirling during dialogue.",
    [keys.cloudsEnabled] = "Enable Clouds",
    [keys.cloudsEnabledDescription] =
    "Keeps clouds drifting across the sky during dialogue.",
    [keys.swayCategory] = "Sway",
    [keys.swayEnabled] = "Enable Camera Sway",
    [keys.swayEnabledDescription] =
    "Adds a subtle oscillation to the camera during dialogue.",
    [keys.swayAmplitude] = "Amplitude",
    [keys.swayAmplitudeDescription] = "How far the camera sways, in degrees.",
    [keys.swayFrequency] = "Frequency",
    [keys.swayFrequencyDescription] =
    "How fast the camera sways, in cycles per second.",
    [keys.debuggingPage] = "Debugging",
    [keys.debugModeEnabled] = "Debugging Mode",
    [keys.debugModeEnabledDescription] =
    "Development tool. During dialogue, opens a status HUD and a tabbed debug window: an Animations tab to adopt a base configuration on the actor, preview its greeting/talk/variation clips, trigger overrides, and tune prop transforms, and a Camera tab to live-edit and save camera presets. Also enables the pause and step keys below, which freeze the scene so props can be tuned against a still pose.",
    [keys.debugPauseKey] = "Pause / Unpause Key",
    [keys.debugPauseKeyDescription] =
    "Freezes and unfreezes the dialogue scene. Only active during dialogue.",
    [keys.debugStepKey] = "Step Frame Key",
    [keys.debugStepKeyDescription] =
    "While paused, advances the scene by a single frame. Only active during dialogue.",
    [keys.debugHudTitle] = "Debugging Mode",
    [keys.debugHudPause] = "Pause / Unpause: %{key}",
    [keys.debugHudStep] = "Step Frame: %{key}",
    [keys.debugHudStatusRunning] = "Status: Running",
    [keys.debugHudStatusPaused] = "Status: Paused",
    [keys.debugWindowTitle] = "Animated Dialogue: Debug",
    [keys.debugTabAnimations] = "Animations",
    [keys.debugBaseConfiguration] = "Base Configuration",
    [keys.debugBaseConfigurationHint] =
    "Adopt a base config on this NPC for the rest of the dialogue, replacing the one that was rolled.",
    [keys.debugPreviewAnimation] = "Preview Animation",
    [keys.debugPreviewAnimationHint] = "Play a greeting, talk clip or variation from %{id}, one-shot, reverting to idle.",
    [keys.debugNoActiveConfiguration] =
    "No active base configuration. This actor isn't driven by a clip animation.",
    [keys.debugNoTalkAnimations] = "%{id} has no greeting, talk animations or variations.",
    [keys.debugTriggerOverride] = "Trigger Override",
    [keys.debugTriggerOverrideHint] = "Simulate a dialogue line: override clip + prop.",
    [keys.debugActorAnimDisabledHint] = "Actor animations are disabled in the MCM.",
    [keys.debugPropSection] = "Prop Transform",
    [keys.debugNoPropSpawned] =
    "No prop spawned. Trigger an override with a prop, or adopt a base configuration with one, to edit its transform.",
    [keys.debugTranslationSection] = "Translation",
    [keys.debugRotationSection] = "Rotation",
    [keys.debugScaleSection] = "Scale",
    [keys.debugReset] = "Reset",
    [keys.debugCopy] = "Copy",
    [keys.debugSaveTransform] = "Save Transform to %{source}",
    [keys.debugSaveTransformConfirm] =
    "Overwrite %{source} with the current prop transform? The whole file is rewritten.",
    [keys.debugSave] = "Save",
    [keys.debugTransformSaved] = "Saved prop transform to %{source}.",
    [keys.debugTabCamera] = "Camera",
    [keys.debugCameraPreset] = "Camera Preset",
    [keys.debugCameraDisabledHint] = "Camera animation is disabled in the MCM.",
    [keys.debugCameraNoPresetHint] =
    "The selected camera preset could not be found, so the camera is not animating. Pick an existing preset in the MCM.",
    [keys.debugReplay] = "Replay",
    [keys.debugSavePreset] = "Save Preset to %{id}.json",
    [keys.debugSavePresetConfirm] = "Overwrite %{id}.json with the current values?",
    [keys.debugPresetSaved] = "Saved preset to %{id}.json.",
    [keys.debugTabLighting] = "Lighting",
    [keys.debugFillLight] = "Fill Light",
    [keys.debugFillLightDisabledHint] = "The fill light is set to Never. Cycle the mode above to tune it.",
    [keys.debugFillLightSuppressedHint] =
    "Adaptive mode skipped the fill light for this dialogue, because you or the actor is carrying a light. Switch to Always to tune it here.",
    [keys.debugFillLightSection] = "Light",
    [keys.debugColorSection] = "Colour",
    [keys.debugPlacementSection] = "Placement",
    [keys.debugSaveSettings] = "Save Settings",
    [keys.debugSettingsSaved] = "Saved fill light settings.",
    [keys.validationFailed] = "Animated Dialogue: one or more configurations failed to load. Check mwse.log for details.",
    [keys.initializationFailed] = "Animated Dialogue failed to initialize and is disabled. Check mwse.log for details.",
    [keys.ok] = "OK",
}
