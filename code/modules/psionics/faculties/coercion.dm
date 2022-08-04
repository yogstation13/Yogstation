/datum/psionic_faculty/coercion
	id = PSI_COERCION
	name = "Coercion"
	associated_intent = INTENT_DISARM

/datum/psionic_power/coercion
	faculty = PSI_COERCION

/datum/psionic_power/coercion/invoke(var/mob/living/user, var/mob/living/target)
	if (!istype(target))
		to_chat(user, span_warning("You cannot mentally attack \the [target]."))
		return FALSE

	. = ..()

/datum/psionic_power/coercion/blindstrike
	name =           "Blindstrike"
	cost =           8
	cooldown =       120
	use_ranged =     TRUE
	use_melee =      TRUE
	min_rank =       PSI_RANK_GRANDMASTER
	use_description = "Target the eyes or mouth on disarm intent and click anywhere to use a radial attack that blinds, deafens and disorients everyone near you."

/datum/psionic_power/coercion/blindstrike/invoke(var/mob/living/user, var/mob/living/target)
	if((user.zone_selected != BODY_ZONE_PRECISE_MOUTH && user.zone_selected != BODY_ZONE_PRECISE_EYES) || target.pulledby == user)
		return FALSE
	. = ..()
	if(.)
		user.visible_message(span_danger("\The [user] suddenly throws back their head, as though screaming silently!"))
		to_chat(user, span_danger("You strike at all around you with a deafening psionic scream!"))
		for(var/mob/living/M in orange(user, user.psi.get_rank(PSI_COERCION)))
			if(M == user)
				continue
			M.emote("scream")
			to_chat(M, span_danger("Your senses are blasted into oblivion by a psionic scream!"))
			M.eye_blind = max(M.eye_blind,3)
//			M.ear_deaf = max(M.ear_deaf,6)
			M.confused = rand(3,8)
		return TRUE

/datum/psionic_power/coercion/mindread
	name =            "Read Mind"
	cost =            25
	cooldown =        250 //It should take a WHILE to be able to use this again.
	use_melee =       TRUE
	min_rank =        PSI_RANK_OPERANT
	use_description = "Target the head on disarm intent at melee range to attempt to read a victim's surface thoughts."

/datum/psionic_power/coercion/mindread/invoke(var/mob/living/user, var/mob/living/target)
	if(!isliving(target) || !istype(target) || user.zone_selected != BODY_ZONE_HEAD || target.pulledby == user)
		return FALSE
	. = ..()
	if(!.)
		return

	if(target.stat == DEAD || (HAS_TRAIT(target, TRAIT_FAKEDEATH)) || !target.client)
		to_chat(user, span_warning("\The [target] is in no state for a mind-read."))
		return TRUE

	user.visible_message(span_warning("\The [user] touches \the [target]'s temple..."))
	var/question =  input(user, "Say something?", "Read Mind", "Penny for your thoughts?") as null|text
	if(!question || user.incapacitated() || !do_after(user, 20))
		return TRUE

	var/started_mindread = world.time
	to_chat(user, span_notice("<b>You dip your mentality into the surface layer of \the [target]'s mind, seeking an answer: <i>[question]</i></b>"))
	to_chat(target, span_notice("<b>Your mind is compelled to answer: <i>[question]</i></b>")) // I wonder how this will go down with the playerbase

	var/answer =  input(target, question, "Read Mind") as null|text
	if(!answer || world.time > started_mindread + 25 SECONDS || user.stat != CONSCIOUS || target.stat == DEAD)
		to_chat(user, span_notice("<b>You receive nothing useful from \the [target].</b>"))
	else
		to_chat(user, span_notice("<b>You skim thoughts from the surface of \the [target]'s mind: <i>[answer]</i></b>"))
	log_game("[key_name(user)] read mind of [key_name(target)] with question \"[question]\" and [answer?"got answer \"[answer]\".":"got no answer."]")
	return TRUE

/datum/psionic_power/coercion/agony
	name =          "Agony"
	cost =          8
	cooldown =      50
	use_melee =     TRUE
	min_rank =      PSI_RANK_MASTER
	use_description = "Target the chest or groin on disarm intent to use a melee attack equivalent to a strike from a stun baton."

