/datum/action/bloodsucker/targeted/hecata/necromancy
	name = "Necromancy"
	level_current = 1
	desc = "Raise the dead as temporary vassals, or revive a dead vassal. Temporary vassals last longer as this ability ranks up."
	button_icon_state = "power_necromancy"
	button_icon = 'icons/mob/actions/actions_hecata_bloodsucker.dmi'
	icon_icon = 'icons/mob/actions/actions_hecata_bloodsucker.dmi'
	background_icon_state = "hecata_power_off"
	background_icon_state_on = "hecata_power_on"
	background_icon_state_off = "hecata_power_off"
	power_explanation = "Necromancy:\n\
		Click on a corpse in order to attempt to resurrect them.\n\
		Non-vassals will become temporary, zombie-like vassals. Dead vassals are revived.\n\
		Vassaling people this way does not grant ranks. In addition, after their time is up they will die and no longer be your vassal."
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_UNCONSCIOUS
	bloodcost = 50
	cooldown = 60 SECONDS
	target_range = 1
	prefire_message = "Select a target."

/datum/action/bloodsucker/targeted/hecata/necromancy/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/target = target_atom
	var/mob/living/user = owner
	if(target.stat == DEAD && user.Adjacent(target))
		attempt_resurrection(target, user)
		return
	else
		owner.balloon_alert(owner, "Target is out of range or not dead yet.")
	attempt_resurrection(target, user)

/datum/action/bloodsucker/targeted/hecata/necromancy/proc/attempt_resurrection(mob/living/target, mob/living/user)
	owner.balloon_alert(owner, "attempting to revive...")
	if(!do_mob(user, target, 6 SECONDS, NONE, TRUE))
		return

	if(IS_VASSAL(target))
		PowerActivatedSuccessfully()
		to_chat(user, span_warning("We revive [target]!"))
		target.mind.grab_ghost()
		target.revive(full_heal = TRUE, admin_revive = TRUE)
		return
	if(IS_MONSTERHUNTER(target))
		to_chat(target, span_notice("Their body refuses to react..."))
		return
	if(!bloodsuckerdatum_power.attempt_turn_vassal(target, TRUE))
		return
	PowerActivatedSuccessfully()
	to_chat(user, span_warning("We revive [target]!"))
	target.mind.grab_ghost()
	target.revive(full_heal = TRUE, admin_revive = TRUE)
	var/living_time
	target.set_species(/datum/species/krokodil_addict) //slightly weaker than a normal person
	if(level_current == 1)
		living_time = 5 MINUTES
	else if(level_current == 2)
		living_time = 8 MINUTES
	else if(level_current == 3)
		living_time = 12 MINUTES
	else if(level_current >= 4)
		living_time = 15 MINUTES
	addtimer(CALLBACK(src, .proc/end_necromance, target), living_time)

/datum/action/bloodsucker/targeted/hecata/necromancy/proc/end_necromance(mob/living/user)
	user.mind.remove_antag_datum(/datum/antagonist/vassal)
	to_chat(user, span_warning("You feel the Blood of your Master run out!"))
	target.set_species(/datum/species/krokodil_addict) //they will turn into a fake zombie on death, that still retains blood.
	user.death()
