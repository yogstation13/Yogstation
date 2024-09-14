/datum/artifact_fault
	var/name = "Generic Fault"
	///the visible message sent when triggered
	var/visible_message
	///the chance of us triggering on bad info
	var/trigger_chance = 0
	//how many credits do we get for discovering this? Should be negative.
	var/discovered_credits = 0
	//If availible, warns users that this WILL fuck you up. Picks randomly from list
	var/list/inspect_warning
	///Added by xray machine when discovered.
	var/research_value = 0
	///How likely the fault is to roll.
	var/weight = ARTIFACT_COMMON
	///Our Artifact
	var/datum/component/artifact/our_artifact

/datum/artifact_fault/Destroy(force)
	our_artifact = null
	return ..()

///called when the artifact gets a stimulus, and passes its trigger chance effect.
/datum/artifact_fault/proc/on_trigger()
	return

///Called when the artifact trait comes into existance
/datum/artifact_fault/proc/on_added()
	return

/datum/artifact_fault/shutdown
	name = "Random Shutdown Fault"
	visible_message = "has something malfunction and shuts down!"
	trigger_chance = 1


/datum/artifact_fault/on_trigger(datum/component/artifact/component)
	if(component.active)
		component.artifact_deactivate()
