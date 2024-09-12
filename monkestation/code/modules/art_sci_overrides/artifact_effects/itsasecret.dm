/datum/artifact_effect/toeverybody
	examine_hint = "Seems...off somehow."
	examine_discovered = "Temporarily tears holes in reality."
	discovered_credits = CARGO_CRATE_VALUE * 100 //GDM
	weight = ARTIFACT_VERYRARE/5 //Super rare
	activation_message = "tears open the fabric of reality!"

	research_value = 10000

	type_name = "Its a Secret to Everybody"

	super_secret = TRUE

	COOLDOWN_DECLARE(trigger_cd)

/datum/artifact_effect/toeverybody/proc/returnthey(mob/living/carbon/human,turf/last_position)
	human.forceMove(last_position)
	return

/datum/artifact_effect/toeverybody/effect_activate(silent)
	if(!COOLDOWN_FINISHED(src,trigger_cd))
		return
	var/list/mobs = list()
	var/mob/living/carbon/human

	var/center_turf = get_turf(our_artifact.parent)

	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")

	for(var/mob/living/carbon/mob in range(rand(3, 4), center_turf))
		mobs += mob
	if(!length(mobs))
		return
	human = pick(mobs)
	if(!human)
		return

	var/last_position = get_turf(human)
	human.move_to_error_room()
	COOLDOWN_START(src,trigger_cd,5 MINUTE)
	addtimer(CALLBACK(src,PROC_REF(returnthey),human,last_position),5 SECOND)
	return

