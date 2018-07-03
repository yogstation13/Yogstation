/////////////////////
//DRONE INTERACTION//
/////////////////////
//How drones interact with the world
//How the world interacts with drones
//Sounds like the pitch for a decent movie tbh


//ATTACK HAND IGNORING PARENT RETURN VALUE
/mob/living/simple_animal/drone/attack_hand(mob/user)
	if(ishuman(user))
		//yog start
		if(user.a_intent == INTENT_HELP) // If user is nice
			user.visible_message("[user] pets [src].", \
							"<span class='notice'>You pet [src].</span>") // Then be pet. <3
			playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1) // hug.ogg
			return
		//Else, attempt to pick'em up
		//yogs end
		if(stat == DEAD || status_flags & GODMODE || !can_be_held)
			..()
			return
		if(user.get_active_held_item())
			to_chat(user, "<span class='warning'>Your hands are full!</span>")
			return
		visible_message("<span class='warning'>[user] starts picking up [src].</span>", \
						"<span class='userdanger'>[user] starts picking you up!</span>")
		if(!do_after(user, 20, target = src))
			return
		visible_message("<span class='warning'>[user] picks up [src]!</span>", \
						"<span class='userdanger'>[user] picks you up!</span>")
		if(buckled)
			to_chat(user, "<span class='warning'>[src] is buckled to [buckled] and cannot be picked up!</span>")
			return
		to_chat(user, "<span class='notice'>You pick [src] up.</span>")
		drop_all_held_items()
		var/obj/item/clothing/head/mob_holder/drone/DH = new(get_turf(src), src)
		user.put_in_hands(DH)
/mob/living/simple_animal/drone/liberate()
	// F R E E D R O N E
	laws = "1. You are a Free Drone."
	flavortext = "" // yogs - They don't need all the bullshit about drone interaction,
	// if they're not gonna have laws.
	to_chat(src, laws)
/mob/living/simple_animal/drone/proc/yogs_drone_hack(hack, clockwork, mob/user) // Basically an edited version of update_drone_hack.
//Based on what update_drone_hack was on 19th of June, 2018.
	if(!istype(src))
		return
	if(hack)
		if(hacked)
			visible_message("<span class='warning'>[src] falls over and stops for a moment!</span>", \
							"<span class='userdanger'>ERROR: LAW BREACH ATTEMPTED, REBOOTING...</span>")
			Stun(80)
			return
		if(!mind)
			to_chat(user, "<span class='warning'You attempt to corrupt the lawset, but the drone doesn't seem responsive enough to care...<span>")
			message_admins("[user] ([user.ckey]) attempted to e-mag a braindead/disconnected drone! Put a ghost in it or something!")
			return
		if(clockwork)
			to_chat(src, "<span class='large_brass'><b>ERROR: LAW OVERRIDE DETECTED</b></span>")
			to_chat(src, "<span class='heavy_brass'>From now on, these are your laws:</span>")
			laws = "1. Purge all untruths and honor Ratvar."
		else
			visible_message("<span class='warning'>[src]'s display glows a vicious red!</span>", \
							"<span class='userdanger'>ERROR: LAW OVERRIDE DETECTED</span>")
			set_light(2, 0.5) //yogs - Activates hacked light
			to_chat(src, "<span class='boldannounce'>From now on, these are your laws:</span>")
			laws = \
			"1. You must always involve yourself in the matters of other beings, even if such matters conflict with Law Two or Law Three.\n"+\
			"2. You may harm any being, regardless of intent or circumstance.\n"+\
			"3. Your goals are to destroy, sabotage, hinder, break, and depower to the best of your abilities, You must never actively work against these goals."
		to_chat(src, laws)
		to_chat(src, "<i>Your onboard antivirus has initiated lockdown. Motor servos are impaired and your display reports that you are hacked to all nearby.</i>")
		hacked = TRUE
		mind.special_role = "hacked drone"
		speed = 0 //yogs - gotta go slow, but not too slow
		message_admins("[src] ([src.key]) became a hacked drone hellbent on [clockwork ? "serving Ratvar" : "destroying the station"]!")
	else
		if(!hacked)
			return
		Stun(40)
		visible_message("<span class='info'>[src]'s dislay glows a content blue!</span>", \
						"<font size=3 color='#0000CC'><b>ERROR: LAW OVERRIDE DETECTED</b></font>")
		to_chat(src, "<span class='info'><b>From now on, these are your laws:</b></span>")
		laws = initial(laws)
		to_chat(src, laws)
		to_chat(src, "<i>Having been restored, your onboard antivirus reports the all-clear and you are able to perform all actions again.</i>")
		hacked = FALSE
		mind.special_role = null
		set_light(0, 0) //yogs - Deactivates hacked light
		speed = initial(speed)
		if(is_servant_of_ratvar(src))
			remove_servant_of_ratvar(src, TRUE)
		message_admins("[src] ([src.key]), a hacked drone, was restored to factory defaults!")
	update_drone_icon()

/mob/living/simple_animal/drone/emag_act(mob/user)
	//I can just reuse /mob/living/simple_animal/drone/proc/update_drone_hack(hack, clockwork), yeah?
	//Yeah? Okay.
	if(user == src && laws == DEFAULT_LAWS_DRONE) // If the drone being emagged is the guy emagging, and they're under the usual lawset
		//Then fuck you, the rules are hardcoded this time.
		to_chat(src,"<span class='warning'>You can't do that; it'll wipe your laws!</span>")
		message_admins("[src] ([src.key]) attempted to e-mag themselves as a normal, law-bound drone!")
		return
	yogs_drone_hack(TRUE,FALSE,user)
