///W.I.P. !!!!
/obj/effect/proc_holder/spell/hunterjaunt
	name = "Warp"
	desc = "You can phase out of reality, and phase back near your target or your blood orb."
	charge_max = 0
	clothes_req = FALSE
	//If you couldn't cast this while phased, you'd have a problem
	phase_allowed = TRUE
	selection_type = "range"
	range = 1
	cooldown_min = 0
	overlay = null
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "bloodcrawl"
	action_background_icon_state = "bg_demon"
	var/phased = FALSE


/obj/effect/proc_holder/spell/hunterjaunt/perform(recharge = 1, mob/living/user = usr)
	if(istype(user))
		if(istype(user, /mob/living/simple_animal/hostile/hunter))
			var/mob/living/simple_animal/hostile/hunter/hunterd = user
			hunterd.attack_streak = 0
			if(phased)	
				if(!hunterd.check_shit(MAX_WARP_DISTANCE, ORB_AND_PREY))
					to_chat(user, span_warning("You can only warp in while near your target or your blood orb!"))
					revert_cast()
					return
				if(user.phasein())
					phased = FALSE
			else
				var/phaseouttime = 30
				if(hunterd.check_shit(BOUND_DISTANCE, ONLY_PREY)) ///Warping out while near your target takes longer
					phaseouttime = 50 
				if(do_after(src, phaseouttime))	
					if(user.phaseout())
						phased = TRUE
			start_recharge()
			return
	revert_cast()
	to_chat(user, span_warning("You are not a hunter demon, you can't do this!"))

/obj/effect/proc_holder/spell/targeted/hd_seek_prey
	name = "Seek prey"
	desc = "It says where is your target, or marks the assasination as completed if the target is dead, isn't no more a human, or is off the station z-level."
	invocation_type = "none"
	include_user = FALSE
	range = -1
	clothes_req = FALSE
	school = "evocation"
	charge_max = 100
	cooldown_min = 10
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "moneybag"
	phase_allowed = TRUE

/obj/effect/proc_holder/spell/targeted/cast(list/targets,mob/user = usr)
	if(istype(user,/mob/living/simple_animal/hostile/hunter))
		var/mob/living/simple_animal/hostile/hunter/demon = user
		if(!demon.target)
			to_chat(user,span_warning("You don't have a target! It should be chosen by your master, or you can choose it yourself if you are not bounded by a bounding rite."))
			return
		var/turf/userturf = get_turf(demon)
		var/turf/targetturf = get_turf(demon.target)
		var/dist = get_dist(userturf,targetturf)
		var/dir = get_dir(userturf,targetturf)
		if(userturf.z != targetturf.z)
			to_chat(user,span_warning("Your target isn't on the station z-level, you need to get a new one."))
			complete_assasination(killed = FALSE)
			return
		if(!istype(demon.target, /mob/living/carbon/human))
			to_chat(user,span_warning("Your target isn't no more a human, so you aren't no more interested in it. Get a new one."))
			complete_assasination(killed = FALSE)
			return
		if(demon.target.stat == DEAD)
			to_chat(user,span_warning("Your target is dead, so your mission is completed. Get a new one."))
			complete_assasination(killed = TRUE)
			return	
		switch(dist)         ///Taken from living heart code
			if(0 to 15)
				to_chat(user,span_warning("[target.real_name] is near you. They are to the [dir2text(dir)] of you!"))
			if(16 to 31)
				to_chat(user,span_warning("[target.real_name] is somewhere in your vicinty. They are to the [dir2text(dir)] of you!"))
			if(32 to 127)
				to_chat(user,span_warning("[target.real_name] is far away from you. They are to the [dir2text(dir)] of you!"))
			else
				to_chat(user,span_warning("[target.real_name] is beyond your reach."))		
	return
