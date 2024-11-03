/datum/artifact_fault/death
	name = "Instant Death Fault"
	trigger_chance = 50 //God forbid this actually rolls on a touch artifact,like it did during my testing.
	visible_message = "blows someone up with mind."
	inspect_warning = list(
		span_danger("The grim reapers scythe seems to be reflected in its surface!"),
		span_danger("An aura of death surrounds this object!"),
		span_danger("I'd bet 50/50 someone dies if this turns on!")
	)

	research_value = 10000 //Wow, this would make a fucking amazing weapon

	weight = ARTIFACT_VERYRARE
/datum/artifact_fault/death/on_trigger()
	var/list/mobs = list()
	var/mob/living/carbon/human

	var/center_turf = get_turf(our_artifact.parent)

	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")

	for(var/mob/living/carbon/mob in range(rand(2, 3), center_turf))
		mobs += mob
	if(!length(mobs))
		return
	human = pick(mobs)
	if(!human)
		return
	our_artifact.holder.Beam(human, icon_state = "lightning[rand(1,12)]", time = 0.5 SECONDS)
	human.death(FALSE)
