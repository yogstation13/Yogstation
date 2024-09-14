/datum/artifact_effect
	///string added to artifact desc, if not discovered.
	var/examine_hint
	///string added to artifact desc, if the effect has been discovered
	var/examine_discovered
	///When you discover this, how many credits does it add to the sell price?
	var/discovered_credits = CARGO_CRATE_VALUE*0.75
	///how likely is it that this effect is added to an artifact?
	var/weight = ARTIFACT_COMMON
	///if defined, artifact must be this size to roll
	var/artifact_size
	///how strong is this effect,1-100
	var/potency
	///If the artifact doesnt have the right activator, cant be put on. If null, assume any.
	var/list/valid_activators
	///If the artifact doesnt have this origin, cant be put on. If null, assume any.
	var/list/valid_origins
	///sent on activation
	var/activation_message
	///played on activation
	var/activation_sound
	///sent on deactivation
	var/deactivation_message
	///played on deactivation
	var/deactivation_sound
	///list of paths the artifacts holder is allowed to be, if null, may be on any artifact datum holder.
	var/list/valid_type_paths
	///Does this show up on the artifact fourm?
	var/super_secret = FALSE

	///Research value when discovered For reference,5000 is one node
	var/research_value = 100
	///The artifact we're on.
	var/datum/component/artifact/our_artifact
	///Type of effect, shows up in Xray Machine
	var/type_name = "Generic Artifact Effect"

/datum/artifact_effect/New()
	. = ..()
	potency = rand(1, 100)

/datum/artifact_effect/Destroy(force)
	our_artifact = null
	return ..()

///Called when the artifact has been created
/datum/artifact_effect/proc/setup()
	return
///Called when the artifact has been activated
/datum/artifact_effect/proc/effect_activate(silent)
	return
///Called when the artifact has been de-activated
/datum/artifact_effect/proc/effect_deactivate(silent)
	return
///Called when the artifact has been touched by a living mob,does NOT call faults or activate artifact unless it has the correct touch component!
/datum/artifact_effect/proc/effect_touched(mob/living/user)
	return
///Called on process() IF the artifact is active.
/datum/artifact_effect/proc/effect_process()
	return
///Called when the artifact/effect is destroyed is destroyed
/datum/artifact_effect/proc/on_destroy(atom/source)
	return
///Util, can be called to activate, then de-activate the artifact as a whole swiftly. Wont Re activate already active artifacts.
/datum/artifact_effect/proc/flick_active(silent)
	if(!our_artifact.active)
		our_artifact.artifact_activate(silent)
	our_artifact.artifact_deactivate(silent)
	return
///Util, can be called to swap the artifacts active status quickly.
/datum/artifact_effect/proc/toggle_active(silent)
	our_artifact.active ? our_artifact.artifact_deactivate(silent) : our_artifact.artifact_activate(silent)
