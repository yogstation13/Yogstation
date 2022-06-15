/mob/living/simple_animal/horror
	name = "eldritch horror"
	desc = "Your eyes can barely comprehend what they're looking at."
	icon_state = "horror"
	icon_living = "horror"
	icon_dead = "horror_dead"
	icon_gib = "horror_gib"
	health = 50
	maxHealth = 50
	melee_damage_lower = 10
	melee_damage_upper = 10
	see_in_dark = 5
	stop_automated_movement = TRUE
	attacktext = "bites"
	speak_emote = list("gurgles")
	attack_sound = 'sound/weapons/bite.ogg'
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	faction = list("neutral","silicon","creature","heretics","abomination")
	ventcrawler = VENTCRAWLER_ALWAYS
	initial_language_holder = /datum/language_holder/universal
	hud_type = /datum/hud/chemical_counter

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	unsuitable_atmos_damage = 0.5

	var/playstyle_string = span_bold(span_big("You are an eldritch horror,") + " an evermutating parasitic abomination. Seek human souls to consume. \
							Crawl into people's heads and steal their essence. Use it to mutate yourself, giving you access to more power and abilities. \
							You operate on chemicals that get built up while you spend time in someone's head. You are weak when outside, play carefully. \
							You can attack airlocks to squeeze yourself through them. " + span_danger("Alt+Click on people to infest them."))

	var/mob/living/carbon/victim
	var/datum/mind/target
	var/mob/living/captive_brain/host_brain
	var/available_points = 4
	var/consumed_souls = 0

	//An associative list (associated by ability typepaths) containing the abilities the horror has
	var/list/horrorabilities = list()
	//same (associated by their ID), but for permanent upgrades
	var/list/horrorupgrades = list()
	//list storing what items we have to un-glue when stopping mind control
	var/list/clothing = list()

	var/bonding = FALSE
	var/controlling = FALSE
	var/chemicals = 10
	var/chem_regen_rate = 2
	var/used_freeze
	var/used_target
	var/horror_chems = list(/datum/horror_chem/epinephrine,/datum/horror_chem/mannitol,/datum/horror_chem/bicaridine,/datum/horror_chem/kelotane,/datum/horror_chem/charcoal)

	var/leaving = FALSE
	var/hiding = FALSE
	var/invisible = FALSE
	var/datum/action/innate/horror/talk_to_horror/talk_to_horror_action = new

/mob/living/simple_animal/horror/Initialize(mapload, gen=1)
	..()
	real_name = "[pick(GLOB.horror_names)]"

	//default abilities
	add_ability(/datum/action/innate/horror/mutate)
	add_ability(/datum/action/innate/horror/seek_soul)
	add_ability(/datum/action/innate/horror/consume_soul)
	add_ability(/datum/action/innate/horror/talk_to_host)
	add_ability(/datum/action/innate/horror/freeze_victim)
	add_ability(/datum/action/innate/horror/toggle_hide)
	add_ability(/datum/action/innate/horror/talk_to_brain)
	add_ability(/datum/action/innate/horror/take_control)
	add_ability(/datum/action/innate/horror/leave_body)
	add_ability(/datum/action/innate/horror/make_chems)
	add_ability(/datum/action/innate/horror/give_back_control)
	RefreshAbilities()

	var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	hud.add_hud_to(src)
	update_horror_hud()


/mob/living/simple_animal/horror/Destroy()
	host_brain = null
	victim = null
	return ..()

//Yogs -- slightly fancier examine
/mob/living/simple_animal/horror/examine(mob/user) // Return a more... positive description when the examiner is themselves an eldritch horror.
	if(user == src) // Hey, that's me!
		return list("[icon2html(src, user)] That's [src.real_name], \a [initial(src.name)].","I'm so beautiful!")
	else if(ishorror(user))
		return list("[get_examine_string(user, TRUE)].","What a handsome rogue.")
	else
		return ..()
//Yogs end
	
