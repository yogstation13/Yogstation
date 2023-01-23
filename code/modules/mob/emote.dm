///How confused a carbon must be before they will vomit
#define BEYBLADE_PUKE_THRESHOLD 30
///How must nutrition is lost when a carbon pukes
#define BEYBLADE_PUKE_NUTRIENT_LOSS 60
///How often a carbon becomes penalized
#define BEYBLADE_DIZZINESS_PROBABILITY 20
///How long the screenshake lasts
#define BEYBLADE_DIZZINESS_DURATION 20
///How much confusion a carbon gets every time they are penalized
#define BEYBLADE_CONFUSION_INCREMENT 10
///A max for how much confusion a carbon will be for beyblading
#define BEYBLADE_CONFUSION_LIMIT 40

//The code execution of the emote datum is located at code/datums/emotes.dm
/mob/proc/emote(act, m_type = null, message = null, intentional = FALSE, is_keybind = FALSE)
	act = lowertext(act)
	var/param = message
	var/custom_param = findchar(act, " ")
	if(custom_param)
		param = copytext(act, custom_param + length(act[custom_param]))
		act = copytext(act, 1, custom_param)


	var/list/key_emotes = GLOB.emote_list[act]

	if(!length(key_emotes))
		if(intentional)
			to_chat(src, span_notice("'[act]' emote does not exist. Say *help for a list."))
		return FALSE
	var/silenced = FALSE
	for(var/datum/emote/P in key_emotes)
		if(!P.check_cooldown(src, intentional, is_keybind=is_keybind))
			silenced = TRUE
			continue
		if(P.run_emote(src, param, m_type, intentional))
			return TRUE
	if(intentional && !silenced)
		to_chat(src, span_notice("Unusable emote '[act]'. Say *help for a list."))
	return FALSE


/datum/emote/flip
	key = "flip"
	key_third_person = "flips"
	restraint_check = TRUE
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)
	cooldown = 0 SECONDS

/datum/emote/flip/run_emote(mob/user, params , type_override, intentional)
	. = ..()
	if(.)
		user.SpinAnimation(7,1)

/datum/emote/flip/check_cooldown(mob/user, intentional, update=TRUE, is_keybind = FALSE)
	. = ..()
	if (!is_keybind)
		return
	if(!can_run_emote(user, intentional=intentional))
		return
	if(!.)
		if(isliving(user)) // Spammers get punished!
			var/mob/living/flippy_mcgee = user
			if(prob(40))
				flippy_mcgee.Knockdown(1 SECONDS)
				flippy_mcgee.visible_message(
					span_notice("[flippy_mcgee] attempts to do a flip and falls over, what a doofus!"),
					span_notice("You attempt to do a flip while still off balance from the last flip and fall down!")
				)
				if(prob(50))
					flippy_mcgee.adjustBruteLoss(1)
			else
				flippy_mcgee.visible_message(
					span_notice("[flippy_mcgee] stumbles a bit after their flip."),
					span_notice("You stumble a bit from still being off balance from your last flip.")
				)
		return

/datum/emote/spin
	key = "spin"
	key_third_person = "spins"
	restraint_check = TRUE
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)
	cooldown = 0 SECONDS

/datum/emote/spin/run_emote(mob/user, params ,type_override, intentional)
	. = ..()
	if(.)
		if(iscyborg(user) && user.has_buckled_mobs())
			var/mob/living/silicon/robot/R = user
			var/datum/component/riding/riding_datum = R.GetComponent(/datum/component/riding)
			if(riding_datum)
				for(var/mob/M in R.buckled_mobs)
					riding_datum.force_dismount(M)
			else
				R.unbuckle_all_mobs()
		else
			//we want to hold off on doing the spin if they are a cyborg and have someone buckled to them
			user.spin(20,1)

/datum/emote/spin/check_cooldown(mob/living/carbon/user, intentional, update=TRUE, is_keybind = FALSE)
	. = ..()
	if(!.)
		return
	if (!is_keybind)
		return
	if(!can_run_emote(user, intentional=intentional))
		return
	if(!iscarbon(user))
		return
	var/current_confusion = user.confused
	if(current_confusion > BEYBLADE_PUKE_THRESHOLD)
		user.vomit(BEYBLADE_PUKE_NUTRIENT_LOSS, distance = 0)
		return
	if(prob(BEYBLADE_DIZZINESS_PROBABILITY))
		to_chat(user, "<span class='warning'>You feel woozy from spinning.</span>")
		user.Dizzy(BEYBLADE_DIZZINESS_DURATION)
		if(current_confusion < BEYBLADE_CONFUSION_LIMIT)
			user.confused += BEYBLADE_CONFUSION_INCREMENT

#undef BEYBLADE_PUKE_THRESHOLD
#undef BEYBLADE_PUKE_NUTRIENT_LOSS
#undef BEYBLADE_DIZZINESS_PROBABILITY
#undef BEYBLADE_DIZZINESS_DURATION
#undef BEYBLADE_CONFUSION_INCREMENT
#undef BEYBLADE_CONFUSION_LIMIT
