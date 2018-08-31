/datum/spythief_bounty
	var/name = "Spy Thief Bounty (Report this to the coders)"
	var/description = "Please report this to your local maintainers!"
	var/completed = FALSE
	var/objective
	var/area/turn_in_loc

/datum/spythief_bounty/New()
	turn_in_loc = pick(SSticker.mode.spythief_turn_in_locs)

/datum/spythief_bounty/proc/check_complete(atom/A)
	return istype(A, objective)

/***************************************\
|*************Station Items*************|
\***************************************/

/datum/spythief_bounty/station_item/New()
	SSticker.mode.bounty_stationitems += src
	.=..()

/***************************************\
|***************Personal Item***********|
\***************************************/

/datum/spythief_bounty/personal_item/New()
	SSticker.mode.bounty_personalitems += src
	.=..()

/***************************************\
|***************Organs******************|
\***************************************/

/datum/spythief_bounty/organ/New()
	SSticker.mode.bounty_organs += src
	.=..()

/***************************************\
|***************Machines****************|
\***************************************/

/datum/spythief_bounty/machine/New()
	SSticker.mode.bounty_machines += src
	.=..()

/***************************************\
|***************Photography*************|
\***************************************/

/datum/spythief_bounty/photo
	var/mob/living/carbon/human/target
	objective = /obj/item/photo

/datum/spythief_bounty/photo/New()
	..()
	var/list/possible_candidates
	for(var/mob in GLOB.player_list)
		if(!istype(mob, /mob/living/carbon/human))
			continue
		possible_candidates += mob

	target = pick(possible_candidates)

/datum/spythief_bounty/photo/check_complete(atom/A)
	.=..()
	if(.)
		return TRUE //todo: make it check the photo for whether the target is on it