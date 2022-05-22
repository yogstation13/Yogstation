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
		if(istype(user, /mob/living/simple_animal/hunter))
			var/mob/living/simple_animal/hunter/hunterd = user
			hunterd.attack_streak = 0
			if(phased)	
				if(!hunterd.check_shit())
					to_chat(user, span_warning("You can only warp in while near your target or your blood orb!"))
					revert_cast()
					return
				if(user.phasein(target))
			  		phased = FALSE
	  		else
				var/phaseouttime = 30
				if(hunterd.check_shit())
					phaseouttime = 50
				if(do_after(src, phaseout))	
		  			if(user.phaseout(target))
			  			phased = TRUE
			start_recharge()
			return
	revert_cast()
	to_chat(user, span_warning("You are not a hunter demon, you can't do this!"))
