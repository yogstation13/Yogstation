/datum/artifact_fault/greg
	name = "Greg Fault"
	discovered_credits = 250
	research_value = 1000
	trigger_chance = 5
	weight = ARTIFACT_RARE

/datum/artifact_fault/greg/on_added()
	our_artifact.holder.AddComponent(/datum/component/ghost_object_control,our_artifact.holder,TRUE)

/datum/artifact_fault/greg/on_trigger()
	var/datum/component/ghost_object_control/spiritholder = our_artifact.holder.GetComponent(/datum/component/ghost_object_control)

	if(!(spiritholder.bound_spirit))
		spiritholder.request_control(0.8)