/mob/living/simple_animal/horror/AltClickOn(atom/A)
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if(!C || QDELETED(src) || !Adjacent(C) || victim || !can_use_ability())
			return
		if(victim)
			to_chat(src, span_warning("You are already within a host."))
			return

		to_chat(src, span_warning("You slither your tentacles up [C] and begin probing at [C.p_their()] ear canal...")) // Yogs -- pronouns

		if(!do_mob(src, C, 4 SECONDS))
			to_chat(src, span_warning("As [C] moves away, you are dislodged and fall to the ground."))
			return

		if(!C || QDELETED(src))
			return
		if(C.has_horror_inside())
			to_chat(src, span_warning("[C] is already infested!"))
			return
		Infect(C)
		return
	..()

/mob/living/simple_animal/horror/proc/has_chemicals(amt)
	return chemicals >= amt

/mob/living/simple_animal/horror/proc/use_chemicals(amt)
	if(!has_chemicals(amt))
		return FALSE
	chemicals -= amt
	update_horror_hud()
	return TRUE

/mob/living/simple_animal/horror/proc/regenerate_chemicals(amt)
	chemicals += amt
	chemicals = min(250, chemicals)
	update_horror_hud()

/mob/living/simple_animal/horror/proc/update_horror_hud()
	if(!src || !hud_used)
		return
	var/datum/hud/chemical_counter/H = hud_used
	var/obj/screen/counter = H.chemical_counter
	counter.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#7264FF'>[chemicals]</font></div>"

/mob/living/simple_animal/horror/proc/can_use_ability()
	if(stat != CONSCIOUS)
		to_chat(src, "You cannot do that in your current state.")
		return FALSE
	return TRUE

/mob/living/simple_animal/horror/proc/SearchTarget()
	if(target)
		if(world.time - used_target < 3 MINUTES)
			to_chat(src, span_warning("You cannot use that ability again so soon."))
			return
		if(alert("You already have a target ([target.name]). Would you like to change that target?","Swap targets?","Yes","No") != "Yes")
			return

	var/list/possible_targets = list()
	for(var/datum/mind/M in SSticker.minds)
		if(M.current && M.current.stat != DEAD)
			if(ishuman(M.current))
				if(M.hasSoul && (mind.enslaved_to != M.current))
					possible_targets[M] = M

	var/list/selected_targets = list()
	var/list/icons = list()
	while(selected_targets.len != 4)
		if(possible_targets.len <= 0)
			break
		var/datum/mind/M = pick(possible_targets)
		selected_targets[M] = M
		possible_targets -= M

		var/mob/living/carbon/human/H = M.current
		icons[M] = H

	used_target = world.time

	var/entry_name = show_radial_menu(src, (victim ? src.loc : src), icons, tooltips = TRUE)
	target = selected_targets[entry_name]

	//you didn't select your target? let me do that for you, my friend
	if(selected_targets.len > 0 && !target)
		target = pick(selected_targets)

	if(target)
		to_chat(src, span_warning("You caught [target.p_their()] scent. Go and consume [target.current.real_name], the [target.assigned_role]'s soul!"))//Yogs -- pronoun police, open up
		apply_status_effect(/datum/status_effect/agent_pinpointer/horror)
		for(var/datum/status_effect/agent_pinpointer/horror/status in status_effects)
			status.scan_target = target.current
	else
		//refund cooldown
		used_target = 0
		to_chat(src, span_warning("Failed to select a target!"))

/mob/living/simple_animal/horror/proc/ConsumeSoul()
	if(!can_use_ability())
		return

	if(!victim.mind.hasSoul)
		to_chat(src, "This host doesn't have a soul!")
		return

	if(victim == mind.enslaved_to)
		to_chat(src, span_userdanger("No, not yet... We still need them..."))
		return

	if(victim.mind != target)
		to_chat(src, "This soul isn't your target, you can't consume it!")
		return

	to_chat(src, "You begin consuming [victim.name]'s soul!")
	if(do_after(src, 30 SECONDS, victim, stayStill = FALSE))
		consume()

