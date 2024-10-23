/datum/action/changeling/teratoma
	name = "Birth Teratoma"
	desc = "Our form divides, creating an egg that will soon hatch into a living tumor, fixated on causing mayhem. Costs 60 chemicals."
	helptext = "The tumor will not be loyal to us or our cause. Requires 3 changeling absorptions."
	button_icon_state = "spread_infestation"
	chemical_cost = 60
	dna_cost = 2
	req_absorbs = 3

/datum/action/changeling/teratoma/sting_action(mob/living/user)
	..()
	if(create_teratoma(user))
		playsound(user.loc, 'sound/effects/blobattack.ogg', 50, 1)
		user.spawn_gibs()
		user.visible_message(span_danger("Something horrible bursts out of [user]'s chest!"), \
								span_danger("Living teratoma bursts out of your chest!"), \
								span_hear("You hear flesh tearing!"), COMBAT_MESSAGE_RANGE)
	return FALSE		//create_teratoma() handles the chemicals anyway so there is no reason to take them again

/datum/action/changeling/teratoma/proc/create_teratoma(mob/living/user)
	var/datum/antagonist/changeling/ling = user?.mind?.has_antag_datum(/datum/antagonist/changeling)
	if(!ling)
		return FALSE
	ling.adjust_chemicals(-chemical_cost)
	var/list/candidates = SSpolling.poll_ghost_candidates(
		"Do you want to play as a living teratoma?",
		poll_time = 7.5 SECONDS,
		ignore_category = POLL_IGNORE_TERATOMA,
		alert_pic = /datum/antagonist/teratoma,
		role_name_text = "living teratoma",
		chat_text_border_icon = /datum/antagonist/teratoma,
	)
	if(!length(candidates)) //if we got at least one candidate, they're teratoma now
		to_chat(user, span_warning("You fail at creating a tumor. Perhaps you should try again later?"))
		ling.adjust_chemicals(chemical_cost)
		return FALSE
	var/mob/dead/observer/candidate = pick(candidates)
	if(QDELETED(candidate))
		to_chat(user, span_warning("You fail at creating a tumor. Perhaps you should try again later?"))
		ling.adjust_chemicals(chemical_cost)
		return FALSE
	var/mob/living/carbon/human/species/teratoma/goober = new(user.drop_location())
	goober.key = candidate.key
	if(!goober.mind)
		goober.mind_initialize()
	goober.mind.add_antag_datum(/datum/antagonist/teratoma)
	to_chat(goober, span_notice("You burst out from [user]'s chest!"))
	SEND_SOUND(goober, sound('sound/effects/blobattack.ogg'))
	return TRUE