/datum/psionic_power/coercion/agony/invoke(var/mob/living/user, var/mob/living/target)
	if(!istype(target))
		return FALSE
	if(user.zone_selected != BODY_ZONE_CHEST && user.zone_selected != BODY_ZONE_PRECISE_GROIN)
		return FALSE
	. = ..()
	if(.)
		user.visible_message("<span class='danger'>\The [target] has been struck by \the [user]!</span>")
		playsound(user.loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
		target.apply_damage(70, STAMINA, BODY_ZONE_CHEST)
		return TRUE

/datum/psionic_power/coercion/spasm
	name =           "Spasm"
	cost =           15
	cooldown =       100
	use_melee =      TRUE
	use_ranged =     TRUE
	min_rank =       PSI_RANK_MASTER
	use_description = "Target the arms or hands on disarm intent to use a ranged attack that may rip the weapons away from the target."

/datum/psionic_power/coercion/spasm/invoke(var/mob/living/user, var/mob/living/carbon/human/target)
	if(!istype(target))
		return FALSE

	if(!(user.zone_selected in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)))
		return FALSE

	. = ..()

	if(.)
		to_chat(user, "<span class='danger'>You lash out, stabbing into \the [target] with a lance of psi-power.</span>")
		to_chat(target, "<span class='danger'>The muscles in your arms cramp horrendously!</span>")
		if(prob(75))
			target.emote("scream")
		if(prob(75) && target.held_items[1] && target.dropItemToGround(target.get_item_for_held_index(1)))
			target.visible_message("<span class='danger'>\The [target] drops what they were holding as their left hand spasms!</span>")
		if(prob(75) && target.held_items[2] && target.dropItemToGround(target.get_item_for_held_index(2)))
			target.visible_message("<span class='danger'>\The [target] drops what they were holding as their right hand spasms!</span>")
		return TRUE

/datum/psionic_power/coercion/mindslave
	name =          "Mindslave"
	cost =          28
	cooldown =      200
	use_melee =      TRUE
	min_rank =      PSI_RANK_PARAMOUNT
	use_description = "Grab a victim, target the eyes, then use the grab on them while on disarm intent, in order to convert them into a loyal mind-slave. The process takes some time, and failure is punished harshly."

/datum/psionic_power/coercion/mindslave/invoke(var/mob/living/user, var/mob/living/target)
	if(!istype(target) || user.zone_selected != BODY_ZONE_PRECISE_EYES || target.pulledby != user)
		return FALSE
	. = ..()
	if(.)
		if(target.stat == DEAD || (HAS_TRAIT(target, TRAIT_FAKEDEATH)))
			to_chat(user, "<span class='warning'>\The [target] is dead!</span>")
			return TRUE
		if(!target.mind || !target.key)
			to_chat(user, "<span class='warning'>\The [target] is mindless!</span>")
			return TRUE
		user.visible_message("<span class='danger'><i>\The [user] seizes the head of \the [target] in both hands...</i></span>")
		to_chat(user, "<span class='warning'>You plunge your mentality into that of \the [target]...</span>")
		to_chat(target, "<span class='danger'>Your mind is invaded by the presence of \the [user]! They are trying to make you a slave!</span>")
		if(!do_after(user, target.stat == CONSCIOUS ? 80 : 40, target, 0, 1))
			user.psi.backblast(rand(10,25))
			return TRUE
		to_chat(user, "<span class='danger'>You sear through \the [target]'s neurons, reshaping as you see fit and leaving them subservient to your will!</span>")
		to_chat(target, "<span class='danger'>Your defenses have eroded away and \the [user] has made you their mindslave.</span>")
		target.mind.add_antag_datum(ANTAG_DATUM_THRALL)
		return TRUE

/datum/psionic_power/coercion/assay
	name =            "Assay"
	cost =            15
	cooldown =        100
	use_melee =      TRUE
	min_rank =        PSI_RANK_OPERANT
	use_description = "Grab a patient, target the head, then use the grab on them while on disarm intent, in order to perform a deep coercive-redactive probe of their psionic potential."

/datum/psionic_power/coercion/assay/invoke(var/mob/living/user, var/mob/living/target)
	if(!istype(target) || user.zone_selected != BODY_ZONE_HEAD || target.pulledby != user || user == target)
		return FALSE
	. = ..()
	if(.)
		user.visible_message(span_warning("\The [user] holds the head of \the [target] in both hands..."))
		to_chat(user, span_notice("You insinuate your mentality into that of \the [target]..."))
		to_chat(target, span_warning("Your persona is being probed by the psychic lens of \the [user]."))
		if(!do_after(user, (target.stat == CONSCIOUS ? 50 : 25), target, 0, 1))
			user.psi.backblast(rand(5,10))
			return TRUE
		to_chat(user, span_notice("You retreat from \the [target], holding your new knowledge close."))
		to_chat(target, span_danger("Your mental complexus is laid bare to judgement of \the [user]."))
		target.show_psi_assay(user)
		return TRUE

/datum/psionic_power/coercion/focus
	name =          "Focus"
	cost =          10
	cooldown =      80
	use_melee =      TRUE
	min_rank =      PSI_RANK_MASTER
	use_description = "Grab a patient, target the mouth, then use the grab on them while on disarm intent, in order to cure ailments of the mind."

/datum/psionic_power/coercion/focus/invoke(var/mob/living/user, var/mob/living/target)
	if(user.zone_selected != BODY_ZONE_PRECISE_MOUTH || target.pulledby != user)
		return FALSE
	. = ..()
	if(.)
		user.visible_message(span_warning("\The [user] holds the head of \the [target] in both hands..."))
		to_chat(user, span_notice("You probe \the [target]'s mind for various ailments.."))
		to_chat(target, span_warning("Your mind is being cleansed of ailments by \the [user]."))
		if(!do_after(user, (target.stat == CONSCIOUS ? 50 : 25), target, 0, 1))
			user.psi.backblast(rand(5,10))
			return TRUE
		to_chat(user, span_warning("You clear \the [target]'s mind of ailments."))
		to_chat(target, span_warning("Your mind is cleared of ailments."))

		var/coercion_rank = user.psi.get_rank(PSI_COERCION)
		if(coercion_rank >= PSI_RANK_GRANDMASTER)
			target.SetParalyzed(0)
		target.drowsyness = 0
		if(istype(target, /mob/living/carbon))
			var/mob/living/carbon/M = target
			M.hallucination = max(M.hallucination, 10)
		return TRUE