/mob/living/simple_animal/horror/proc/consume()
	if(!can_use_ability() || !victim || !victim.mind.hasSoul || victim.mind != target)
		return
	consumed_souls++
	available_points++
	to_chat(src, span_userdanger("You succeed in consuming [victim.name]'s soul!"))
	to_chat(victim, span_userdanger("You suddenly feel weak and hollow inside..."))
	victim.health -= 20
	victim.maxHealth -= 20
	victim.mind.hasSoul = FALSE
	target = null
	remove_status_effect(/datum/status_effect/agent_pinpointer/horror)
	playsound(src, 'sound/effects/curseattack.ogg', 150)
	playsound(src, 'sound/effects/ghost.ogg', 50)

/mob/living/simple_animal/horror/proc/Communicate()
	if(!can_use_ability())
		return
	if(!victim)
		to_chat(src, "You do not have a host to communicate with!")
		return

	var/input = stripped_input(src, "Please enter a message to tell your host.", "Horror", null)
	if(!input)
		return

	if(src && !QDELETED(src) && !QDELETED(victim))
		if(victim)
			to_chat(victim, span_changeling("<i>[real_name] slurs:</i> [input]"))
			for(var/M in GLOB.dead_mob_list)
				if(isobserver(M))
					var/rendered = span_changeling("<i>Horror Communication from <b>[real_name]</b> : [input]</i>")
					var/link = FOLLOW_LINK(M, src)
					to_chat(M, "[link] [rendered]")
		to_chat(src, span_changeling("<i>[real_name] slurs:</i> [input]"))
		add_verb(victim, /mob/living/proc/horror_comm)
		talk_to_horror_action.Grant(victim)

/mob/living/proc/horror_comm()
	set name = "Converse with Horror"
	set category = "Horror"
	set desc = "Communicate mentally with the thing in your head."

	var/mob/living/simple_animal/horror/B = has_horror_inside()
	if(B)
		var/input = stripped_input(src, "Please enter a message to tell the horror.", "Message", "")
		if(!input)
			return

		to_chat(B, span_changeling("<i>[real_name] says:</i> [input]"))

		for(var/M in GLOB.dead_mob_list)
			if(isobserver(M))
				var/rendered = span_changeling("<i>Horror Communication from <b>[real_name]</b> : [input]</i>")
				var/link = FOLLOW_LINK(M, src)
				to_chat(M, "[link] [rendered]")
		to_chat(src, span_changeling("<i>[real_name] says:</i> [input]"))

/mob/living/proc/trapped_mind_comm()
	var/mob/living/simple_animal/horror/B = has_horror_inside()
	if(!B || !B.host_brain)
		return
	var/mob/living/captive_brain/CB = B.host_brain
	var/input = stripped_input(src, "Please enter a message to tell the trapped mind.", "Message", null)
	if(!input)
		return

	to_chat(CB, span_changeling("<i>[B.real_name] says:</i> [input]"))

	for(var/M in GLOB.dead_mob_list)
		if(isobserver(M))
			var/rendered = span_changeling("<i>Horror Communication from <b>[B.real_name]</b> : [input]</i>")
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")
	to_chat(src, span_changeling("<i>[B.real_name] says:</i> [input]"))

/mob/living/simple_animal/horror/Life()
	..()
	if(has_upgrade("regen"))
		heal_overall_damage(5)

	if(invisible) //don't regenerate chemicals when invisible
		if(use_chemicals(5))
			alpha = max(alpha - 100, 1)
		else
			to_chat(src, span_warning("You ran out of chemicals to support your invisibility."))
			invisible = FALSE
			Update_Invisibility_Button()
	else
		if(has_upgrade("nohost_regen"))
			regenerate_chemicals(chem_regen_rate)
		else if(victim)
			if(victim.stat == DEAD)
				regenerate_chemicals(1)
			else
				regenerate_chemicals(chem_regen_rate)
	alpha = min(255, alpha + 50)

	if(victim)
		if(stat != DEAD && victim.stat != DEAD)
			heal_overall_damage(1)

