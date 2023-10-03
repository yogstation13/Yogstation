/**
  * Hecata, the unified clan of death.
  *
  * Focuses more on their vassals than other clans.
  * Has to rely more on vassals for ranks and blood, as they cannot use the blood altar for leveling up and cannot silent feed.
  * In exchange, they can raise the dead as temporary vassals to do their bidding, or permanently revive dead existing vassals.
  * In addition, they can summon Wraiths (shades) around them for both offense and defense
  * And can send messages to vassals anywhere globally via Dark Communion.
  * In addition, raising the dead with Necromancy turns them into Sanguine Zombies
  * They are pseudo zombies, which have high punch damage and special resistances, but aren't infectious nor can they use guns.
  */
/datum/action/cooldown/bloodsucker/targeted/hecata
	purchase_flags = HECATA_CAN_BUY
	background_icon = 'icons/mob/actions/actions_hecata_bloodsucker.dmi'
	button_icon = 'icons/mob/actions/actions_hecata_bloodsucker.dmi'
	active_background_icon_state = "hecata_power_on"
	base_background_icon_state = "hecata_power_off"

/datum/action/cooldown/bloodsucker/targeted/hecata/necromancy
	name = "Necromancy"
	button_icon_state = "power_necromancy"
	desc = "Raise the dead as temporary vassals, or revive a dead vassal as a zombie permanently. Temporary vassals last longer as this ability ranks up. Mindshielded people will take far longer to necromance."
	power_explanation = "Necromancy:\n\
		Click on a corpse in order to attempt to resurrect them.\n\
		Non-vassals will become temporary zombies that will follow your orders. Dead vassals are also turned, but last permanently.\n\
		Temporary vassals tend to not last long, their form quickly falling apart, make sure you set them out to do what you want as soon as possible.\n\
		Vassaling people this way does not grant ranks. In addition, after their time is up they will die and no longer be your vassal."
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_UNCONSCIOUS
	power_flags = BP_AM_STATIC_COOLDOWN
	bloodcost = 35
	cooldown_time = 45 SECONDS
	target_range = 1
	prefire_message = "Select a target."
	
/datum/action/cooldown/bloodsucker/targeted/hecata/necromancy/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	return isliving(target_atom)

/datum/action/cooldown/bloodsucker/targeted/hecata/necromancy/CheckCanTarget(mob/living/carbon/target_atom)
	. = ..()
	if(!.)
		return FALSE
	// No mind
	if(!target_atom.mind)
		to_chat(owner, span_warning("[target_atom] is mindless."))
		return FALSE
	// Bloodsucker
	if(IS_BLOODSUCKER(target_atom))
		to_chat(owner, span_notice("Bloodsuckers are immune to [src]."))
		return FALSE
	// Alive
	if(target_atom.stat != DEAD)
		to_chat(owner, span_notice("[target_atom] is still alive."))
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/targeted/hecata/necromancy/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/target = target_atom
	var/mob/living/user = owner
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(target.stat == DEAD && user.Adjacent(target))
		owner.balloon_alert(owner, "attempting to revive...")
		if(HAS_TRAIT(target, TRAIT_MINDSHIELD) && !IS_VASSAL(target)) //if they aren't already a vassal and they have a mindshield
			owner.balloon_alert(owner, "mindshield detected, this will take longer...")
			if(!do_after(user, 18 SECONDS, target))
				return FALSE
		else
			if(!do_after(user, 6 SECONDS, target))
				return FALSE
		if(IS_VASSAL(target))
			power_activated_sucessfully()
			owner.balloon_alert(owner, "we revive [target]!")
			zombify(target)
			bloodsuckerdatum.clanprogress++ //counts a succesful necromancy towards your objective progress
			return
		if(IS_MONSTERHUNTER(target))
			owner.balloon_alert(owner, "their body refuses to react...")
			DeactivatePower()
			return
		zombify(target)
		bloodsuckerdatum.make_vassal(target)
		power_activated_sucessfully()
		bloodsuckerdatum.clanprogress++ //counts a succesful necromancy towards your objective progress
		to_chat(user, span_warning("We revive [target]!"))
		var/living_time
		switch(level_current)
			if(0)
				living_time = 2 MINUTES
			if(1)
				living_time = 5 MINUTES
			if(2)
				living_time = 8 MINUTES
			if(3)
				living_time = 11 MINUTES
			if(4)
				living_time = 14 MINUTES 
			if(5 to 99)
				living_time = 17 MINUTES //in general, they don't last long, make the most of them.
		addtimer(CALLBACK(src, PROC_REF(end_necromance), target), living_time)
	else //extra check, but this shouldn't happen
		owner.balloon_alert(owner, "out of range/not dead.")
		return FALSE
	DeactivatePower()
	
/datum/action/cooldown/bloodsucker/targeted/hecata/necromancy/proc/end_necromance(mob/living/user)
	user.mind.remove_antag_datum(/datum/antagonist/vassal)
	to_chat(user, span_warning("You feel the shadows around you weaken, your form falling limp like a puppet cut from its strings!"))
	user.set_species(/datum/species/krokodil_addict) //they will turn into a fake zombie on death, that still retains blood and isnt so powerful.
	user.death()

/datum/action/cooldown/bloodsucker/targeted/hecata/necromancy/proc/zombify(mob/living/user)
	user.mind.grab_ghost()
	user.set_species(/datum/species/zombie/hecata) //imitation zombies that shamble around and beat people with their fists
	user.revive(full_heal = TRUE, admin_revive = TRUE)
	user.visible_message(span_danger("[user] suddenly convulses, as [user.p_they()] stagger to their feet and gain a ravenous hunger in [user.p_their()] eyes!"), span_alien("You RISE!"))
	playsound(owner.loc, 'sound/hallucinations/far_noise.ogg', 50, 1)
	to_chat(user, span_warning("Your broken form is picked up by strange shadows. If you were previously not a vassal, it is unlikely these shadows will be strong enough to keep you going for very long."))
	to_chat(user, span_notice("You are resilient to many things like the vacuum of space, can punch harder, and can take more damage before dropping. However, you are unable to use guns and are slower."))