/datum/psionic_power/coercion/commune
	name =           "Commune"
	cost =           10
	cooldown =       80
	use_melee =      TRUE
	use_ranged =     TRUE
	min_rank =       PSI_RANK_OPERANT
	use_description = "Target the mouth and click on a creature on disarm intent to psionically send them a message."

/datum/psionic_power/coercion/commune/invoke(var/mob/living/user, var/mob/living/target)
	if(user.zone_selected != "mouth" || user == target)
		return FALSE
	. = ..()
	if(.)
		user.visible_message("<i><span class='notice'>[user] touches their fingers to their temple.</span></i>")
		var/text = pretty_filter(stripped_input(user, "What would you like to say?", "Speak to creature", null, null))

		if(!text)
			return

		if(target.stat == DEAD)
			to_chat(user,"<span class='cult'>Not even a psion of your level can speak to the dead.</span>")
			return

		if (issilicon(target)) 
			to_chat(user,"<span class='warning'>This can only be used on living organisms.</span>")
			return

		log_say("[key_name(user)] communed to [key_name(target)]: [text]")

		for (var/mob/M in GLOB.player_list)
			if(M.stat == DEAD &&  M.client.prefs.toggles & CHAT_GHOSTEARS)
				to_chat(M,"<span class='notice'>[user] psionically says to [target]:</span> [text]")

		var/mob/living/carbon/human/H = target
//		if (target.can_commune())
		to_chat(H,"<b>You instinctively sense [user] sending their thoughts into your mind, hearing:</b> [text]")
		if(prob(25) && (target.mind && target.mind.assigned_role == "Chaplain"))
			to_chat(H,"<b>You sense [user]'s psyche enter your mind, whispering quietly:</b> [text]")
		else
			to_chat(H,"<b>You feel something crawl behind your eyes, hearing:</b> [text]")
			if(istype(H))
				//if (H.can_commune())
				//	return
				if(prob(10) && !(H.dna.species.species_traits & NOBLOOD))
					to_chat(H,"<span class='warning'>Your nose begins to bleed...</span>")
					//H.drip(3)
				else if(prob(25))
					to_chat(H,"<span class='warning'>Your head hurts...</span>")
				else if(prob(50))
					to_chat(H,"<span class='warning'>Your mind buzzes...</span>")

/datum/psionic_power/coercion/psiping
	name =           "Psi-ping"
	cost =           30
	cooldown =       250
	use_melee =      TRUE
	min_rank =       PSI_RANK_OPERANT
	use_description = "Click on yourself with an empty hand on disarm intent to detect nearby psionic signatures."

/datum/psionic_power/coercion/psiping/invoke(var/mob/living/user, var/mob/living/target)
	if((target && user != target))
		return FALSE
	. = ..()
	if(.)
		to_chat(user, "<span class='notice'>You take a moment to tune into the local Nlom...</span>")
		if(!do_after(user, 3 SECONDS))
			return
		var/list/dirs = list()
		for(var/mob/living/L in range(20))
			var/turf/T = get_turf(L)
			if(!T || L == user || L.stat == DEAD || issilicon(L))
				continue
			var/image/ping_image = image(icon = 'icons/effects/effects.dmi', icon_state = "sonar_ping", loc = user)
			ping_image.plane = LIGHTING_LAYER+1
			ping_image.layer = LIGHTING_LAYER+1
			ping_image.pixel_x = (T.x - user.x) * 32
			ping_image.pixel_y = (T.y - user.y) * 32
			user << ping_image
			addtimer(CALLBACK(GLOBAL_PROC, /proc/qdel, ping_image), 8)
			var/direction = num2text(get_dir(user, L))
			var/dist
			if(text2num(direction))
				switch(get_dist(user, L) / user.client.view)
					if(0 to 0.2)
						dist = "very close"
					if(0.2 to 0.4)
						dist = "close"
					if(0.4 to 0.6)
						dist = "a little ways away"
					if(0.6 to 0.8)
						dist = "farther away"
					else
						dist = "far away"
			else
				dist = "on top of you"
			LAZYINITLIST(dirs[direction])
			dirs[direction][dist] += 1
		for(var/d in dirs)
			var/list/feedback = list()
			for(var/dst in dirs[d])
				feedback += "[dirs[d][dst]] psionic signature\s [dst],"
			if(feedback.len > 1)
				feedback[feedback.len - 1] += " and"
			to_chat(user, span_notice("You sense " + jointext(feedback, " ") + " towards the [dir2text(text2num(d))]."))
		if(!length(dirs))
			to_chat(user, span_notice("You detect no psionic signatures but your own."))