/mob/living/simple_animal/horror/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(victim)
		to_chat(src, span_warning("You cannot speak out loud while inside a host!"))
		return
	return ..()

/mob/living/simple_animal/horror/emote(act, m_type = null, message = null, intentional = FALSE)
	if(victim)
		to_chat(src, span_warning("You cannot emote while inside a host!"))
		return
	return ..()

/mob/living/simple_animal/horror/UnarmedAttack(atom/A)
	if(istype(A, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/door = A
		if(door.welded)
			to_chat(src, span_danger("The door is welded shut!"))
			return
		visible_message(span_warning("[src] slips their tentacles into the airlock and starts prying it open!"), span_warning("You start moving onto the airlock."))
		playsound(A, 'sound/misc/splort.ogg', 50, 1)
		if(do_after(src, 5 SECONDS, A))
			if(door.welded)
				to_chat(src, span_danger("The door is welded shut!"))
				return
			visible_message(span_warning("[src] forces themselves through the airlock!"), span_warning("You force yourself through the airlock"))
			forceMove(get_turf(A))
			playsound(A, 'sound/machines/airlock_alien_prying.ogg', 50, 1)
			return

	if(isliving(A))
		if(victim || A == src.mind.enslaved_to)
			healthscan(usr, A)
			chemscan(usr, A)
		else
			alpha = 255
			if(hiding)
				var/datum/action/innate/horror/H = has_ability(/datum/action/innate/horror/toggle_hide)
				H.Activate()
			if(invisible)
				var/datum/action/innate/horror/H = has_ability(/datum/action/innate/horror/chameleon)
				H.Activate()
			Update_Invisibility_Button()
			..()

/mob/living/simple_animal/horror/ex_act()
	if(victim)
		return

	..()

/mob/living/simple_animal/horror/proc/Infect(mob/living/carbon/C)
	if(!C)
		return
	var/obj/item/bodypart/head/head = C.get_bodypart(BODY_ZONE_HEAD)
	if(!head)
		to_chat(src, span_warning("[C] doesn't have a head!"))
		return
	var/hasbrain = locate(/obj/item/organ/brain) in C.internal_organs

	if(!hasbrain)
		to_chat(src, span_warning("[C] doesn't have a brain!"))
		return

	if(C.has_horror_inside())
		to_chat(src, span_warning("[C] is already infested!"))
		return

	//can only infect non-ssd alive people / corpses with ghosts attached / current target
	if((C.stat == DEAD || !C.key) && (C.stat != DEAD || !C.get_ghost()) && (!target || C != target.current))
		to_chat(src, span_warning("[C]'s mind seems unresponsive. Try someone else!"))
		return

	if(hiding)
		var/datum/action/innate/horror/H = has_ability(/datum/action/innate/horror/toggle_hide)
		H.Activate()
	invisible = FALSE
	Update_Invisibility_Button()

	victim = C
	victim.visible_message(span_warning("[src] enters [victim]'s head!"), span_notice("Something enters your head!"))
	forceMove(victim)
	RefreshAbilities()
	log_game("[src]/([src.ckey]) has infested [victim]/([victim.ckey]")

/mob/living/simple_animal/horror/proc/secrete_chemicals()
	if(!can_use_ability())
		return
	if(!victim)
		to_chat(src, span_warning("You are not inside a host body."))
		return

	var/content = "<p>Chemicals: <span id='chemicals'>[chemicals]</span></p>"
	content += "<table>"

	for(var/path in subtypesof(/datum/horror_chem))
		var/datum/horror_chem/chem = path
		if(path in horror_chems)
			content += "<tr><td><a class='chem-select' href='?_src_=\ref[src];src=\ref[src];horror_use_chem=[initial(chem.chemname)]'>[initial(chem.chemname)] ([initial(chem.chemuse)])</a><p>[initial(chem.chem_desc)]</p></td></tr>"

	content += "</table>"

	var/html = get_html_template(content)

	usr << browse(html, "window=ViewHorror\ref[src]Chems;size=600x800")

/mob/living/simple_animal/horror/proc/hide()
	if(victim)
		to_chat(src, span_warning("You cannot do this while you're inside a host."))
		return

	if(stat != CONSCIOUS)
		return

	if(!hiding)
		layer = LATTICE_LAYER
		visible_message(span_name("[src] scurries to the ground!"), \
						span_noticealien("You are now hiding."))
		hiding = TRUE
	else
		layer = MOB_LAYER
		visible_message("[src] slowly peaks up from the ground...", \
					span_noticealien("You stop hiding."))
		hiding = FALSE

/mob/living/simple_animal/horror/proc/go_invisible()
	if(victim)
		to_chat(src, span_warning("You cannot do this while you're inside a host."))
		return

	if(!can_use_ability())
		return

	if(!has_chemicals(10))
		to_chat(src, span_warning("You don't have enough chemicals to do that."))
		return

	if(!invisible)
		to_chat(src, span_noticealien("You focus your chameleon skin to blend into the environment."))
		invisible = TRUE
	else
		to_chat(src, span_noticealien("You stop your camouflage."))
		invisible = FALSE

/mob/living/simple_animal/horror/proc/freeze_victim()
	if(world.time - used_freeze < 150)
		to_chat(src, span_warning("You cannot use that ability again so soon."))
		return

	if(victim)
		to_chat(src, span_warning("You cannot do that from within a host body."))
		return

	if(!can_use_ability())
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1,src))
		if(C.stat == CONSCIOUS)
			choices += C

	if(!choices.len)
		return

	if(QDELETED(src) || stat != CONSCIOUS || victim || (world.time - used_freeze < 150))
		return

	layer = MOB_LAYER
	for (var/mob/living/carbon/M in range(1, src))
		if(!M || !Adjacent(M))
			return
		if(has_upgrade("paralysis"))
			playsound(loc, "sound/effects/sparks4.ogg", 30, 1, -1)
			M.Stun(50)
			M.SetSleeping(50)  //knocked out cold
			M.Knockdown(70)
			M.electrocute_act(15, src, 1, FALSE, FALSE, FALSE, 1, FALSE)
		else
			to_chat(M, span_userdanger("You feel something wrapping around your leg, pulling you down!"))
			playsound(loc, "sound/weapons/whipgrab.ogg", 30, 1, -1)
			M.Immobilize(50)
			M.Knockdown(70)
	used_freeze = world.time

