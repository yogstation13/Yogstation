#define TRANSFORMATION_DURATION 22

/mob/living/carbon/proc/monkeyize(instant = FALSE)
	if (notransform || transformation_timer)
		return

	if(ismonkey(src))
		return

	if(instant)
		finish_monkeyize()
		return

	//Make mob invisible and spawn animation
	notransform = TRUE
	Paralyze(TRANSFORMATION_DURATION, ignore_canstun = TRUE)
	icon = null
	cut_overlays()
	invisibility = INVISIBILITY_MAXIMUM

	new /obj/effect/temp_visual/monkeyify(loc)
	transformation_timer = addtimer(CALLBACK(src, PROC_REF(finish_monkeyize)), TRANSFORMATION_DURATION, TIMER_UNIQUE)

/mob/living/carbon/proc/finish_monkeyize()
	transformation_timer = null
	to_chat(src, "<B>You are now a monkey.</B>")
	notransform = FALSE
	icon = initial(icon)
	invisibility = 0
	set_species(/datum/species/monkey)
	SEND_SIGNAL(src, COMSIG_HUMAN_MONKEYIZE)
	uncuff()
	regenerate_icons()
	return src

//////////////////////////           Humanize               //////////////////////////////
//Could probably be merged with monkeyize but other transformations got their own procs, too

/mob/living/carbon/proc/humanize(species = /datum/species/human, instant = FALSE)
	if (notransform || transformation_timer)
		return

	if(!ismonkey(src))
		return

	if(instant)
		finish_humanize(species)
		return

	//Make mob invisible and spawn animation
	notransform = TRUE
	Paralyze(TRANSFORMATION_DURATION, ignore_canstun = TRUE)
	icon = null
	cut_overlays()
	invisibility = INVISIBILITY_MAXIMUM

	new /obj/effect/temp_visual/monkeyify/humanify(loc)
	transformation_timer = addtimer(CALLBACK(src, PROC_REF(finish_humanize), species), TRANSFORMATION_DURATION, TIMER_UNIQUE)

/mob/living/carbon/proc/finish_humanize(species = /datum/species/human)
	transformation_timer = null
	to_chat(src, "<B>You are now a human.</B>")
	notransform = FALSE
	icon = initial(icon)
	invisibility = 0
	set_species(species)
	SEND_SIGNAL(src, COMSIG_MONKEY_HUMANIZE)
	regenerate_icons()
	return src

/mob/living/carbon/human/AIize(transfer_after = TRUE, client/preference_source)
	if (notransform)
		return
	for(var/t in bodyparts)
		qdel(t)

	return ..()

/mob/living/carbon/AIize(transfer_after = TRUE, client/preference_source)
	if (notransform)
		return
	notransform = TRUE
	Paralyze(1, ignore_canstun = TRUE)
	for(var/obj/item/W in src)
		dropItemToGround(W)
	regenerate_icons()
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	return ..()

/mob/proc/AIize(transfer_after = TRUE, client/preference_source)
	var/valid_core = FALSE
	for(var/obj/machinery/ai/data_core/core in GLOB.data_cores)
		if(core.valid_data_core())
			valid_core = TRUE
			break
	if(!valid_core)
		message_admins("No valid data core for [src]. Yell at a mapper! The AI will die.")

	if(client)
		stop_sound_channel(CHANNEL_LOBBYMUSIC)

	if(!transfer_after)
		mind.active = FALSE

	. = new /mob/living/silicon/ai(loc, null, src)


	if(preference_source)
		apply_pref_name(/datum/preference/name/ai, preference_source)

	qdel(src)

/mob/living/carbon/human/proc/Robotize(delete_items = 0, transfer_after = TRUE)
	if (notransform)
		return
	notransform = TRUE
	Paralyze(1, ignore_canstun = TRUE)

	for(var/obj/item/W in src)
		if(delete_items)
			qdel(W)
		else
			dropItemToGround(W)
	regenerate_icons()
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	for(var/t in bodyparts)
		qdel(t)

	var/mob/living/silicon/robot/R = new /mob/living/silicon/robot(loc)

	R.gender = gender
	R.invisibility = 0

	if(client)
		R.updatename(client)

	if(mind)		//TODO
		if(!transfer_after)
			mind.active = FALSE
		mind.transfer_to(R)
	else if(transfer_after)
		R.key = key

	if(R.mmi)
		R.mmi.name = "[initial(R.mmi.name)]: [real_name]"
		if(R.mmi.brain)
			R.mmi.brain.name = "[real_name]'s brain"
		if(R.mmi.brainmob)
			R.mmi.brainmob.real_name = real_name //the name of the brain inside the cyborg is the robotized human's name.
			R.mmi.brainmob.name = real_name

	R.job = "Cyborg"
	R.notify_ai(NEW_BORG)

	. = R
	if(R.ckey && is_banned_from(R.ckey, "Cyborg"))
		INVOKE_ASYNC(R, TYPE_PROC_REF(/mob/living/silicon/robot, replace_banned_cyborg))
	qdel(src)

/mob/living/silicon/robot/proc/replace_banned_cyborg()
	to_chat(src, "<b>You are job banned from cyborg! Appeal your job ban if you want to avoid this in the future!</b>")
	ghostize(FALSE)

	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as [src]?", "[src]", null, "Cyborg", 50, src)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/chosen_candidate = pick(candidates)
		message_admins("[key_name_admin(chosen_candidate)] has taken control of ([key_name_admin(src)]) to replace a jobbanned player.")
		key = chosen_candidate.key

