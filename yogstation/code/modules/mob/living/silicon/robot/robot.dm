/mob/living/silicon/robot/proc/PickBorgSkin(var/forced = FALSE) //We'll do our own AI version inside its pre existent skin selector methinks
	icon = initial(icon) //Redundancy in case they repick a skin after modulechange
	if(!GLOB.DonorBorgHolder)
		message_admins("[client.ckey] just tried to change their borg skin, but there is no borg skin holder datum! (Has the game not started yet?)")
		to_chat(src, "<span class='warning'>An error occured, if the game has not started yet, please try again after it has. The admins have been notified about this.</span>")
		return FALSE
	if(forced || is_donator(client))//First off, are we even meant to have this verb? or is an admin bruteforcing it onto a non donator for some reason?
		if(module.name == "Default")
			to_chat(src, "Please choose a module first! (Standard works too)")
			return FALSE
		if(ROLE_SYNDICATE in faction)
			to_chat(src, "<span class='warning'>You cannot reskin as a syndicate cyborg!</span>")
			return FALSE
		var/datum/borg_skin/skins = list("default" = icon(icon = src.icon, icon_state = module.cyborg_base_icon))
		for(var/T in GLOB.DonorBorgHolder.skins)
			if(istype(T, /datum/borg_skin))
				var/datum/borg_skin/S = T
				if(S.owner == client.ckey || !S.owner) //We own this skin.
					if(!S.module_locked || S.module_locked == module.name)
						skins[S] = image(icon = S.icon, icon_state = S.icon_state) //So add it to the temp list which we'll iterate through
		var/datum/borg_skin/A //Defining A as a borg_skin datum so we can pick out the vars we want and reskin the unit
		A = show_radial_menu(src, src, skins, radius = 42)//Pick any datum from the list we just established up here ^^
		if(!A)
			special_skin = FALSE
			return FALSE
		if(!istype(A))
			to_chat(src, "You've chosen to use the standard skinset instead of a custom one.")
			special_skin = FALSE
			return FALSE
		icon =  A.icon
		icon_state = A.icon_state
		cut_overlays()
		eye_lights.icon = A.icon
		eye_lights.icon_state = "[icon_state]_e[is_servant_of_ratvar(src) ? "_r" : ""]"
		add_overlay(eye_lights)
		to_chat(src, "<span class='notice'>You have successfully applied the skin: [A.name]</span>")
		special_skin = TRUE
		return TRUE

//I'm overriding this so that donors will be able to pick their borg skin after choosing a module.
/obj/item/robot_module/do_transform_delay()
	. = ..()
	var/mob/living/silicon/robot/R = loc
	R.PickBorgSkin()

/mob/living/silicon/robot/update_icons() //Need to change this, as it's killing donorborgs
	var/old_icon = icon_state
	. = ..()
	if (special_skin)
		cut_overlays()
		icon_state = old_icon
		eye_lights.icon_state = "[icon_state]_e[is_servant_of_ratvar(src) ? "_r" : ""]"
		add_overlay(eye_lights)

/mob/living/silicon/robot/examine(mob/user)
	. = ..()
	. += "It seems to have the <b>[module.name] module</b> loaded."

/mob/living/silicon/robot/verb/self_self_destruct()
	set category = "Robot Commands"
	set name = "Self Destruct"

	if(usr.stat == DEAD)
		return //won't work if dead

	if(alert("WARNING: Are you sure you wish to self-destruct? This action cannot be undone!",,"Yes","No") != "Yes")
		return

	if(usr.stat == DEAD)
		to_chat(usr, "<span class='danger'>You are already dead.</span>")
		return //won't work if dead

	var/turf/T = get_turf(usr)
	message_admins("<span class='notice'>[ADMIN_LOOKUPFLW(usr)] detonated themselves at [ADMIN_VERBOSEJMP(T)]!</span>")
	log_game("\<span class='notice'>[key_name(usr)] detonated themselves!</span>")
	if(connected_ai)
		to_chat(connected_ai, "<br><br><span class='alert'>ALERT - Cyborg detonation detected: [usr]</span><br>")
	self_destruct()