/mob/living/simple_animal/horror/proc/is_leaving()
	return leaving

/mob/living/simple_animal/horror/proc/release_victim()
	if(!victim)
		to_chat(src, span_danger("You are not inside a host body."))
		return

	if(!can_use_ability())
		return

	if(leaving)
		leaving = FALSE
		to_chat(src, span_danger("You decide against leaving your host."))
		return

	to_chat(src, span_danger("You begin disconnecting from [victim]'s synapses and prodding at [victim.p_their()] internal ear canal.")) //Yogs -- pronouns ~~holy shit dude this is yogs exclusive antag already, why #Chester

	if(victim.stat != DEAD && !has_upgrade("invisible_exit"))
		to_chat(victim, span_userdanger("An odd, uncomfortable pressure begins to build inside your skull, behind your ear..."))

	leaving = TRUE
	if(do_after(src, 10 SECONDS, victim, extra_checks = CALLBACK(src, .proc/is_leaving), stayStill = FALSE))
		release_host()

/mob/living/simple_animal/horror/proc/release_host()
	if(!victim || QDELETED(victim) || QDELETED(src) || controlling)
		return

	if(!can_use_ability())
		return
	else
		to_chat(src, span_danger("You wiggle out of [victim]'s ear and plop to the ground."))
	if(victim.mind)
		if(!has_upgrade("invisible_exit"))
			to_chat(victim, span_danger("Something slimy wiggles out of your ear and plops to the ground!"))

	leaving = FALSE

	leave_victim()

