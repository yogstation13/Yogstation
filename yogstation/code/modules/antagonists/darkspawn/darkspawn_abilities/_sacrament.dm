//Turns the darkspawn into a progenitor.
/datum/action/cooldown/spell/sacrament
	name = "Sacrament"
	desc = "Ascends into a progenitor. You must have drained lucidity from a certain number of different people for this to work."
	panel = "Darkspawn"
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "sacrament"
	check_flags =  AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS
	spell_requirements = NONE
	var/datum/looping_sound/sacrament/soundloop
	var/datum/antagonist/darkspawn/darkspawn
	///if they're actively performing the sacrament
	var/in_use = FALSE

/datum/action/cooldown/spell/sacrament/IsAvailable(feedback)
	if(in_use)
		if (feedback)
			owner.balloon_alert(owner, "already in use!")
		return
	return ..()

/datum/action/cooldown/spell/sacrament/cast(atom/cast_on)
	. = ..()
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(owner)
	if(!darkspawn)
		to_chat(owner, span_warning("Error with non darkspawn using sacrament spell"))
		return
	var/datum/team/darkspawn/team = darkspawn.get_team()
	if(!team)
		stack_trace("Non-Darkspawn or Darkspawn without team tried to perform the sacrament")
		return
	if(team.lucidity < team.required_succs)
		to_chat(owner, span_warning("You do not have enough unique lucidity! ([team.lucidity] / [team.required_succs])"))
		return
	if(tgui_alert(owner, "The Sacrament is ready! Are you prepared?", name, list("Yes", "No")) != "Yes")
		return
	if(GLOB.sacrament_done)
		darkspawn.sacrament() //if someone else has already done the sacrament, skip to the good part
		return

	var/mob/living/carbon/human/user = owner
	if(!user || !istype(user))//sanity check
		return

	var/processed_message = span_progenitor("\[Mindlink\] [user] has begun performing the sacrament.")
	for(var/mob/M as anything in GLOB.alive_mob_list)
		if(is_darkspawn_or_thrall(M))
			to_chat(M, processed_message)
	deadchat_broadcast(processed_message, null, user)

	in_use = TRUE

	user.visible_message(span_warning("[user]'s sigils flare as energy swirls around them..."), span_velvet("You begin creating a psychic barrier around yourself..."))
	sound_to_playing_players('yogstation/sound/magic/sacrament_begin.ogg', 50, FALSE, pressure_affected = FALSE)
	if(!do_after(user, 3 SECONDS, user))
		in_use = FALSE
		return
	user.visible_message(span_warning("A vortex of violet energies surrounds [user]!"), span_velvet("Your barrier will protect you."))
	for(var/turf/T in RANGE_TURFS(2, user))
		if(isclosedturf(T))
			continue
		new/obj/structure/psionic_barrier(T, 340)

	var/image/alert_overlay = image('yogstation/icons/mob/actions/actions_darkspawn.dmi', "sacrament")
	notify_ghosts("Darkspawn [user.real_name] has begun the Sacrament at [get_area(user)]! ", source = user, ghost_sound = 'yogstation/sound/magic/devour_will_victim.ogg', alert_overlay = alert_overlay, action = NOTIFY_ORBIT)
	soundloop = new(GLOB.player_list, TRUE, TRUE)

	user.visible_message(span_danger("[user] suddenly jolts into the air, pulsing with screaming violet light."), span_progenitor("You begin the Sacrament."))

	for(var/stage in 1 to 2)
		soundloop.stage = stage
		switch(stage)
			if(1)
				user.visible_message(span_userdanger("[user]'s sigils howl out light. Their limbs twist and move, glowing cracks forming across their chitin."), \
									span_velvet("Power... <i>power...</i> flooding through you, the dreams and thoughts of the wills you've devoured whispering in your ears..."))
				sound_to_playing_players('yogstation/sound/magic/sacrament_01.ogg', 20, FALSE, pressure_affected = FALSE)
			if(2)
				for(var/turf/T in range(10, owner)) //add spooky visuals to the mounting power
					if(prob(10))
						addtimer(CALLBACK(src, PROC_REF(unleashed_psi), T), rand(1, 15 SECONDS))

				animate(user, transform = matrix() * 2, time = 15 SECONDS)
				user.visible_message(span_userdanger("[user] begins to... <i>grow.</i>."), span_progenitor("Your mortal shell begins to fracture as power swells within it!"))
				sound_to_playing_players('yogstation/sound/magic/sacrament_02.ogg', 20, FALSE, pressure_affected = FALSE)

		//if you somehow get interrupted
		if(!do_after(user, 15 SECONDS, user))
			user.visible_message(span_warning("[user] falls to the ground!"), span_userdanger("Your transformation was interrupted!"))
			animate(user, transform = matrix(), pixel_y = initial(user.pixel_y), time = 3 SECONDS)
			in_use = FALSE
			QDEL_NULL(soundloop)
			return


	soundloop.stage = 3
	animate(user, pixel_y = user.pixel_y + 20, time = 4 SECONDS)
	user.visible_message(span_userdanger("[user] rises into the air, crackling with power!"))	

	for(var/turf/T in range(10, owner))
		if(prob(35))
			addtimer(CALLBACK(src, PROC_REF(unleashed_psi), T), rand(1, 40))

	addtimer(CALLBACK(src, PROC_REF(finalize), user), 3 SECONDS)//ominous delay that's eerily quiet

/datum/action/cooldown/spell/sacrament/proc/finalize(mob/living/carbon/human/user)
	to_chat(user, span_progenitor("AND THE WEAK WILL KNOW <i>FEAR--</i>"))
	sound_to_playing_players('yogstation/sound/magic/sacrament_ending.ogg', 75, FALSE, pressure_affected = FALSE)
	QDEL_IN(soundloop, 1 SECONDS)
	addtimer(CALLBACK(darkspawn, TYPE_PROC_REF(/datum/antagonist/darkspawn, sacrament)), 1 SECONDS)

/datum/action/cooldown/spell/sacrament/proc/unleashed_psi(turf/T)
	if(!in_use)
		return
	playsound(T, 'yogstation/sound/magic/divulge_end.ogg', 25, FALSE)
	new/obj/effect/temp_visual/revenant/cracks(T)
