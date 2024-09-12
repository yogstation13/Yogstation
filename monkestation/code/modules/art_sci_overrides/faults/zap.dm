/datum/artifact_fault/tesla_zap
	name = "Energetic Discharge Fault"
	trigger_chance = 12
	visible_message = "discharges a large amount of electricity!"

	research_value = 200

	weight = ARTIFACT_RARE

/datum/artifact_fault/tesla_zap/on_trigger()
	var/list/mobs = list()

	var/center_turf = get_turf(our_artifact.parent)

	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")
	var/shock_range = rand(4, 7)
	for(var/mob/living/carbon/mob in range(shock_range, center_turf))
		mobs += mob
	if(!length(mobs))
		return

	tesla_zap(our_artifact.holder, shock_range, ZAP_MOB_DAMAGE,shocked_targets = mobs)