/mob/living/simple_animal/horror/proc/leave_victim()
	if(!victim)
		return

	if(controlling)
		detatch()

	forceMove(get_turf(victim))

	reset_perspective()
	unset_machine()

	victim.reset_perspective()
	victim.unset_machine()

	var/mob/living/V = victim
	remove_verb(V, /mob/living/proc/horror_comm)
	talk_to_horror_action.Remove(victim)

	for(var/obj/item/horrortentacle/T in victim)
		victim.visible_message(span_warning("[victim]'s tentacle transforms back!"), span_notice("Your tentacle disappears!"))
		playsound(victim, 'sound/effects/blobattack.ogg', 30, 1)
		qdel(T)
	victim = null

	RefreshAbilities()


/mob/living/simple_animal/horror/proc/jumpstart()
	if(!victim)
		to_chat(src, span_warning("You need a host to be able to use this."))
		return

	if(!can_use_ability())
		return

	if(victim.stat != DEAD)
		to_chat(src, span_warning("Your host is already alive!"))
		return

	if(!has_chemicals(250))
		to_chat(src, span_warning("You need 250 chemicals to use this!"))
		return

	if(HAS_TRAIT_FROM(target, TRAIT_BADDNA, CHANGELING_DRAIN))
		to_chat(src, span_warning("Their DNA is completely destroyed! You can't revive them"))
		return

	if(victim.stat == DEAD)
		playsound(src, 'sound/machines/defib_charge.ogg', 50, 1, -1)
		sleep(1 SECONDS)
		victim.tod = null
		victim.setToxLoss(0)
		victim.setOxyLoss(0)
		victim.setCloneLoss(0)
		victim.SetUnconscious(0)
		victim.SetStun(0)
		victim.SetKnockdown(0)
		victim.radiation = 0
		victim.heal_overall_damage(victim.getBruteLoss(), victim.getFireLoss())
		victim.reagents.clear_reagents()
		if(HAS_TRAIT_FROM(victim, TRAIT_HUSK, BURN))
			victim.cure_husk(BURN)
		for(var/organ in victim.internal_organs)
			var/obj/item/organ/O = organ
			O.setOrganDamage(0)
		victim.restore_blood()
		victim.remove_all_embedded_objects()
		victim.revive()
		log_game("[src]/([src.ckey]) has revived [victim]/([victim.ckey]")
		chemicals -= 250
		to_chat(src, span_notice("You send a jolt of energy to your host, reviving them!"))
		victim.grab_ghost(force = TRUE) //brings the host back, no eggscape
		victim.adjustOxyLoss(30)
		to_chat(victim, span_userdanger("You bolt upright, gasping for breath!"))
		victim.electrocute_act(15, src, 1, FALSE, FALSE, FALSE, 1, FALSE)
		playsound(src, 'sound/machines/defib_zap.ogg', 50, 1, -1)


