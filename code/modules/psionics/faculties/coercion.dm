#define COGMANIP_HYPNOTIZE "Hypnotize"
#define COGMANIP_ERASE_MEMORY "Erase Memory"
#define COGMANIP_THRALL "Thrall"

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
	name =				"Blindstrike"
	cost =				8
	cooldown =			120
	use_ranged =		TRUE
	use_melee =			TRUE
	min_rank =			PSI_RANK_GRANDMASTER
	use_description =	"Target the eyes or mouth on disarm intent and click anywhere to use a radial attack that blinds, deafens and disorients everyone near you."

/datum/psionic_power/coercion/blindstrike/invoke(var/mob/living/user, var/mob/living/target)
	if(user.zone_selected == BODY_ZONE_PRECISE_MOUTH || user.zone_selected != BODY_ZONE_PRECISE_EYES || (istype(target) && target.pulledby == user))
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
			M.blind_eyes(1 SECONDS)
			M.confused = rand(3,8)
		return TRUE

/datum/psionic_power/coercion/mindread
	name =				"Read Mind"
	cost =				25
	heat =				15
	cooldown =			25 SECONDS //It should take a WHILE to be able to use this again.
	use_melee =			TRUE
	min_rank =			PSI_RANK_MASTER
	use_description =	"Target the head on disarm intent at melee range to attempt to read a victim's surface thoughts."

/datum/psionic_power/coercion/mindread/invoke(var/mob/living/user, var/mob/living/target)
	if(!istype(target) || target == user || user.zone_selected != BODY_ZONE_HEAD || target.pulledby == user)
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
	name =				"Agony"
	cost =				20
	heat =				15
	cooldown =			7 SECONDS
	use_melee =			TRUE
	min_rank =			PSI_RANK_OPERANT
	use_description =	"Target the chest or groin on disarm intent to use a melee attack equivalent to a strike from a stun baton."