//human -> alien
/mob/living/carbon/human/proc/Alienize()
	if (notransform)
		return
	notransform = TRUE
	mobility_flags = NONE
	for(var/obj/item/W in src)
		dropItemToGround(W)
	regenerate_icons()
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	for(var/t in bodyparts)
		qdel(t)

	var/alien_caste = pick("Hunter","Sentinel","Drone")
	var/mob/living/carbon/alien/humanoid/new_xeno
	switch(alien_caste)
		if("Hunter")
			new_xeno = new /mob/living/carbon/alien/humanoid/hunter(loc)
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(loc)
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/humanoid/drone(loc)

	new_xeno.a_intent = INTENT_HARM
	new_xeno.key = key
	update_atom_languages()

	to_chat(new_xeno, "<B>You are now an alien.</B>")
	. = new_xeno
	qdel(src)

/mob/living/carbon/human/proc/slimeize(reproduce as num)
	if (notransform)
		return
	notransform = TRUE
	mobility_flags = NONE
	for(var/obj/item/W in src)
		dropItemToGround(W)
	regenerate_icons()
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	for(var/t in bodyparts)
		qdel(t)

	var/mob/living/simple_animal/slime/new_slime
	if(reproduce)
		var/number = pick(14;2,3,4)	//reproduce (has a small chance of producing 3 or 4 offspring)
		var/list/babies = list()
		for(var/i=1,i<=number,i++)
			var/mob/living/simple_animal/slime/M = new/mob/living/simple_animal/slime(loc)
			M.set_nutrition(round(nutrition/number))
			step_away(M,src)
			babies += M
		new_slime = pick(babies)
	else
		new_slime = new /mob/living/simple_animal/slime(loc)
	new_slime.a_intent = INTENT_HARM
	new_slime.key = key

	to_chat(new_slime, "<B>You are now a slime. Skreee!</B>")
	. = new_slime
	qdel(src)

/mob/proc/become_overmind(starting_points = 60, pointmodifier = 1)
	var/mob/camera/blob/B = new /mob/camera/blob(get_turf(src), starting_points, pointmodifier)
	B.key = key
	. = B
	qdel(src)


/mob/living/carbon/human/proc/corgize()
	if (notransform)
		return
	notransform = TRUE
	Paralyze(1, ignore_canstun = TRUE)
	for(var/obj/item/W in src)
		dropItemToGround(W)
	regenerate_icons()
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	for(var/t in bodyparts)	//this really should not be necessary
		qdel(t)

	var/mob/living/simple_animal/pet/dog/corgi/new_corgi = new /mob/living/simple_animal/pet/dog/corgi (loc)
	new_corgi.a_intent = INTENT_HARM
	new_corgi.key = key

	to_chat(new_corgi, "<B>You are now a Corgi. Yap Yap!</B>")
	. = new_corgi
	qdel(src)

/mob/living/carbon/proc/gorillize()
	if(notransform)
		return
	notransform = TRUE
	Paralyze(1, ignore_canstun = TRUE)

	SSblackbox.record_feedback("amount", "gorillas_created", 1)

	var/Itemlist = get_equipped_items(TRUE)
	Itemlist += held_items
	for(var/obj/item/W in Itemlist)
		dropItemToGround(W, TRUE)

	regenerate_icons()
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	var/mob/living/simple_animal/hostile/gorilla/new_gorilla = new (get_turf(src))
	new_gorilla.a_intent = INTENT_HARM
	if(mind)
		mind.transfer_to(new_gorilla)
	else
		new_gorilla.key = key
	to_chat(new_gorilla, "<B>You are now a gorilla. Ooga ooga!</B>")
	. = new_gorilla
	qdel(src)

/mob/living/carbon/human/proc/pacmanize()
	if (notransform)
		return
	notransform = TRUE
	Paralyze(1, ignore_canstun = TRUE)
	for(var/obj/item/W in src)
		dropItemToGround(W)
	regenerate_icons()
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	for(var/t in bodyparts)	//this really should not be necessary
		qdel(t)

	var/mob/living/simple_animal/pacman/new_pacman = new /mob/living/simple_animal/pacman (loc)
	new_pacman.a_intent = INTENT_HARM
	new_pacman.key = key

	to_chat(new_pacman, "<B>You are now a pacman. I LOVE PACMAN!</B>")
	. = new_pacman
	qdel(src)

/mob/living/carbon/human/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		to_chat(usr, span_danger("Sorry but this mob type is currently unavailable."))
		return

	if(notransform)
		return
	notransform = TRUE
	Paralyze(1, ignore_canstun = TRUE)

	for(var/obj/item/W in src)
		dropItemToGround(W)

	regenerate_icons()
	icon = null
	invisibility = INVISIBILITY_MAXIMUM

	for(var/t in bodyparts)
		qdel(t)

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = INTENT_HARM


	to_chat(new_mob, "You suddenly feel more... animalistic.")
	. = new_mob
	qdel(src)

/mob/proc/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input(usr, "Which type of mob should [src] turn into?", "Choose a type", sortList(mobtypes, /proc/cmp_typepaths_asc))

	if(!safe_animal(mobpath))
		to_chat(usr, span_danger("Sorry but this mob type is currently unavailable."))
		return

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = INTENT_HARM
	to_chat(new_mob, "You feel more... animalistic")

	. = new_mob
	qdel(src)

/* Certain mob types have problems and should not be allowed to be controlled by players.
 *
 * This proc is here to force coders to manually place their mob in this list, hopefully tested.
 * This also gives a place to explain -why- players shouldnt be turn into certain mobs and hopefully someone can fix them.
 */
/mob/proc/safe_animal(MP)

//Bad mobs! - Remember to add a comment explaining what's wrong with the mob
	if(!MP)
		return 0	//Sanity, this should never happen.
//	if(ispath(MP, /mob/living/simple_animal/pet/cat))
//		return 0	//Template

	//Not in here? Must be good!
	return 1

#undef TRANSFORMATION_DURATION