/mob/living/simple_animal/horror/proc/view_memory()
	if(!victim)
		to_chat(src, span_warning("You need a host to be able to use this."))
		return

	if(!can_use_ability())
		return

	if(victim.stat == DEAD)
		to_chat(src, span_warning("Your host brain is unresponsive. [victim.p_they(TRUE)] are dead!")) // Yogs -- pronouns
		return

	if(prob(20))
		to_chat(victim, span_danger("You suddenly feel your memory being tangled with..."))//chance to alert the victim

	if(victim.mind)
		var/datum/mind/suckedbrain = victim.mind
		to_chat(src, span_boldnotice("You skim through [victim]'s memories...[suckedbrain.memory]"))
		for(var/A in suckedbrain.antag_datums)
			var/datum/antagonist/antag_types = A
			var/list/all_objectives = antag_types.objectives.Copy()
			if(antag_types.antag_memory)
				to_chat(src, span_notice("[antag_types.antag_memory]"))
			if(LAZYLEN(all_objectives))
				to_chat(src, span_boldnotice("Objectives:"))
				var/obj_count = 1
				for(var/O in all_objectives)
					var/datum/objective/objective = O
					to_chat(src, span_notice("Objective #[obj_count++]: [objective.explanation_text]"))
					var/list/datum/mind/other_owners = objective.get_owners() - suckedbrain
					if(other_owners.len)
						for(var/mind in other_owners)
							var/datum/mind/M = mind
							to_chat(src, span_notice("Conspirator: [M.name]"))

		var/list/recent_speech = list()
		var/list/say_log = list()
		var/log_source = victim.logging
		for(var/log_type in log_source)
			var/nlog_type = text2num(log_type)
			if(nlog_type & LOG_SAY)
				var/list/reversed = log_source[log_type]
				if(islist(reversed))
					say_log = reverseRange(reversed.Copy())
					break
		if(LAZYLEN(say_log))
			for(var/spoken_memory in say_log)
				if(recent_speech.len >= 5)//up to 5 random lines of speech, favoring more recent speech
					break
				if(prob(50))
					recent_speech[spoken_memory] = say_log[spoken_memory]
		if(recent_speech.len)
			to_chat(src, span_boldnotice("You catch some drifting memories of their past conversations..."))
			for(var/spoken_memory in recent_speech)
				to_chat(src, span_notice("[recent_speech[spoken_memory]]"))
		var/mob/living/carbon/human/H = victim
		var/datum/dna/the_dna = H.has_dna()
		if(the_dna)
			to_chat(src, span_boldnotice("You uncover that [H.p_their()] true identity is [the_dna.real_name]."))

/mob/living/simple_animal/horror/proc/is_bonding()
	return bonding

/mob/living/simple_animal/horror/proc/bond_brain()
	if(!victim)
		to_chat(src, span_warning("You are not inside a host body."))
		return

	if(!can_use_ability())
		return

	if(victim.stat == DEAD)
		to_chat(src, span_notice("This host lacks enough brain function to control."))
		return

	if(victim.has_trauma_type(/datum/brain_trauma/severe/split_personality))
		to_chat(src, span_notice("This host's brain lobe separation makes it too complex for you to control."))
		return

	if(bonding)
		bonding = FALSE
		to_chat(src, span_danger("You stop attempting to take control of your host."))
		return

	to_chat(src, span_danger("You begin delicately adjusting your connection to the host brain..."))

	if(QDELETED(src) || QDELETED(victim))
		return

	bonding = TRUE

	var/delay = 20 SECONDS
	if(has_upgrade("fast_control"))
		delay -= 12 SECONDS
	if(do_after(src, delay, victim, extra_checks = CALLBACK(src, .proc/is_bonding), stayStill = FALSE))
		assume_control()

/mob/living/simple_animal/horror/proc/assume_control()
	if(!victim || !src || controlling || victim.stat == DEAD)
		return
	if(is_servant_of_ratvar(victim) || iscultist(victim))
		to_chat(src, span_warning("[victim]'s mind seems to be blocked by some unknown force!"))
		bonding = FALSE
		return
	if(HAS_TRAIT(victim, TRAIT_MINDSHIELD))
		to_chat(src, span_warning("[victim]'s mind seems to be shielded from your influence!"))
		bonding = FALSE
		return
	else
		RegisterSignal(victim, COMSIG_MOB_APPLY_DAMAGE, .proc/hit_detatch)
		log_game("[src]/([src.ckey]) assumed control of [victim]/([victim.ckey] with eldritch powers.")
		to_chat(src, span_warning("You plunge your probosci deep into the cortex of the host brain, interfacing directly with [victim.p_their()] nervous system.")) // Yogs -- pronouns
		to_chat(victim, span_userdanger("You feel a strange shifting sensation behind your eyes as an alien consciousness displaces yours."))

		clothing = victim.get_equipped_items()
		for(var/obj/item/I in clothing)
			ADD_TRAIT(I, TRAIT_NODROP, HORROR_TRAIT)

		qdel(host_brain)
		host_brain = new(src)
		host_brain.H = src
		host_brain.name = "Trapped mind of [victim.real_name]"
		victim.mind.transfer_to(host_brain)
		if(victim.key)
			host_brain.key = victim.key

		to_chat(host_brain, "You are trapped in your own mind. You feel that there must be a way to resist!")

		mind.transfer_to(victim)

		bonding = FALSE
		controlling = TRUE

		remove_verb(victim, /mob/living/proc/horror_comm)
		talk_to_horror_action.Remove(victim)
		GrantControlActions()

		victim.med_hud_set_status()
		if(target)
			victim.apply_status_effect(/datum/status_effect/agent_pinpointer/horror)
			for(var/datum/status_effect/agent_pinpointer/horror/status in victim.status_effects)
				status.scan_target = target.current

