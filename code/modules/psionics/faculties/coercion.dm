#define COGMANIP_HYPNOTIZE "Hypnotize"
#define COGMANIP_ERASE_MEMORY "Erase Memory"
#define COGMANIP_THRALL "Thrall"

/datum/psionic_faculty/coercion
	id = PSI_COERCION
	name = "Coercion"

/datum/psionic_power/coercion
	faculty = PSI_COERCION

/datum/psionic_power/coercion/commune
	name =				"Commune"
	cost =				10
	cooldown =			5 SECONDS
	min_rank =			PSI_RANK_OPERANT
	icon_state = "coe_commune"
	use_description =	"Activate the power with z, then click on a creature on to psionically send them a message."

/datum/psionic_power/coercion/commune/invoke(var/mob/living/user, var/mob/living/target, proximity, parameters)
	if(!istype(target) || user == target || isipc(target))
		return FALSE
	. = ..()
	if(.)
		user.visible_message("<i><span class='notice'>[user] touches their fingers to their temple.</span></i>")
		var/text = pretty_filter(stripped_input(user, "What would you like to say?", "Speak to creature", null, null))

		if(!text)
			return

		if(target.stat == DEAD)
			to_chat(user, span_cult("Not even a psion of your level can speak to the dead."))
			return TRUE

		if (issilicon(target)) 
			to_chat(user, span_warning("This can only be used on living organisms."))
			return TRUE

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

/datum/psionic_power/coercion/assay
	name =				"Assay"
	cost =				15
	cooldown =			5 SECONDS
	min_rank =			PSI_RANK_OPERANT
	icon_state = "coe_assay"
	use_description =	"Activate the power with z, then click on a target in order to perform a deep coercive-redactive probe of their psionic potential."

/datum/psionic_power/coercion/assay/invoke(var/mob/living/user, var/mob/living/target, proximity, parameters)
	if(!istype(target) || user == target || isipc(target))
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

/datum/psionic_power/coercion/psiping
	name =				"Psi-ping"
	cost =				30
	cooldown =			20 SECONDS
	min_rank =			PSI_RANK_OPERANT
	icon_state = "coe_psiping"
	use_description =	"Activate the power with z, then click on yourself with an empty hand to detect nearby psionic signatures."
	var/searching = FALSE

/datum/psionic_power/coercion/psiping/invoke(mob/living/user, mob/living/target, proximity, parameters)
	if(user != target || searching)
		return FALSE
	. = ..()
	if(.)
		to_chat(user, span_notice("You take a moment to tune into the local Nlom..."))
		searching = TRUE
		if(!do_after(user, 3 SECONDS, user))
			searching = FALSE
			return FALSE 
		searching = FALSE
		var/list/dirs = list()
		for(var/mob/living/L in range(20))
			var/turf/T = get_turf(L)
			if(!T || L == user || L.stat == DEAD || issilicon(L) || !L.psi)
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
			var/direction = num2text(angle2dir(Get_Angle(user, L)))
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
		if(length(dirs))
			var/list/feedback = list()
			feedback += "You sense..."
			for(var/d in dirs)
				feedback += "[capitalize(dir2text(text2num(d)))]:"
				for(var/dst in dirs[d])
					feedback += "[dirs[d][dst]] psionic signature\s [dst]."
			
			to_chat(user, span_notice(feedback.Join("<br>")))
		else
			to_chat(user, span_notice("You detect no psionic signatures but your own."))
		return TRUE

/datum/psionic_power/coercion/invoke(mob/living/user, mob/living/target, proximity, parameters)
	if (!istype(target))
		to_chat(user, span_warning("You cannot mentally attack \the [target]."))
		return FALSE
	. = ..()

/datum/psionic_power/coercion/agony
	name =				"Agony"
	cost =				20
	heat =				20
	cooldown =			5 SECONDS
	min_rank =			PSI_RANK_OPERANT
	icon_state = "coe_agony"
	use_description =	"Activate the power with z, attack someone while in combat mode to deal minor stamina damage. Higher psi levels augment the damage done."

