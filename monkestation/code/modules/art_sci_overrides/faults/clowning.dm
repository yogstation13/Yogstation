/datum/artifact_fault/clown
	name = "Funny Fault"
	trigger_chance = 5
	inspect_warning = list(
		"Smells faintly of bananas",
		"Looks funny.",
		"Hates mimes.",
	)
	visible_message = "summons a portal to the HONK DIMENSION!"
	discovered_credits = -500
	research_value = 250

	weight = ARTIFACT_VERYRARE

/datum/artifact_fault/clown/on_trigger()
	var/center_turf = get_turf(our_artifact.parent)

	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")

	var/obj/structure/spawner/clown/hehe = new(center_turf)
	QDEL_IN(hehe, 3 MINUTES)
