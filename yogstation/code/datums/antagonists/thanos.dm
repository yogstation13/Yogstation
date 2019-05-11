#define PINPOINTER_MINIMUM_RANGE 1
#define PINPOINTER_PING_TIME 40

/datum/antagonist/thanos
	name = "Balance Seeker"
	roundend_category = "balance seeker" //just in case
	antagpanel_category = "Wizard"
	job_rank = ROLE_WIZARD
	antag_moodlet = /datum/mood_event/focused
	can_hijack = HIJACK_HIJACKER

/datum/antagonist/thanos/on_gain()
	if(!owner)
		return
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	H.delete_equipment()
	H.set_species(/datum/species/human)
	H.equipOutfit(/datum/outfit/thanos)
	. = ..()

/datum/antagonist/thanos/greet()
	to_chat(owner, "<span class='boldannounce'>You are the Gauntlet-bearer!</span>")
	to_chat(owner, "<B>You must gather the infinity stones and bring balance to the universe!</B>")
	to_chat(owner, "You have a pinpointer showing you where a nearby gem is at all times.")
	to_chat(owner, "Once you have a gem, simply place it into the infinity gauntlet and you gain its powers!.")
	to_chat(owner, "You have already found the space gem, which you may use to travel to the station.")

/datum/antagonist/thanos/farewell()
	to_chat(owner, "<span class='userdanger'>Oh god, what were you thinking? The population's going to bounce back in 50 years anyway...</span>")

/datum/antagonist/thanos/apply_innate_effects()
	.=..()
	if(owner && owner.current)
		owner.current.apply_status_effect(/datum/status_effect/gem_pinpointer)

/datum/antagonist/thanos/remove_innate_effects()
	.=..()
	if(owner && owner.current)
		owner.current.remove_status_effect(/datum/status_effect/gem_pinpointer)

/datum/status_effect/gem_pinpointer
	id = "gem sense"
	duration = -1
	tick_interval = PINPOINTER_PING_TIME
	alert_type = /obj/screen/alert/status_effect/agent_pinpointer
	var/minimum_range = PINPOINTER_MINIMUM_RANGE
	var/item/infinity_gem/scan_target = null
	var/range_mid = 8
	var/range_far = 16

/obj/screen/alert/status_effect/gem_pinpointer
	name = "Gem sense"
	desc = "You are inevitable."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinon"

/datum/status_effect/gem_pinpointer/proc/point_to_target() //If we found what we're looking for, show the distance and direction
	if(!scan_target)
		linked_alert.icon_state = "pinonnull"
		return
	var/turf/here = get_turf(owner)
	var/turf/there = get_turf(scan_target)
	if(here.z != there.z)
		linked_alert.icon_state = "pinonnull"
		return
	if(get_dist_euclidian(here,there)<=minimum_range)
		linked_alert.icon_state = "pinondirect"
	else
		linked_alert.setDir(get_dir(here, there))
		var/dist = (get_dist(here, there))
		if(dist >= 1 && dist <= range_mid)
			linked_alert.icon_state = "pinonclose"
		else if(dist > range_mid && dist <= range_far)
			linked_alert.icon_state = "pinonmedium"
		else if(dist > range_far)
			linked_alert.icon_state = "pinonfar"

/datum/status_effect/gem_pinpointer/proc/scan_for_target()
	var/turf/my_loc = get_turf(owner)

	var/list/item/infinity_gem/targets = list()

	for(var/item/infinity_gem/gem in GLOB.poi_list)
		var/their_loc = get_turf(gem)
		var/distance = get_dist_euclidian(my_loc, their_loc)
		if(distance>PINPOINTER_MINIMUM_RANGE && distance<PINPOINTER_MAX_RANGE)
			targets[gem] = ((22500) - (distance ** 2))

	if(targets.len)
		scan_target = pickweight(targets) //Point at a 'random' target, biasing heavily towards closer ones.
	else
		scan_target = null
	

/datum/status_effect/gem_pinpointer/tick()
	if(!owner)
		qdel(src)
		return
	scan_for_target()
	point_to_target()
