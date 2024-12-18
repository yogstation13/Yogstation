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

	/// Weakref to the last spawner created by this artifact.
	/// Used to ensure another spawner isn't created while the last one exists.
	var/datum/weakref/spawner_weakref

/datum/artifact_fault/clown/Destroy(force)
	spawner_weakref = null
	return ..()

/datum/artifact_fault/clown/on_trigger()
	var/obj/structure/spawner/clown/hehe = spawner_weakref?.resolve()
	if(!QDELETED(hehe))
		return
	var/center_turf = get_turf(our_artifact.parent)

	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")

	hehe = new(center_turf)
	spawner_weakref = WEAKREF(hehe)
	QDEL_IN(hehe, 3 MINUTES)
