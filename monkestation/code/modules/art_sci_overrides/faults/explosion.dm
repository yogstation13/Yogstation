/datum/artifact_fault/explosion
	name = "Exploding Fault"
	trigger_chance = 3
	visible_message = "reaches a catastrophic overload, cracks forming at its surface!"

	research_value = 500 //nanotrasen always likes weapons IMO

	weight = ARTIFACT_UNCOMMON

/datum/artifact_fault/explosion/on_trigger()
	our_artifact.holder.Shake(duration = 5 SECONDS, shake_interval = 0.08 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(payload), our_artifact), 5 SECONDS)

/datum/artifact_fault/explosion/proc/payload()
	explosion(our_artifact.holder, light_impact_range = 2, explosion_cause = src)
	qdel(our_artifact.holder)