/mob/living/carbon/proc/release_control()
	var/mob/living/simple_animal/horror/B = has_horror_inside()
	if(B && B.host_brain)
		to_chat(src, span_danger("You withdraw your probosci, releasing control of [B.host_brain]"))
		B.detatch()

//Check for brain worms in head.
/mob/proc/has_horror_inside()
	for(var/I in contents)
		if(ishorror(I))
			return I


/mob/living/simple_animal/horror/proc/hit_detatch()
	if(victim.health <= 75)
		detatch()
		to_chat(src, span_warning("It appears that [victim]s brain detected danger, and hastily took over."))
		to_chat(victim, span_danger("Your body is under attack, you unconciously forced your brain to immediately take over!"))

/mob/living/simple_animal/horror/proc/detatch()
	if(!victim || !controlling)
		return

	controlling = FALSE
	UnregisterSignal(victim, COMSIG_MOB_APPLY_DAMAGE)
	add_verb(victim, /mob/living/proc/horror_comm)
	RemoveControlActions()
	RefreshAbilities()
	talk_to_horror_action.Grant(victim)

	for(var/obj/item/I in clothing)
		REMOVE_TRAIT(I, TRAIT_NODROP, HORROR_TRAIT)
	clothing = list()

	victim.med_hud_set_status()
	victim.remove_status_effect(/datum/status_effect/agent_pinpointer/horror)

	victim.mind.transfer_to(src)
	if(host_brain)
		host_brain.mind.transfer_to(victim)
		if(host_brain.key)
			victim.key = host_brain.key

	log_game("[src]/([src.ckey]) released control of [victim]/([victim.ckey]")
	qdel(host_brain)

/mob/living/simple_animal/horror/proc/Update_Invisibility_Button()
	var/datum/action/innate/horror/action = has_ability(/datum/action/innate/horror/chameleon)
	if(action)
		action.button_icon_state = "horror_sneak_[invisible ? "true" : "false"]"
		action.UpdateButtonIcon()

/mob/living/simple_animal/horror/proc/GrantHorrorActions()
	for(var/datum/action/innate/horror/ability in horrorabilities)
		if("horror" in ability.category)
			ability.Grant(src)

/mob/living/simple_animal/horror/proc/RemoveHorrorActions()
	for(var/datum/action/innate/horror/ability in horrorabilities)
		if("horror" in ability.category)
			ability.Remove(src)

/mob/living/simple_animal/horror/proc/GrantInfestActions()
	for(var/datum/action/innate/horror/ability in horrorabilities)
		if("infest" in ability.category)
			ability.Grant(src)

/mob/living/simple_animal/horror/proc/RemoveInfestActions()
	for(var/datum/action/innate/horror/ability in horrorabilities)
		if("infest" in ability.category)
			ability.Remove(src)

/mob/living/simple_animal/horror/proc/GrantControlActions()
	for(var/datum/action/innate/horror/ability in horrorabilities)
		if("control" in ability.category)
			ability.Grant(victim)

/mob/living/simple_animal/horror/proc/RemoveControlActions()
	for(var/datum/action/innate/horror/ability in horrorabilities)
		if("control" in ability.category)
			ability.Remove(victim)

/mob/living/simple_animal/horror/proc/RefreshAbilities() //control abilities technically don't belong to horror
	if(victim)
		RemoveHorrorActions()
		GrantInfestActions()
	else
		RemoveInfestActions()
		GrantHorrorActions()