/datum/psionic_power/coercion/agony/invoke(var/mob/living/user, var/mob/living/target)
	if(!istype(target))
		return FALSE
	if(user.zone_selected != BODY_ZONE_CHEST && user.zone_selected != BODY_ZONE_PRECISE_GROIN)
		return FALSE
	. = ..()
	if(.)
		user.visible_message("<span class='danger'>\The [target] has been struck by \the [user]!</span>")
		playsound(user.loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
		target.apply_damage(10 * (user.psi.get_rank(PSI_COERCION) - 1), STAMINA, BODY_ZONE_CHEST)
		return TRUE

/datum/psionic_power/coercion/spasm
	name =				"Spasm"
	cost =				15
	cooldown =			100
	use_melee =			TRUE
	use_ranged =		TRUE
	min_rank =			PSI_RANK_MASTER
	use_description =	"Target the arms or hands on disarm intent to use a ranged attack that may rip the weapons away from the target."

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

/datum/psionic_power/coercion/cognitivemanipulation
	name =				"Cognitive Manipulation"
	cost =				28
	cooldown =			20 SECONDS
	use_melee =			TRUE
	min_rank =			PSI_RANK_OPERANT
	use_description =	"Grab a victim, target the eyes, then attack them while on disarm intent, in order to manipulate their mind. The process takes some time, and failure is punished harshly."

/datum/psionic_power/coercion/cognitivemanipulation/invoke(var/mob/living/user, var/mob/living/target)
	if(!istype(target) || user.zone_selected != BODY_ZONE_PRECISE_EYES || target.pulledby != user)
		message_admins("A")
		return FALSE
	. = ..()
	if(.)
		message_admins("B")
		if(target.stat == DEAD || HAS_TRAIT(target, TRAIT_FAKEDEATH))
			to_chat(user, span_warning("\The [target] is dead!"))
			return TRUE
		user.visible_message(span_danger("\The [user] seizes the head of \the [target] in both hands..."))

		var/coercion_rank = user.psi.get_rank(PSI_COERCION)
		var/target_coercion_rank = PSI_RANK_BLUNT
		if(target.psi)
			target_coercion_rank = target.psi.get_rank(PSI_COERCION)
		var/relative_coercion_rank = target_coercion_rank ? coercion_rank - target_coercion_rank : coercion_rank
		message_admins(relative_coercion_rank)

		var/list/radial_list = list()
		var/radial_icon = 'icons/mob/screen_psi.dmi'

		if(coercion_rank >= PSI_RANK_OPERANT)
			var/datum/radial_menu_choice/choice = new
			choice.image = icon(radial_icon, "hypnotise")
			choice.info = "Make the target temporarily subject to a hypnosis-like effect, making them easily influenced by spoken words."
			radial_list[COGMANIP_HYPNOTIZE] = choice
			message_admins(COGMANIP_HYPNOTIZE)

		if(coercion_rank >= PSI_RANK_GRANDMASTER)
			var/datum/radial_menu_choice/choice = new
			choice.image = icon(radial_icon, "erase")
			choice.info = "Rewrite the targets mind to remove a specific memory, which can cure them of related ailments."
			radial_list[COGMANIP_ERASE_MEMORY] = choice
			message_admins(COGMANIP_ERASE_MEMORY)

		if(coercion_rank >= PSI_RANK_PARAMOUNT)
			var/datum/radial_menu_choice/choice = new
			choice.image = icon(radial_icon, "thrall")
			choice.info = "Make the target a subservient thrall to your will."
			radial_list[COGMANIP_THRALL] = choice
			message_admins(COGMANIP_THRALL)

		if(!radial_list.len)
			return TRUE

		var/choice = show_radial_menu(user, target, radial_list, require_near = TRUE, tooltips = TRUE)

		if(!(choice in radial_list))
			return TRUE

		var/mob/living/carbon/C = target
		// So much text
		if(relative_coercion_rank < PSI_RANK_OPERANT || (relative_coercion_rank == PSI_RANK_OPERANT && (istype(C) && !C.hypnosis_vulnerable())))
			to_chat(user, span_warning("[target] mind is too strong to hypnotize them!"))
			if(target_coercion_rank >= PSI_RANK_OPERANT)
				to_chat(target, span_warning("Your mind is invaded by the presence of \the [user], but you manage to [relative_coercion_rank == 1 ? "barely " :""]repel the attack!"))
			else if(target_coercion_rank == PSI_RANK_LATENT)
				to_chat(target, span_notice("Your somehow feel [user]'s presence in your head and something in your head holding strong."))
			else
				// Non-psionics have no clue what is going on, but they should still have some indication of whats is happening
				to_chat(target, span_notice("Your feel a strange sensation in your head."))
			return TRUE
		if(target_coercion_rank >= PSI_RANK_OPERANT)
			to_chat(target, span_warning("Your mind is invaded by the presence of \the [user], and your mental barriers [relative_coercion_rank > 1 ? "shatter like glass" : "fail"]!"))
			to_chat(user, span_notice("You manage to [relative_coercion_rank > 1 ? "easily " : ""]push through [target]'s mental barriers and start working on the task at hand."))
		else if(target_coercion_rank == PSI_RANK_LATENT)
			to_chat(target, span_notice("Your somehow feel [user]'s presence in your head and something in your head failing."))
			to_chat(user, span_notice("You manage to [relative_coercion_rank > 1 ? "easily " : ""]push through [target]'s amiture defenses and start working on the task at hand."))
		else
			to_chat(target, span_notice("Your feel a strange sensation in your head."))

		switch(choice)
			if(COGMANIP_HYPNOTIZE)
				if(!do_after(user, 30 SECONDS, target, FALSE))
					user.psi.backblast(rand(1, 5))
					return TRUE
				to_chat(user, span_danger("You surgicaly rearange \the [target]'s neurons, leaving [target.p_them()] easily influinced by the next thing [target.p_they()] hear. Choice you next words carefuly..."))
				target.apply_status_effect(/datum/status_effect/trance, relative_coercion_rank * 10 SECONDS, relative_coercion_rank >= 2)

			if(COGMANIP_ERASE_MEMORY)
				if(!do_after(user, 30 SECONDS, target, FALSE))
					user.psi.backblast(rand(1, 5))
					return TRUE
				var/lost_memory = pretty_filter(stripped_input(user, "What would you like [target] to forget?", "Cognative Manipulation"))
				to_chat(user, span_danger("You surgicaly cut \the [target]'s hippocampus, removing every shread of memory surounding the phrase \"[lost_memory]\"."))
				to_chat(target, "<span class='reallybig hypnophrase'>[lost_memory]</span>")
				to_chat(target, span_warning("You can't remember anything surounding that phrase!"))

			if(COGMANIP_THRALL)
				if(!target.mind || !target.key)
					to_chat(user, span_warning("\The [target] is mindless!"))
					return TRUE
				to_chat(user, span_warning("You plunge your mentality into that of \the [target]..."))
				if(!do_after(user, target.stat == CONSCIOUS ? 2 MINUTES : 1 MINUTES, target, FALSE))
					user.psi.backblast(rand(10,25))
					return TRUE
				to_chat(user, span_danger("You sear through \the [target]'s neurons, reshaping as you see fit and leaving them subservient to your will!"))
				to_chat(target, span_danger("Your defenses have eroded away and \the [user] has made you their mindslave."))
				var/datum/antagonist/thrall/T = new()
				T.master = user.mind
				target.mind.add_antag_datum(T)
		return TRUE

/datum/psionic_power/coercion/assay
	name =				"Assay"
	cost =				15
	cooldown =			10 SECONDS
	use_melee =			TRUE
	min_rank =			PSI_RANK_OPERANT
	use_description =	"Grab a patient, target the head, then use the grab on them while on disarm intent, in order to perform a deep coercive-redactive probe of their psionic potential."

/datum/psionic_power/coercion/assay/invoke(var/mob/living/user, var/mob/living/target)
	if(!istype(target) || user.zone_selected != BODY_ZONE_HEAD || target.pulledby != user || user == target)
		return FALSE
	. = ..()
	if(.)
		user.visible_message(span_warning("\The [user] holds the head of \the [target] in both hands..."))
		to_chat(user, span_notice("You insinuate your mentality into that of \the [target]..."))
		to_chat(target, span_warning("Your persona is being probed by the psychic lens of \the [user]."))
		if(!do_after(user, (target.stat == CONSCIOUS ? 50 : 25), target, FALSE))
			user.psi.backblast(rand(5,10))
			return TRUE
		to_chat(user, span_notice("You retreat from \the [target], holding your new knowledge close."))
		to_chat(target, span_danger("Your mental complexus is laid bare to judgement of \the [user]."))
		target.show_psi_assay(user)
		return TRUE

/datum/psionic_power/coercion/focus
	name =				"Focus"
	cost =				10
	cooldown =			8 SECONDS
	use_melee =			TRUE
	min_rank =			PSI_RANK_MASTER
	use_description =	"Grab a patient, target the mouth, then use the grab on them while on disarm intent, in order to cure ailments of the mind."

/datum/psionic_power/coercion/focus/invoke(var/mob/living/user, var/mob/living/target)
	if(user.zone_selected != BODY_ZONE_PRECISE_MOUTH || target.pulledby != user)
		return FALSE
	. = ..()
	if(.)
		user.visible_message(span_warning("\The [user] holds the head of \the [target] in both hands..."))
		to_chat(user, span_notice("You probe \the [target]'s mind for various ailments.."))
		to_chat(target, span_warning("Your mind is being cleansed of ailments by \the [user]."))
		if(!do_after(user, (target.stat == CONSCIOUS ? 5 SECONDS : 2.5 SECONDS), target, FALSE))
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
	name =				"Commune"
	cost =				10
	cooldown =			8 SECONDS
	use_melee =			TRUE
	use_ranged =		TRUE
	min_rank =			PSI_RANK_OPERANT
	use_description =	"Target the mouth and click on a creature on disarm intent to psionically send them a message."

/datum/psionic_power/coercion/commune/invoke(var/mob/living/user, var/mob/living/target)
	if(user.zone_selected != BODY_ZONE_PRECISE_MOUTH || user == target)
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
		if(prob(25) && (target.mind && target.mind.assigned_role == "Chaplain"))
			to_chat(H,"<b>You sense [user]'s psyche enter your mind, whispering quietly:</b> [text]")
		else
			to_chat(H,"<b>You feel something crawl behind your eyes, hearing:</b> [text]")
			if(istype(H))
				if(prob(10) && !(H.dna.species.species_traits & NOBLOOD))
					to_chat(H,"<span class='warning'>Your nose begins to bleed...</span>")
					H.add_splatter_floor(small_drip = TRUE)
				else if(prob(25))
					to_chat(H,"<span class='warning'>Your head hurts...</span>")
				else if(prob(50))
					to_chat(H,"<span class='warning'>Your mind buzzes...</span>")

/datum/psionic_power/coercion/psiping
	name =				"Psi-ping"
	cost =				30
	cooldown =			25 SECONDS
	use_melee =			TRUE
	min_rank =			PSI_RANK_OPERANT
	use_description =	"Click on yourself with an empty hand on disarm intent to detect nearby psionic signatures."

/datum/psionic_power/coercion/psiping/invoke(var/mob/living/user, var/mob/living/target)
	if((target && user != target))
		return FALSE
	. = ..()
	if(.)
		to_chat(user, "<span class='notice'>You take a moment to tune into the local Nlom...</span>")
		if(!do_after(user, 3 SECONDS, user))
			return
		var/list/dirs = list()
		for(var/mob/living/L in range(20))
			var/turf/T = get_turf(L)
			if(!T || L == user || L.stat == DEAD || issilicon(L))
				continue
			/*
			var/image/ping_image = image(icon = 'icons/effects/effects.dmi', icon_state = "sonar_ping", loc = user)
			ping_image.plane = LIGHTING_LAYER+1
			ping_image.layer = LIGHTING_LAYER+1
			ping_image.pixel_x = (T.x - user.x) * 32
			ping_image.pixel_y = (T.y - user.y) * 32
			user << ping_image
			addtimer(CALLBACK(GLOBAL_PROC, /proc/qdel, ping_image), 8)
			*/
			var/direction = num2text(get_dir(user, L))
			var/dist
			if(text2num(direction))
				switch(get_dist(user, L))
					if(0 to 10)
						dist = "very close"
					if(10 to 20)
						dist = "close"
					if(20 to 30)
						dist = "a little ways away"
					if(30 to 40)
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
