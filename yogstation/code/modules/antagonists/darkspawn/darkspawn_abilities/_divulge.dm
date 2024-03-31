//A channeled ability that turns the darkspawn into their main form.
/datum/action/cooldown/spell/divulge
	name = "Divulge"
	desc = "Sheds your human disguise. This is obvious and so should be done in a secluded area. You cannot reverse this."
	panel = "Darkspawn"
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "divulge"
	check_flags =  AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = NONE
	///if they're actively divulging
	var/in_use = FALSE

/datum/action/cooldown/spell/divulge/IsAvailable(feedback)
	if(in_use)
		if (feedback)
			owner.balloon_alert(owner, "already in use!")
		return
	return ..()

/datum/action/cooldown/spell/divulge/cast(atom/cast_on)
	set waitfor = FALSE
	. = ..()
	var/mob/living/carbon/human/user = usr
	var/turf/spot = get_turf(user)
	if(!ishuman(user))
		to_chat(user, span_warning("You need to be human-er to do that!"))
		return

	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(user)
	if(darkspawn)
		if(!darkspawn.picked_class)
			to_chat(user, span_warning("You must pick a class to divulge!"))
			return
		if(darkspawn.darkspawn_state != DARKSPAWN_MUNDANE) //if they've somehow gone back to being a non-darkspawn, let them skip the process
			darkspawn.divulge()
			return

	if(isethereal(user))//disable the light for long enough to start divulge
		user.dna.species.spec_emp_act(user, EMP_HEAVY)
			
	if(spot.get_lumcount() > SHADOW_SPECIES_DIM_LIGHT)
		to_chat(user, span_warning("You are only able to divulge in darkness!"))
		return

	if(tgui_alert(user, "You are ready to divulge. This will leave you vulnerable and take a long time, are you sure?", name, list("Yes", "No")) != "Yes")
		return
	in_use = TRUE

	if(istype(user.dna.species, /datum/species/pod))
		to_chat(user, span_notice("Your disguise is stabilized by the divulgance..."))
		user.reagents.add_reagent(/datum/reagent/medicine/salbutamol,20)

	if(istype(user.dna.species, /datum/species/plasmaman))
		to_chat(user, span_notice("Your bones harden to protect you from the atmosphere..."))
		user.set_species(/datum/species/skeleton)

	to_chat(user, span_velvet("You begin creating a psychic barrier around yourself..."))
	if(!do_after(user, 3 SECONDS, user))
		in_use = FALSE
		return
	for(var/turf/T in RANGE_TURFS(1, user))
		if(isclosedturf(T))
			continue
		new/obj/structure/psionic_barrier(T, 35 SECONDS)
	user.visible_message(span_warning("A vortex of violet energies surrounds [user]!"), span_velvet("Your barrier will keep you shielded to a point.."))

	var/image/alert_overlay = image('yogstation/icons/mob/actions/actions_darkspawn.dmi', "divulge")
	notify_ghosts("Darkspawn [user.real_name] has begun divulging at [get_area(user)]! ", source = user, ghost_sound = 'yogstation/sound/magic/devour_will_victim.ogg', alert_overlay = alert_overlay, action = NOTIFY_ORBIT)

	user.visible_message(span_danger("[user] slowly rises into the air, their belongings falling away, and begins to shimmer..."), span_progenitor("You begin the removal of your human disguise. You will be completely vulnerable during this time."))
	user.setDir(SOUTH)
	user.unequip_everything()

	for(var/stage in 1 to 3)
		if(isethereal(user))//keep the light disabled
			user.dna.species.spec_emp_act(user, EMP_HEAVY)
		switch(stage)
			if(1)
				user.visible_message(span_userdanger("Vibrations pass through the air. [user]'s eyes begin to glow a deep violet."), \
									span_velvet("Psi floods into your consciousness. You feel your mind growing more powerful... <i>expanding.</i>"))
				playsound(user, 'yogstation/sound/magic/divulge_01.ogg', 30, 0)
			if(2)
				user.visible_message(span_userdanger("Gravity fluctuates. Psychic tendrils extend outward and feel blindly around the area."), \
									span_velvet("Gravity around you fluctuates. You tentatively reach out, feeling with your mind."))
				user.Shake(0, 3, 500) //50 loops in a second times 15 seconds = 750 loops
				playsound(user, 'yogstation/sound/magic/divulge_02.ogg', 40, 0)
			if(3)
				user.visible_message(span_userdanger("Sigils form along [user]'s body. [user.p_their()] skin blackens as [user.p_they()] glow a blinding purple."), \
									span_velvet("Your body begins to warp. Sigils etch themselves upon your flesh."))
				animate(user, color = list(rgb(0, 0, 0), rgb(0, 0, 0), rgb(0, 0, 0), rgb(0, 0, 0)), time = 10 SECONDS) //Produces a slow skin-blackening effect
				playsound(user, 'yogstation/sound/magic/divulge_03.ogg', 50, 0)
		if(!do_after(user, 10 SECONDS, user))
			user.visible_message(span_warning("[user] falls to the ground!"), span_userdanger("Your transformation was interrupted!"))
			animate(user, color = initial(user.color), pixel_y = initial(user.pixel_y), time = 1 SECONDS)
			in_use = FALSE
			return
	if(isethereal(user))//keep the light disabled
		user.dna.species.spec_emp_act(user, EMP_HEAVY)
	playsound(user, 'yogstation/sound/magic/divulge_ending.ogg', 50, 0)
	user.visible_message(span_userdanger("[user] rises into the air, crackling with power!"), span_progenitor("Your mind...! can't--- THINK--"))
	animate(user, pixel_y = user.pixel_y + 8, time = 6 SECONDS)
	sleep(4.5 SECONDS)

	user.Shake(5, 5, 11 SECONDS)
	var/list/spooky = list(
		"I- I- I-", "Mind-", "Sigils-", "Can't think-", 
		"<i>POWER-</i>","<i>TAKE-</i>", "M-M-MOOORE-", 
		"<i>THINK-</i>", "EMBRACE-", "BECOME-")
	for(var/i in 1 to 40)
		to_chat(user, span_progenitor("[pick(spooky)]"))
		sleep(0.05 SECONDS) //Spooky flavor message spam

	user.visible_message(span_userdanger("A tremendous shockwave emanates from [user]!"), span_progenitor("YOU ARE FREE!!"))
	playsound(user, 'yogstation/sound/magic/divulge_end.ogg', 50, 0)
	animate(user, color = initial(user.color), pixel_y = initial(user.pixel_y), time = 3 SECONDS)

	for(var/mob/living/L in view(7, user))
		if(is_team_darkspawn(L) || L == user) //probably won't have thralls yet, but might as well check just in case
			continue
		L.flash_act(1, 1)
		L.Knockdown(5 SECONDS)

	if(darkspawn)//sanity check
		darkspawn.divulge()
