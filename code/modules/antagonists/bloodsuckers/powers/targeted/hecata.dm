//Hecata, the unified clan of death.
//Focuses more on their vassals than other clans.
//Has to rely more on vassals for ranks and blood, as they cannot use the blood altar for leveling up and cannot silent feed.
//In exchange, they can raise the dead as temporary vassals to do their bidding, or permanently revive dead existing vassals.
//In addition, they can summon Wraiths (shades) around them for both offense and defense
//And can send messages to vassals anywhere globally via Dark Communion.
//In addition, raising the dead with Necromancy turns them into Sanguine Zombies
//They are pseudo zombies, which have high punch damage and special resistances, but aren't infectious nor can they use guns.

/datum/action/bloodsucker/targeted/hecata
	purchase_flags = HECATA_CAN_BUY

	button_icon = 'icons/mob/actions/actions_hecata_bloodsucker.dmi'
	icon_icon = 'icons/mob/actions/actions_hecata_bloodsucker.dmi'
	background_icon_state = "hecata_power_off"
	background_icon_state_on = "hecata_power_on"
	background_icon_state_off = "hecata_power_off"

/datum/action/bloodsucker/targeted/hecata/necromancy
	name = "Necromancy"
	level_current = 1
	button_icon_state = "power_necromancy"
	desc = "Raise the dead as temporary vassals, or revive a dead vassal as a zombie permanently. Temporary vassals last longer as this ability ranks up."
	power_explanation = "Necromancy:\n\
		Click on a corpse in order to attempt to resurrect them.\n\
		Non-vassals will become temporary zombies that will follow your orders. Dead vassals are also turned, but last permanently.\n\
		Temporary vassals tend to not last long, their form quickly falling apart, make sure you set them out to do what you want as soon as possible.\n\
		Vassaling people this way does not grant ranks. In addition, after their time is up they will die and no longer be your vassal."
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_UNCONSCIOUS
	power_flags = BP_AM_STATIC_COOLDOWN
	bloodcost = 35
	cooldown = 45 SECONDS
	target_range = 1
	prefire_message = "Select a target."
	
/datum/action/bloodsucker/targeted/hecata/necromancy/CheckCanTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/current_target = target_atom // We already know it's carbon due to CheckValidTarget()
	// No mind
	if(!current_target.mind)
		to_chat(owner, span_warning("[current_target] is mindless."))
		return FALSE
	// Bloodsucker
	if(IS_BLOODSUCKER(current_target))
		to_chat(owner, span_notice("Bloodsuckers are immune to [src]."))
		return FALSE
	// Alive
	if(current_target.stat != DEAD)
		to_chat(owner, "[current_target] is still alive.")
		return FALSE
	return TRUE

/datum/action/bloodsucker/targeted/hecata/necromancy/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/target = target_atom
	var/mob/living/user = owner
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(target.stat == DEAD && user.Adjacent(target))
		owner.balloon_alert(owner, "attempting to revive...")
		if(!do_mob(user, target, 6 SECONDS, NONE, TRUE))
			return FALSE

		if(IS_VASSAL(target))
			PowerActivatedSuccessfully()
			to_chat(user, span_warning("We revive [target]!"))
			zombify(target)
			bloodsuckerdatum.clanprogress++ //counts a succesful necromancy towards your objective progress
			DeactivatePower()
			return
		if(IS_MONSTERHUNTER(target))
			to_chat(target, span_notice("Their body refuses to react..."))
			DeactivatePower()
			return
		if(!bloodsuckerdatum_power.attempt_turn_vassal(target, TRUE))
			return FALSE
		zombify(target)
		PowerActivatedSuccessfully()
		bloodsuckerdatum.clanprogress++ //counts a succesful necromancy towards your objective progress
		to_chat(user, span_warning("We revive [target]!"))
		var/living_time
		if(level_current == 1)
			living_time = 1 MINUTES
		else if(level_current == 2)
			living_time = 8 MINUTES
		else if(level_current == 3)
			living_time = 12 MINUTES
		else if(level_current >= 4)
			living_time = 15 MINUTES //in general, they don't last long, make the most of them.
		addtimer(CALLBACK(src, .proc/end_necromance, target), living_time)
	else //extra check, but this shouldn't happen
		owner.balloon_alert(owner, "Target is out of range or not dead yet.")
		return FALSE
	DeactivatePower()
	

