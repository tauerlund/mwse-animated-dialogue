local keys = require("tauer.animated-dialogue.services.translations.constants.translationKey")

return {
    [keys.modName] = "Animated Dialogue",
    [keys.generalPage] = "General",
    [keys.modEnabled] = "Enabled",
    [keys.modEnabledDescription] = "Enable or disable the Animated Dialogue mod.",
    [keys.disableInCombat] = "Disable During Combat",
    [keys.disableInCombatDescription] =
    "Disables all dialogue animation when talking to an actor that is in combat, so fighting actors are not pulled into cinematic framing.",
    [keys.limitDialogueDistance] = "Limit By Distance",
    [keys.limitDialogueDistanceDescription] =
    "Disables all dialogue animation when the actor is not nearby, so remote conversations (e.g. telepathy rings) do not trigger cinematic framing on an actor you cannot see.",
    [keys.maxDialogueDistance] = "Maximum Distance",
    [keys.maxDialogueDistanceDescription] =
    "The furthest an actor can be, in game units, for dialogue animation to trigger when Limit By Distance is enabled. Normal face-to-face conversation is well within this range.",
    [keys.cameraPage] = "Camera",
    [keys.cameraEnabled] = "Enable Camera Animation",
    [keys.cameraEnabledDescription] = "Enables or disables the camera animation during dialogue.",
    [keys.actorPage] = "Actors",
    [keys.actorAnimEnabled] = "Enable Actor Animations",
    [keys.actorAnimEnabledDescription] = "Enables or disables actor body animations during dialogue.",
    [keys.actorNativeAnimEnabled] = "Preserve Custom NPC Animations",
    [keys.actorNativeAnimEnabledDescription] =
    "For NPCs that already play their own custom animation (such as the performers added by Animated Morrowind), keeps that animation playing during dialogue instead of applying this mod's animations.",
    [keys.creatureAnimEnabled] = "Animate Creatures",
    [keys.creatureAnimEnabledDescription] =
    "Keeps creatures animating during dialogue by playing a neutral idle, instead of freezing them. Creatures use their own animations; this mod's NPC body animations do not apply to them.",
    [keys.actorTalkAnimEnabled] = "Enable Actor Talk Animations",
    [keys.actorTalkAnimEnabledDescription] =
    "Enables or disables actor talking gesture animations played while responding during dialogue. Requires actor animations to be enabled.",
    [keys.actorTalkAnimChance] = "Talk Animation Chance",
    [keys.actorTalkAnimChanceDescription] =
    "The chance that a talking gesture plays on any given response, so actors do not gesture on every single line. Animations configured for a specific dialogue topic always play and ignore this setting.",
    [keys.actorGreetingEnabled] = "Enable Greeting Animations",
    [keys.actorGreetingEnabledDescription] =
    "Enables a gesture played once as a conversation opens, in response to the actor's greeting (a bow, a salute, a wave). Requires actor animations to be enabled, and only affects actors whose animation set defines a greeting. An animation configured for the greeting topic itself takes precedence.",
    [keys.actorIdleVariationEnabled] = "Enable Idle Variations",
    [keys.actorIdleVariationEnabledDescription] =
    "Enables occasional idle variations (a weight shift, a glance away, a small gesture) played while an actor is idling between lines, so they do not hold a single pose. Requires actor animations to be enabled, and only affects actors whose animation set defines variations.",
    [keys.actorIdleVariationInterval] = "Idle Variation Interval",
    [keys.actorIdleVariationIntervalDescription] =
    "The average number of seconds an actor idles before playing a variation. The actual wait is randomized around this value so actors do not move in unison.",
    [keys.actorTurnEnabled] = "Enable Actor Turning",
    [keys.actorTurnEnabledDescription] = "Enables or disables the actor turning to face the player when dialogue starts.",
    [keys.actorHeadMorphAnimEnabled] = "Enable Head Morph Animations",
    [keys.actorHeadMorphAnimEnabledDescription] =
    "Enables or disables actor head morph animations during dialogue. This includes blinking and lip syncing (for voiced dialogue).",
    [keys.actorSimulatedVoiceEnabled] = "Simulate Voice",
    [keys.actorSimulatedVoiceEnabledDescription] =
    "For lines that have no voiceover, synthesizes mouth and head movement from the response text so lip sync and head bob still play. Automatically stands aside on lines that do have a voiceover, so it is safe to leave on with a voice mod installed. Requires head morph and/or head bob to be enabled.",
    [keys.actorSimulatedVoiceSpeed] = "Simulate Voice: Speed",
    [keys.actorSimulatedVoiceSpeedDescription] =
    "Scales how quickly the simulated speech articulates. 1.0 is the default; higher shortens the words and pauses for faster, more clipped speech, lower slows it down.",
    [keys.actorSimulatedVoiceMaxDuration] = "Simulate Voice: Max Duration",
    [keys.actorSimulatedVoiceMaxDurationDescription] =
    "The longest a simulated line will keep animating, in seconds. Longer responses are capped at this value so the mouth movement does not run on far past the point the player has read the line.",
    [keys.actorHeadLookAtModeFirstPerson] = "Head Look-At (First Person)",
    [keys.actorHeadLookAtModeFirstPersonDescription] =
    "What the actor's head turns to look at while you are in first person.\n\nCamera: looks into the camera.\n\nPlayer: looks at the player's head.\n\nOff: the head is left to the body animation.\n\nWhat reads best depends on the camera preset the perspective uses: Player suits over-the-shoulder framings, Camera suits centered ones.",
    [keys.actorHeadLookAtModeThirdPerson] = "Head Look-At (Third Person)",
    [keys.actorHeadLookAtModeThirdPersonDescription] =
    "What the actor's head turns to look at while you are in third person.\n\nCamera: looks into the camera.\n\nPlayer: looks at the player's head.\n\nOff: the head is left to the body animation.\n\nWhat reads best depends on the camera preset the perspective uses: Player suits over-the-shoulder framings, Camera suits centered ones.",
    [keys.actorHeadLookAtModeCamera] = "Camera",
    [keys.actorHeadLookAtModePlayer] = "Player",
    [keys.actorHeadLookAtModeOff] = "Off",
    [keys.actorHeadBobEnabled] = "Enable Head Bob",
    [keys.actorHeadBobEnabledDescription] =
    "Enables or disables subtle procedural head movement while the actor is speaking a voiced line.",
    [keys.actorHeadBobNodEnabled] = "Head Bob: Nodding",
    [keys.actorHeadBobNodEnabledDescription] =
    "Enables or disables the up-and-down nodding component of the head bob. Requires Head Bob to be enabled.",
    [keys.actorHeadBobYawEnabled] = "Head Bob: Turning",
    [keys.actorHeadBobYawEnabledDescription] =
    "Enables or disables the side-to-side turning component of the head bob. Requires Head Bob to be enabled.",
    [keys.actorHeadBobTiltEnabled] = "Head Bob: Tilting",
    [keys.actorHeadBobTiltEnabledDescription] =
    "Enables or disables the tilting (roll) component of the head bob. Requires Head Bob to be enabled.",
    [keys.actorHeadBobAmount] = "Head Bob: Amount",
    [keys.actorHeadBobAmountDescription] =
    "Scales how far the head moves during the bob. 1.0 is the default; higher is more pronounced.",
    [keys.actorHeadBobSpeed] = "Head Bob: Speed",
    [keys.actorHeadBobSpeedDescription] =
    "Scales how quickly the head bobs. 1.0 is the default; higher is faster.",
    [keys.actorHeadBobRandomness] = "Head Bob: Randomness",
    [keys.actorHeadBobRandomnessDescription] =
    "How organic versus mechanical the motion feels. 0 is a steady rhythm; higher blends in more random wander.",
    [keys.propsEnabled] = "Enable Props",
    [keys.propsEnabledDescription] =
    "Enables or disables actors holding props during dialogue (when configured)",
    [keys.blacklistedActorsTitleLabel] = "Blacklist",
    [keys.blacklistedActorsDescription] =
    "Actors on the blacklist are excluded from this mod's functionality entirely.",
    [keys.blacklistedActorsLeftLabel] = "Blacklisted",
    [keys.blacklistedActorsRightLabel] = "Actors",
    [keys.playerPage] = "Player",
    [keys.playerPageDescription] =
    "Animates the player during dialogue, alongside the actor. Player animations apply in third person only; in first person the player's body is not visible and these settings do nothing.",
    [keys.playerAnimEnabled] = "Enable Player Animations",
    [keys.playerAnimEnabledDescription] =
    "Animates the player's body during dialogue, using the same animations as actors. Third person only.",
    [keys.playerAnimation] = "Animation",
    [keys.playerAnimationDescription] =
    "Which animation the player's body plays during dialogue. Context-driven picks one the same way actors do, based on sex, class, and equipment; a specific pick always plays, ignoring those conditions.",
    [keys.playerAnimationContextDriven] = "Context-driven",
    [keys.playerTurnEnabled] = "Enable Player Turning",
    [keys.playerTurnEnabledDescription] =
    "Turns the player to face the actor when dialogue starts, and restores the original facing when it ends.",
    [keys.playerHeadLookAtEnabled] = "Enable Head Look-At",
    [keys.playerHeadLookAtEnabledDescription] =
    "Turns the player's head to look at the actor during dialogue.",
    [keys.visibilityCategory] = "Visibility",
    [keys.hidePlayerMode] = "Hide Player",
    [keys.hidePlayerModeDescription] =
    "Hides the player's model while dialogue is open, so it does not clutter the shot.\n\nFirst Person: hides the first-person hands when dialogue starts in first person.\n\nThird Person: hides the player's body when dialogue starts in third person.\n\nAlways: hides in both perspectives.\n\nNever: leaves the player visible.",
    [keys.hidePlayerModeFirstPerson] = "First Person",
    [keys.hidePlayerModeThirdPerson] = "Third Person",
    [keys.hidePlayerModeAlways] = "Always",
    [keys.hidePlayerModeNever] = "Never",
    [keys.presetsCategory] = "Presets",
    [keys.cameraPresetFirstPerson] = "First Person Preset",
    [keys.cameraPresetFirstPersonDescription] =
    "The camera preset used when dialogue starts while the player is in first person.",
    [keys.cameraPresetThirdPerson] = "Third Person Preset",
    [keys.cameraPresetThirdPersonDescription] =
    "The camera preset used when dialogue starts while the player is in third person.",
    [keys.presetsPage] = "Presets",
    [keys.presetEditTarget] = "Editing Preset",
    [keys.presetEditTargetDescription] =
    "Which preset the fields below edit. Changes apply live to the running game; use Save to write them to disk.",
    [keys.presetName] = "Name",
    [keys.presetNameDescription] = "The display name shown for this preset in the dropdowns. Does not rename the file.",
    [keys.presetAnchor] = "Anchor",
    [keys.presetAnchorDescription] =
    "Whose horizontal position the camera anchors to. Actor keeps the shot framed on the actor; Player places the camera relative to the player, for over-the-shoulder framing.",
    [keys.presetAnchorActor] = "Actor",
    [keys.presetAnchorPlayer] = "Player",
    [keys.presetVerticalAnchor] = "Vertical Anchor",
    [keys.presetVerticalAnchorDescription] =
    "The camera's height, blended between the player's eye level (0%) and the actor's head height (100%). Lower values keep the camera at your own eye line; higher values rise to meet a tall or standing actor and drop to a sitting one.",
    [keys.presetActionsCategory] = "Actions",
    [keys.presetSave] = "Save",
    [keys.presetSaveDescription] = "Writes the current preset's values to its file on disk.",
    [keys.presetSaveConfirm] = "Save this preset to disk, overwriting its file?",
    [keys.presetClone] = "Clone",
    [keys.presetCloneDescription] = "Creates a copy of the current preset as a new, separate preset.",
    [keys.presetNew] = "New",
    [keys.presetNewDescription] = "Creates a new preset with default values.",
    [keys.presetDelete] = "Delete",
    [keys.presetDeleteDescription] = "Deletes the current preset's file from disk. This cannot be undone.",
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
    "The minimum distance the camera maintains from the actor's head during dialogue. If standing closer than this, the camera will pull back.",
    [keys.horizontalOffset] = "Horizontal Offset",
    [keys.horizontalOffsetDescription] =
    "Shifts the camera left or right relative to the actor. Negative values move left, positive values move right.",
    [keys.verticalOffset] = "Vertical Offset",
    [keys.verticalOffsetDescription] =
    "Shifts the camera up or down relative to the actor's head. Negative values move down, positive values move up.",
    [keys.pitchOffset] = "Pitch",
    [keys.pitchOffsetDescription] =
    "Tilts the camera up or down relative to the actor's head. Positive values look down, negative values look up.",
    [keys.yawOffset] = "Yaw",
    [keys.yawOffsetDescription] =
    "Rotates the camera left or right relative to the actor's head. Positive values shift the actor left in frame, negative values shift right.",
    [keys.rollOffset] = "Roll",
    [keys.rollOffsetDescription] =
    "Rolls the camera around the look direction. Positive values tilt clockwise, negative values tilt counter-clockwise.",
    [keys.animationDuration] = "Duration",
    [keys.animationDurationDescription] = "How long the camera zoom animation takes, in seconds.",
    [keys.turnDuration] = "Turn Duration",
    [keys.turnDurationDescription] =
    "How long the actor takes to turn and face the player when dialogue starts, in seconds.",
    [keys.transitionDuration] = "Transition Duration",
    [keys.transitionDurationDescription] =
    "How long the actor's body takes to ease into the dialogue animation when dialogue starts, in seconds. Set to 0 to snap instantly.",
    [keys.effectsPage] = "Effects",
    [keys.dofCategory] = "Depth of Field",
    [keys.dofEnabled] = "Enable Depth of Field",
    [keys.dofEnabledDescription] =
    "Applies a depth of field effect during dialogue, keeping the actor in focus while blurring the background.",
    [keys.dofStrength] = "Blur Strength",
    [keys.dofStrengthDescription] = "Controls how strongly out-of-focus areas are blurred.",
    [keys.letterboxCategory] = "Letterbox",
    [keys.letterboxEnabled] = "Enable Letterbox",
    [keys.letterboxEnabledDescription] =
    "Eases cinematic black bars in at the top and bottom of the screen as dialogue starts, and removes them when it ends.",
    [keys.hudCategory] = "HUD",
    [keys.hideHudEnabled] = "Hide HUD",
    [keys.hideHudEnabledDescription] =
    "Hides the heads-up display (health bars, minimap, equipped weapon and magic) while dialogue is open, and restores it when dialogue ends.",
    [keys.lightingParticlesCategory] = "Lighting & Particles",
    [keys.lightEnabled] = "Enable Light Animation",
    [keys.lightEnabledDescription] =
    "Keeps flickering and pulsing lights (such as torches, candles, and braziers) animating during dialogue. Without this, they freeze while in menu mode.",
    [keys.particlesEnabled] = "Enable Particle Effects",
    [keys.particlesEnabledDescription] =
    "Keeps particle effects (such as the flame on a held torch) animating during dialogue. Without this, they remain frozen while in menu mode.",
    [keys.effectsMode] = "Animation Mode",
    [keys.effectsModeDescription] =
    "Actor: animates just the actor's lights and particle effects.\n\nCurrent cell: animates all lights and particle effects in the current cell, including placed world lights, fireplaces, and other actors' torches.\n\nActive cells: like Current cell, but also includes neighboring loaded cells (exteriors). Within the cell distance. May have a bigger performance impact.",
    [keys.effectsModeActor] = "Actor",
    [keys.effectsModeCurrentCell] = "Current cell",
    [keys.effectsModeActiveCells] = "Active cells",
    [keys.effectsCellDistance] = "Cell Distance",
    [keys.effectsCellDistanceDescription] =
    "In the cell modes, the maximum distance (in game units) a light or particle effect may be from the actor to be animated. Anything beyond this remains frozen.",
    [keys.weatherPage] = "Weather",
    [keys.precipitationEnabled] = "Enable Precipitation",
    [keys.precipitationEnabledDescription] =
    "Keeps rain and snow falling during dialogue. Without this, precipitation freezes while in menu mode.",
    [keys.stormsEnabled] = "Enable Storms",
    [keys.stormsEnabledDescription] =
    "Keeps ash, blight, and blizzard storms swirling during dialogue. Without this, storms freeze while in menu mode.",
    [keys.cloudsEnabled] = "Enable Clouds",
    [keys.cloudsEnabledDescription] =
    "Keeps clouds drifting across the sky during dialogue. Without this, clouds freeze while in menu mode.",
    [keys.swayCategory] = "Sway",
    [keys.swayEnabled] = "Enable Camera Sway",
    [keys.swayEnabledDescription] =
    "Adds a subtle oscillation to the camera during dialogue for a more cinematic, living feel.",
    [keys.swayAmplitude] = "Amplitude",
    [keys.swayAmplitudeDescription] = "How far the camera sways, in degrees. Lower values are more subtle.",
    [keys.swayFrequency] = "Frequency",
    [keys.swayFrequencyDescription] =
    "How fast the camera sways, in cycles per second. Lower values give a slow, breathing-like motion.",
    [keys.debuggingPage] = "Debugging",
    [keys.debugModeEnabled] = "Debugging Mode",
    [keys.debugModeEnabledDescription] =
    "Development tool. Opens a debug window during dialogue with tabs for previewing animations, tuning prop transforms, and live-editing camera presets, and enables the pause key below. Leave off during normal play.",
    [keys.debugPauseKey] = "Pause / Unpause Key",
    [keys.debugPauseKeyDescription] =
    "While debugging mode is on, this key freezes and unfreezes the dialogue scene (actor animation, particles, lights, and weather) so prop transforms can be tuned against a still pose. Only active during dialogue.",
    [keys.debugStepKey] = "Step Frame Key",
    [keys.debugStepKeyDescription] =
    "While the scene is paused, this key advances it by a single frame. Hold to step continuously. Only active during dialogue.",
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
    [keys.debugCameraNoPresetHint] = "The selected camera preset could not be found, so the camera is not animating. Pick an existing preset in the MCM.",
    [keys.debugReplay] = "Replay",
    [keys.debugSavePreset] = "Save Preset to %{id}.json",
    [keys.debugSavePresetConfirm] = "Overwrite %{id}.json with the current values?",
    [keys.debugPresetSaved] = "Saved preset to %{id}.json.",
    [keys.validationFailed] = "Animated Dialogue: one or more configurations failed to load. Check mwse.log for details.",
    [keys.initializationFailed] = "Animated Dialogue failed to initialize and is disabled. Check mwse.log for details.",
    [keys.ok] = "OK",
}
