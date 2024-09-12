/datum/artifact_fault/bioscramble
	name = "Bioscrambling Fault"
	trigger_chance = 3
	visible_message = "corrupts nearby biological life!"

	inspect_warning = list(span_danger("It looks like its made of patchwork flesh!"),
	span_danger("It looks Frankenstien like!"))

	research_value = 250

	weight = ARTIFACT_UNCOMMON

/datum/artifact_fault/bioscramble/on_trigger()
	var/center_turf = get_turf(our_artifact.parent)

	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")

	for(var/mob/living/carbon/mob in range(rand(3, 4), center_turf))
		for(var/i in 1 to 3)
			mob.bioscramble(our_artifact.holder)