/datum/action/cooldown/bloodsucker/hecata
	purchase_flags = HECATA_CAN_BUY
	background_icon = 'icons/mob/actions/actions_hecata_bloodsucker.dmi'
	button_icon = 'icons/mob/actions/actions_hecata_bloodsucker.dmi'
	active_background_icon_state = "hecata_power_on"
	base_background_icon_state = "hecata_power_off"

///summon wraiths (weakened shades) to attack anyone who isn't a zombie. This includes non-zombified vassals. However, you can get around this by zombifying your vassals.
///to do this, you can make someone your favorite vassal, or you can kill them and then revive them with necromancy.
/datum/action/cooldown/bloodsucker/hecata/spiritcall
	name = "Spirit Call"
	desc = "Summon angry wraiths which will attack anyone whose flesh is still alive. Summon amount increases as this ability levels up."
	button_icon_state = "power_spiritcall"
	power_explanation = "Spirit Call:\n\
		Summon angry wraiths which enact vengeance from beyond the grave on those still connected to this world.\n\
		Note, that includes any of your vassals who are not undead, as wraiths will seek to kill them too!\n\
		Summons more wraiths as this ability ranks up.\n\
		These wraiths aren't very powerful, and best serve as a distraction, but in a pinch can help in a fight. \n\
		The spirits will eventually return back to their realm if not otherwise destroyed."
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_UNCONSCIOUS
	power_flags = BP_AM_STATIC_COOLDOWN
	bloodcost = 15
	cooldown_time = 60 SECONDS
	///How many spirits should be summoned when cast
	var/num_spirits = 1

/datum/action/cooldown/bloodsucker/hecata/spiritcall/vassal //this variant has to exist, as hecata favorite vassals are technically in 'torpor'
	check_flags = BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	
/datum/action/cooldown/bloodsucker/hecata/spiritcall/ActivatePower(mob/user = owner)
	. = ..()
	switch(level_current)
		if(0)
			num_spirits = 1
		if(1)
			num_spirits = 2
		if(2)
			num_spirits = 3
		if(3 to 99)
			num_spirits = 4
	var/list/turf/locs = list()
	for(var/direction in GLOB.alldirs) //looking for spirit spawns
		if(locs.len == num_spirits) //we found the number of spots needed and thats all we need
			break
		var/turf/T = get_step(owner, direction) //getting a loc in that direction
		if(AStar(user, T, /turf/proc/Distance, 1, simulated_only = 0)) // if a path exists, so no dense objects in the way its valid salid
			locs += T
	// pad with player location
	for(var/i = locs.len + 1 to num_spirits)
		locs += user.loc
	summon_wraiths(locs, user = owner)
	cast_effect() // POOF
	DeactivatePower()
	
/datum/action/cooldown/bloodsucker/hecata/spiritcall/proc/summon_wraiths(list/targets, mob/living/user)
	for(var/T in targets)
		new /mob/living/simple_animal/hostile/bloodsucker/wraith(T)

/datum/action/cooldown/bloodsucker/hecata/spiritcall/proc/cast_effect() //same as veil of many faces, makes smoke and stuff when casted
	// Effect
	playsound(get_turf(owner), 'sound/magic/smoke.ogg', 20, TRUE)
	var/datum/effect_system/steam_spread/puff = new /datum/effect_system/steam_spread/bloodsucker()
	puff.effect_type = /obj/effect/particle_effect/fluid/smoke/vampsmoke
	puff.set_up(3, 0, get_turf(owner))
	puff.attach(owner) //OPTIONAL
	puff.start()
	owner.spin(8, 1) //Spin around like a loon.

/datum/action/cooldown/bloodsucker/hecata/communion
	name = "Deathly Communion"
	desc = "Send a message to all your vassals."
	button_icon_state = "power_communion"
	power_explanation = "Deathly Communion:\n\
		Send a message directly to all vassals under your control, temporary or permanent.\n\
		They will not be able to respond to you through any supernatural means in the way you can.\n\
		Note, nearby humans can hear you talk when using this.\n\
		The cooldown of Communion will decrease as it levels up."
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY
	power_flags = NONE
	bloodcost = 8
	cooldown_time = 30 SECONDS

/datum/action/cooldown/bloodsucker/hecata/communion/ActivatePower()
	. = ..()
	var/input = sanitize(tgui_input_text(usr, "Enter a message to tell your vassals.", "Voice of Blood"))
	if(!input || !IsAvailable())
		return FALSE
	deathly_commune(usr, input)

/datum/action/cooldown/bloodsucker/hecata/communion/proc/deathly_commune(mob/living/user, message) //code from Fulpstation
	var/rendered = span_cultlarge("<b>Master [user.real_name] announces:</b> [message]")
	user.log_talk(message, LOG_SAY, tag=ROLE_BLOODSUCKER)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	for(var/datum/antagonist/vassal/receiver as anything in bloodsuckerdatum.vassals)
		if(!receiver.owner.current)
			continue
		var/mob/receiver_mob = receiver.owner.current
		to_chat(receiver_mob, rendered)
	to_chat(user, rendered) // tell yourself, too.
	for(var/mob/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, user)
		to_chat(dead_mob, "[link] [rendered]")
	DeactivatePower()