/datum/psionic_power/coercion/agony/invoke(mob/living/user, mob/living/target, proximity, parameters)
	if(!istype(target) || !proximity || user == target || !user.combat_mode || isipc(target))
		return FALSE
	. = ..()
	if(.)
		user.visible_message("<span class='danger'>\The [target] has been struck by \the [user]!</span>")
		playsound(user.loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
		target.apply_damage(20 * (user.psi.get_rank(PSI_COERCION) - 1), STAMINA, BODY_ZONE_CHEST)
		return TRUE

/datum/psionic_power/coercion/spasm
	name =				"Spasm"
	cost =				15
	cooldown =			10 SECONDS
	min_rank =			PSI_RANK_MASTER
	icon_state = "coe_spasm"
	use_description =	"Activate the power with z, then target a creature to use a ranged attack that may rip the weapons away from the target."

/datum/psionic_power/coercion/spasm/invoke(mob/living/user, mob/living/carbon/human/target, proximity, parameters)
	if(!istype(target) || user == target || !user.combat_mode || isipc(target))
		return FALSE

	. = ..()

	if(.)
		to_chat(user, span_danger("You lash out, stabbing into \the [target] with a lance of psi-power."))
		to_chat(target, span_danger("The muscles in your arms cramp horrendously!"))
		if(prob(75))
			target.emote("scream")
		if(prob(75) && target.held_items[1] && target.dropItemToGround(target.get_item_for_held_index(1)))
			target.visible_message(span_danger("\The [target] drops what they were holding as their left hand spasms!"))
		if(prob(75) && target.held_items[2] && target.dropItemToGround(target.get_item_for_held_index(2)))
			target.visible_message(span_danger("\The [target] drops what they were holding as their right hand spasms!"))
		return TRUE

/datum/psionic_power/coercion/focus
	name =				"Focus"
	cost =				10
	cooldown =			8 SECONDS
	min_rank =			PSI_RANK_MASTER
	icon_state = "coe_focus"
	use_description =	"Activate the power with z, then click on someone in order to cure ailments of the mind."

/datum/psionic_power/coercion/focus/invoke(mob/living/user, mob/living/target, proximity, parameters)
	if(!istype(target) || !proximity || user == target || isipc(target))
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

		var/resilience = TRAUMA_RESILIENCE_BASIC
		var/coercion_rank = user.psi.get_rank(PSI_COERCION)
		if(coercion_rank >= PSI_RANK_GRANDMASTER)
			target.SetParalyzed(0)
			resilience = TRAUMA_RESILIENCE_SURGERY
		if(coercion_rank >= PSI_RANK_PARAMOUNT)
			target.SetAllImmobility(0)
			resilience = TRAUMA_RESILIENCE_LOBOTOMY
		target.SetDaze(0)
		if(istype(target, /mob/living/carbon))
			var/mob/living/carbon/M = target
			M.cure_trauma_type(resilience = resilience)
			M.adjust_hallucinations(10 SECONDS)
		return TRUE

/datum/psionic_power/coercion/mindread
	name =				"Read Mind"
	cost =				25
	heat =				15
	cooldown =			25 SECONDS //It should take a WHILE to be able to use this again.
	min_rank =			PSI_RANK_MASTER
	icon_state = "coe_mindread"
	use_description =	"Activate the power with z, then click on someone in melee range to attempt to read a victim's surface level thoughts."

/datum/psionic_power/coercion/mindread/invoke(var/mob/living/user, var/mob/living/target, proximity, parameters)
	if(!istype(target) || target == user || !proximity || isipc(target))
		return FALSE
	. = ..()
	if(!.)
		return

	if(target.stat == DEAD || (HAS_TRAIT(target, TRAIT_FAKEDEATH)) || !target.client)
		to_chat(user, span_warning("\The [target] is in no state for a mind-read."))
		return FALSE

	user.visible_message(span_warning("\The [user] touches \the [target]'s temple..."))
	var/question =  input(user, "Say something?", "Read Mind", "Penny for your thoughts?") as null|text
	if(!question || user.incapacitated() || !do_after(user, 20))
		return TRUE

	var/started_mindread = world.time
	to_chat(user, span_notice("<b>You dip your mentality into the surface layer of \the [target]'s mind, seeking an answer: <i>[question]</i></b>"))
	to_chat(target, span_hypnophrase("<b>Your mind is compelled to answer: <i>[question]</i></b>")) // I wonder how this will go down with the playerbase

	var/answer =  input(target, question, "Read Mind") as null|text
	if(!answer || world.time > started_mindread + 25 SECONDS || user.stat != CONSCIOUS || target.stat == DEAD)
		to_chat(user, span_notice("<b>You receive nothing useful from \the [target].</b>"))
	else
		to_chat(user, span_notice("<b>You skim thoughts from the surface of \the [target]'s mind: <i>[answer]</i></b>"))
	log_game("[key_name(user)] read mind of [key_name(target)] with question \"[question]\" and [answer? "got answer \"[answer]\".":"got no answer."]")
	return TRUE

/datum/psionic_power/coercion/blindstrike
	name =				"Blindstrike"
	cost =				8
	cooldown =			12 SECONDS
	min_rank =			PSI_RANK_GRANDMASTER
	icon_state = "coe_blindstrike"
	use_description =	"Activate the power with z, then click anywhere to use a radial attack that blinds, deafens and disorients everyone near you."

/datum/psionic_power/coercion/blindstrike/invoke(var/mob/living/user, var/mob/living/target, proximity, parameters)
	if(isipc(target))
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
			M.adjust_confusion(10 SECONDS)
		return TRUE

/datum/psionic_power/coercion/dis_arm
	name =				"Dis-Arm"
	cost =				10
	cooldown =			12 SECONDS
	min_rank =			PSI_RANK_PARAMOUNT
	icon_state = "coe_disarm"
	use_description =	"Activate the power with z, then click your target with combat mode to Psionically rip their arms off."

/datum/psionic_power/coercion/dis_arm/invoke(var/mob/living/user, var/mob/living/target, proximity, parameters)
	if(!user.combat_mode || isipc(target))
		return FALSE
	. = ..()
	if(.)
		user.visible_message(span_danger("\The [user] grows two psionic arms, ripping [target]'s arms off!"))
		to_chat(user, span_danger("You channel your full mental might into ripping and tearing!"))
		var/mob/living/carbon/CM = target
		for(var/obj/item/bodypart/bodypart in CM.bodyparts)
			if(!(bodypart.body_part & (HEAD|CHEST|LEGS)))
				if(bodypart.dismemberable)
					bodypart.dismember()
		return TRUE