/datum/action/bloodsucker/targeted/hecata/necromancy/proc/end_necromance(mob/living/user)
	user.mind.remove_antag_datum(/datum/antagonist/vassal)
	to_chat(user, span_warning("You feel the shadows around you weaken, your form falling limp like a puppet cut from its strings!"))
	user.set_species(/datum/species/krokodil_addict) //they will turn into a fake zombie on death, that still retains blood and isnt so powerful.
	user.death()

/datum/action/bloodsucker/targeted/hecata/necromancy/proc/zombify(mob/living/user)
	user.mind.grab_ghost()
	user.revive(full_heal = TRUE, admin_revive = TRUE)
	user.set_species(/datum/species/zombie/hecata) //imitation zombies that shamble around and beat people with their fists
	user.visible_message(span_danger("[user] suddenly convulses, as [user.p_they()] stagger to their feet and gain a ravenous hunger in [user.p_their()] eyes!"), span_alien("You RISE!"))
	playsound(owner.loc, 'sound/hallucinations/far_noise.ogg', 50, 1)
	to_chat(user, span_warning("Your broken form is picked up by strange shadows. If you were previously not a vassal, it is unlikely these shadows will be strong enough to keep you going for very long."))
	to_chat(user, span_notice("You are resilient to many things like the vacuum of space, can punch harder, and can take more damage before dropping. However, you are unable to use guns and are slower."))

//summon wraiths (weakened shades) to attack anyone who isn't a zombie. This includes non-zombified vassals. However, you can get around this by zombifying your vassals.
//to do this, you can make someone your favorite vassal, or you can kill them and then revive them with necromancy.
/datum/action/bloodsucker/hecata
	purchase_flags = HECATA_CAN_BUY
	button_icon = 'icons/mob/actions/actions_hecata_bloodsucker.dmi'
	icon_icon = 'icons/mob/actions/actions_hecata_bloodsucker.dmi'
	background_icon_state = "hecata_power_off"
	background_icon_state_on = "hecata_power_on"
	background_icon_state_off = "hecata_power_off"

/datum/action/bloodsucker/hecata/spiritcall
	name = "Spirit Call"
	level_current = 1
	desc = "Summon two angry wraiths which will attack anyone whose flesh is still alive. Summon amount increases as this ability levels up."
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
	cooldown = 60 SECONDS
	var/num_spirits = 2

/datum/action/bloodsucker/hecata/spiritcall/vassal //this variant has to exist, as hecata favorite vassals are technically in 'torpor'
	check_flags = BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS

/datum/action/bloodsucker/hecata/spiritcall/ActivatePower(mob/user = usr)
	. = ..()
	if(level_current == 2)
		num_spirits = 3
	else if(level_current >= 3)
		num_spirits = 4
	var/list/turf/locs = new
	for(var/direction in GLOB.alldirs) //looking for spirit spawns
		if(locs.len == num_spirits) //we found the number of spots needed and thats all we need
			break
		var/turf/T = get_step(usr, direction) //getting a loc in that direction
		if(AStar(user, T, /turf/proc/Distance, 1, simulated_only = 0)) // if a path exists, so no dense objects in the way its valid salid
			locs += T

	// pad with player location
	for(var/i = locs.len + 1 to num_spirits)
		locs += user.loc

	summonWraiths(locs, user = user)
	cast_effect() // POOF
	DeactivatePower()
	

/datum/action/bloodsucker/hecata/spiritcall/proc/summonWraiths(list/targets, mob/user = usr)
	for(var/T in targets)
		new /mob/living/simple_animal/hostile/bloodsucker/wraith(T)

/datum/action/bloodsucker/hecata/spiritcall/proc/cast_effect() //same as veil of many faces, makes smoke and stuff when casted
	// Effect
	playsound(get_turf(owner), 'sound/magic/smoke.ogg', 20, 1)
	var/datum/effect_system/steam_spread/puff = new /datum/effect_system/steam_spread/()
	puff.effect_type = /obj/effect/particle_effect/fluid/smoke/vampsmoke
	puff.set_up(3, 0, get_turf(owner))
	puff.attach(owner) //OPTIONAL
	puff.start()
	owner.spin(8, 1) //Spin around like a loon.

/datum/action/bloodsucker/hecata/communion
	name = "Deathly Communion"
	level_current = 1
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
	cooldown = 30 SECONDS

/datum/action/bloodsucker/hecata/communion/ActivatePower()
	. = ..()
	var/input = stripped_input(usr, "Choose a message to tell your vassals.", "Voice of Blood", "")
	if(!input || !IsAvailable())
		return FALSE

	deathly_commune(usr, input)

/datum/action/bloodsucker/hecata/communion/proc/deathly_commune(mob/living/user, message) //code from Fulpstation
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

