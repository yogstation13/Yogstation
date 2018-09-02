/datum/spythief_bounty
	var/name = "Spy Thief Bounty (Report this to the coders)"
	var/description = "Please report this to your local maintainers!"
	var/completed = FALSE	//whether the bounty has been completed or not
	var/objective			//the path of the item they need to get
	var/area/turn_in_loc	//the area they need to be in to turn the bounty in
	var/hot = FALSE 		//if it's hot, they get a bigger reward
	var/reward				//the amount of TC they get as a reward
	var/old_reward			//the reward pre-hotness
	var/datum/game_mode/spythief/mode

/datum/spythief_bounty/New()
	mode = SSticker.mode
	turn_in_loc = pick(mode.spythief_turn_in_locs)
	reward = rand(3,5)

/datum/spythief_bounty/proc/check_complete(atom/A)
	return istype(A, objective)

/datum/spythief_bounty/proc/complete(mob/user)
	var/datum/antagonist/spythief/spy = user.mind.has_antag_datum(/datum/antagonist/spythief)
	GET_COMPONENT_FROM(uplink, /datum/component/uplink, spy.uplink_holder)
	uplink.telecrystals += reward
	completed = TRUE


/datum/spythief_bounty/proc/makeHot()
	hot = TRUE
	old_reward = reward
	reward = rand(6,8)

/datum/spythief_bounty/proc/resetHot()
	hot = FALSE
	reward = old_reward

/***************************************\
|*************Station Items*************|
\***************************************/

/datum/spythief_bounty/station_item/New()
	mode.bounty_stationitems += src
	.=..()

/datum/spythief_bounty/station_item/complete()
	mode.bounty_stationitems -= src
	.=..()

/***************************************\
|***************Personal Item***********|
\***************************************/

/datum/spythief_bounty/personal_item/New()
	mode.bounty_personalitems += src
	.=..()

/datum/spythief_bounty/personal_item/complete()
	mode.bounty_personalitems -= src
	.=..()

/***************************************\
|***************Organs******************|
\***************************************/

/datum/spythief_bounty/organ/New()
	mode.bounty_organs += src
	.=..()

/datum/spythief_bounty/organ/complete()
	mode.bounty_organs -= src
	.=..()

/***************************************\
|***************Machines****************|
\***************************************/

/datum/spythief_bounty/machine/New()
	mode.bounty_machines += src
	.=..()

/datum/spythief_bounty/machine/complete()
	mode.bounty_machines -= src
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
		if(mob in mode.completed_photos)
			continue
		possible_candidates += mob

	target = pick(possible_candidates)

/datum/spythief_bounty/photo/check_complete(atom/A)
	.=..()
	if(.)
		return TRUE //todo: make it check the photo for whether the target is on it

/datum/spythief_bounty/photo/complete()
	mode.completed_photos += target
	.=..()
