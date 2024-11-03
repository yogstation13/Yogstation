/datum/artifact_fault/monkey_mode
	name = "Simian Spawner Fault"
	trigger_chance = 5
	visible_message = "summons a mass of simians!"

	research_value = 250

	weight = ARTIFACT_VERYUNCOMMON

/datum/artifact_fault/monkey_mode/on_trigger()
	var/monkeys_to_spawn = rand(1,4)
	var/center_turf = get_turf(our_artifact.parent)
	var/list/turf/valid_turfs = list()
	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")
	for(var/turf/boi in range(rand(3, 6), center_turf))
		if(boi.is_blocked_turf(source_atom = our_artifact.parent))
			continue
		valid_turfs += boi
	for(var/i in 1 to min(monkeys_to_spawn, length(valid_turfs)))
		var/turf/spawnon = pick_n_take(valid_turfs)
		switch(rand(1, 100))
			if(1 to 75)
				new /mob/living/carbon/human/species/monkey/angry(spawnon)
			if(75 to 95)
				new /mob/living/basic/gorilla(spawnon)
			if(95 to 100)
				new /mob/living/basic/gorilla/lesser(spawnon)//OH GOD ITS TINY

