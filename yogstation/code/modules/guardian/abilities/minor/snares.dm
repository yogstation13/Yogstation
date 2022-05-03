/datum/guardian_ability/minor/snare
	name = "Surveillance Snares"
	desc = "The guardian can lay a surveillance snare, which alerts the guardian and the user to anyone who crosses it."
	cost = 1
	action_types = list(/datum/action/guardian/arm_snare, /datum/action/guardian/disarm_snare)
	var/list/snares = list()

/datum/guardian_ability/minor/snare/Remove()
	. = ..()
	QDEL_LIST(snares)

/datum/action/guardian/arm_snare
	name = "Arm Snare"
	desc = "Set an invisible snare that will alert you when living creatures walk over it. Max of 5."
	button_icon_state = "arm_snare"

/datum/action/guardian/arm_snare/on_use(mob/living/simple_animal/hostile/guardian/user)
	var/datum/guardian_ability/minor/snare/ability = user.has_ability(/datum/guardian_ability/minor/snare)
	if (ability.snares.len < 6)
		var/turf/snare_loc = get_turf(user)
		var/obj/effect/snare/S = new /obj/effect/snare(snare_loc)
		S.spawner = user
		S.name = "[get_area(snare_loc)] snare ([rand(1, 1000)])"
		ability.snares |= S
		to_chat(user, span_bolddanger("Surveillance snare deployed!"))
	else
		to_chat(user, span_bolddanger("You have too many snares deployed. Remove some first."))

/datum/action/guardian/disarm_snare
	name = "Disarm Snare"
	desc = "Disarm unwanted surveillance snares."
	button_icon_state = "disarm_snare"

/datum/action/guardian/disarm_snare/on_use(mob/living/simple_animal/hostile/guardian/user)
	var/datum/guardian_ability/minor/snare/ability = user.has_ability(/datum/guardian_ability/minor/snare)
	var/picked_snare = input(user, "Pick which snare to remove", "Remove Snare") as null|anything in ability.snares
	if (picked_snare)
		ability.snares -= picked_snare
		qdel(picked_snare)
		to_chat(ability, span_bolddanger("Snare disarmed."))

// the snare

/obj/effect/snare
	name = "snare"
	desc = "You shouldn't be seeing this!"
	var/mob/living/simple_animal/hostile/guardian/spawner
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/snare/Crossed(AM as mob|obj)
	. = ..()
	if (isliving(AM) && spawner && spawner?.summoner?.current && AM != spawner && !spawner.hasmatchingsummoner(AM))
		to_chat(spawner.summoner.current, span_bolddanger("[AM] has crossed surveillance snare, [name]."))
		var/list/guardians = spawner.summoner.current.hasparasites()
		for (var/para in guardians)
			to_chat(para, span_bolddanger("[AM] has crossed surveillance snare, [name]."))

/obj/effect/snare/singularity_act()
	return

/obj/effect/snare/singularity_pull()
	return
