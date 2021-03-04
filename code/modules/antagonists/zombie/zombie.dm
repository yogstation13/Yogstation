#define TIER_2_TIME 4500

/datum/antagonist/zombie
	name = "Zombie"
	roundend_category = "zombies"
	antagpanel_category = "Zombie"

	var/datum/action/innate/zombie/zomb/zombify = new

	var/datum/action/innate/zombie/talk/talk_action = new

	var/datum/action/innate/zombie/choose_class/evolution = new

	var/datum/action/innate/zombie/choose_class/tier2/evolution2 = new

	//EVOLUTION
	var/evolutionTime = 0 //When can we evolve?

	//GENERAL ABILITIES
	var/datum/action/innate/zombie/uncuff/uncuff = new

	//SPITTER ABILITIES
	var/obj/effect/proc_holder/zombie/spit/spit
	var/obj/effect/proc_holder/zombie/acid/acid

	//Necromancer
	var/obj/effect/proc_holder/zombie/necromance/necro

	//Runner
	var/obj/effect/proc_holder/zombie/adrenaline/adren

	//Juggernaut
	var/obj/effect/proc_holder/zombie/tank/tank

	job_rank = ROLE_ZOMBIE

	var/datum/team/zombie/team
	var/hud_type = "zombie"

	var/class_chosen = FALSE
	var/class_chosen_2 = FALSE

	var/spit_cooldown = 0

	var/zombified = FALSE

	var/evolution_ready = FALSE


/datum/antagonist/zombie/create_team(datum/team/zombie/new_team)
	if(!new_team)
		for(var/HU in GLOB.zombies)
			var/datum/antagonist/zombie/H = HU
			if(!H.owner)
				continue
			if(H.team)
				team = H.team
				return
		team = new /datum/team/zombie
		team.setup_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team

/datum/antagonist/zombie/proc/add_objectives()
	objectives |= team.objectives

/datum/antagonist/zombie/Destroy()
	QDEL_NULL(zombify)
	return ..()


/datum/antagonist/zombie/greet()
	to_chat(owner.current, "<B><font size=3 color=red>You have been infected with a zombie virus! In 15 minutes you will be able to turn into a zombie...</font><B>")
	to_chat(owner.current, "<b>Use the button at the top of the screen (When it appears) to activate the infection. It will kill you, but you will rise as a zombie shortly after!<b>") //Yogs
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ling_aler.ogg', 100, FALSE, pressure_affected = FALSE)//subject to change
	owner.announce_objectives()

/datum/antagonist/zombie/on_gain()
	. = ..()
	var/mob/living/current = owner.current
	add_objectives()
	GLOB.zombies += owner

	current.log_message("has been made a zombie!", LOG_ATTACK, color="#960000")

	var/datum/atom_hud/antag/zombie_hud = GLOB.huds[ANTAG_HUD_ZOMBIE]
	zombie_hud.join_hud(current)
	set_antag_hud(current, hud_type)


/datum/antagonist/zombie/apply_innate_effects()
	. = ..()
	var/mob/living/current = owner.current
	current.faction |= "zombies"
	talk_action.Grant(current)

/datum/antagonist/zombie/remove_innate_effects()
	. = ..()
	var/mob/living/current = owner.current
	current.faction -= "zombies"
	talk_action.Remove(current)


/datum/antagonist/zombie/on_removal()
	GLOB.zombies -= owner

	var/datum/atom_hud/antag/zombie_hud = GLOB.huds[ANTAG_HUD_ZOMBIE]
	zombie_hud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)
	. = ..()


/datum/antagonist/zombie/proc/start_timer()
	addtimer(CALLBACK(src, .proc/add_button_timed), 15 MINUTES)

/datum/antagonist/zombie/proc/add_button_timed()
	zombify.Grant(owner.current)
	to_chat(owner.current, "<span class='userdanger'><b>You can now turn into a zombie! The ability INSTANTLY kills you, and starts the process of turning into a zombie. IN 5 MINUTES YOU WILL FORCIBLY BE ZOMBIFIED IF YOU HAVEN'T.<b></span>")
	addtimer(CALLBACK(src, .proc/force_zombify), 5 MINUTES)

/datum/antagonist/zombie/proc/force_zombify()
	if(!zombified)
		zombify.Activate()

/datum/antagonist/zombie/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has zombied'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has zombied'ed [key_name(new_owner)].")
	start_timer()


/datum/antagonist/zombie/get_admin_commands()
	. = ..()
	.["Give Button"] = CALLBACK(src,.proc/admin_give_button)
	.["Remove Button"] = CALLBACK(src,.proc/remove_button)

/datum/antagonist/zombie/proc/admin_give_button(mob/admin)
	zombify.Grant(owner.current)

/datum/antagonist/zombie/proc/remove_button(mob/admin)
	zombify.Remove(owner.current)

/datum/antagonist/zombie/proc/start_evolution_2()
	addtimer(CALLBACK(src, .proc/finish_evolution_2), TIER_2_TIME)

/datum/antagonist/zombie/proc/finish_evolution_2()
	evolution_ready = TRUE
	evolution2.Grant(owner.current)
	to_chat(owner.current, "<span class='userdanger'><b>You can now evolve into a Tier 2 zombie! There can only be tier 2 zombies equal to the amount of starting zombies!<b></span>")

/datum/team/zombie
	name = "Zombies"

/datum/team/zombie/proc/setup_objectives()

	var/datum/objective/custom/obj = new()
	obj.name = "Escape on the shuttle, while gathering as many infected as possible!"
	obj.explanation_text = "Escape on the shuttle, while gathering as many infected as possible!"
	obj.completed = TRUE
	objectives += obj


/datum/team/zombie/proc/zombies_on_shuttle()
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(isinfected(H) && (H.onCentCom() || H.onSyndieBase()))
			return TRUE
	return FALSE

/datum/team/zombie/roundend_report()
	var/list/parts = list()
	if(zombies_on_shuttle())
		parts += "<span class='greentext big'>BRAINS! The zombies have made it to CentCom!</span>"
	else
		parts += "<span class='redtext big'>Target destroyed. The crew has stopped the zombies!</span>"


	if(members.len)
		parts += "<span class='header'>The zombies were:</span>"
		parts += printplayerlist(members)

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/action/innate/zombie
	icon_icon = 'icons/mob/actions/actions_changeling.dmi'
	background_icon_state = "bg_demon"
	buttontooltipstyle = "cult"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS

/datum/action/innate/zombie/IsAvailable()
	if(!isinfected(owner))
		return FALSE
	return ..()

/datum/action/innate/zombie/zomb
	name = "Zombify!"
	desc = "Initiate the infection, and kill this host.. THIS ACTION IS INSTANT."
	button_icon_state = "chameleon_skin"

/datum/action/innate/zombie/zomb/Activate(forced = FALSE)
	var/mob/living/carbon/human/H = usr
	var/datum/antagonist/zombie/Z = locate() in owner.mind.antag_datums
	if(!forced)
		if(alert(H, "Are you sure you want to kill yourself, and revive as a zombie some time after?", "Confirmation", "Yes", "No") == "No")
			return FALSE

	if(!H.getorganslot(ORGAN_SLOT_ZOMBIE))
		var/obj/item/organ/zombie_infection/gamemode/ZI = new()
		ZI.Insert(H)

	if(H.mind)
		H.mind.zombified = TRUE
	H.death()
	Z.zombify.Remove(H)
	Z.zombified = TRUE
	Z.uncuff.Grant(H)
	Z.evolutionTime = TIER_2_TIME + world.time
	Z.start_evolution_2()




/datum/action/innate/zombie/talk
	name = "Chat"
	desc = "Chat with your fellow infected."
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "cult_comms"

/datum/action/innate/zombie/talk/Activate()
	var/input = stripped_input(usr, "Please choose a message to tell to the other zombies.", "Infected Communications", "")
	if(!input || !IsAvailable())
		return

	talk(usr, input)

/datum/action/innate/zombie/talk/proc/talk(mob/living/user, message)
	var/my_message
	if(!message)
		return
	var/title = "Zombie"
	var/span = "cult"
	my_message = "<span class='[span]'><b>\[[title]] [findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]:</b> [message]</span>"
	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(isinfected(M))
			to_chat(M, my_message)
		else if(M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [my_message]")

	user.log_talk(message, LOG_SAY, tag="zombie")

/datum/action/innate/zombie/choose_class
	name = "Evolve"
	desc = "Evolve into a special class."
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "cultfist"

/datum/action/innate/zombie/choose_class/Activate()
	var/selected = input(usr, "Choose a class to evolve into", "Evolution") as null|anything in list("Runner", "Juggernaut", "Spitter")
	if(!selected || !IsAvailable())
		return
	if(!isinfectedzombie(owner))
		return
	evolve(selected)

/datum/action/innate/zombie/choose_class/IsAvailable(forced = FALSE)
	if(!isinfected(owner))
		return
	var/datum/antagonist/zombie/Z = locate() in owner.mind.antag_datums

	if(Z.class_chosen && !forced)
		return FALSE
	return ..()

/datum/action/innate/zombie/choose_class/proc/evolve(class)
	var/mob/living/carbon/human/H = owner
	var/datum/antagonist/zombie/Z = locate() in owner.mind.antag_datums
	if(!isinfected(H))
		return
	switch(class)
		if("Runner")
			H.set_species(/datum/species/zombie/infectious/gamemode/runner)
			Z.adren = new()
			H.AddAbility(Z.adren)
			to_chat(owner, "<span class='warning'>You can now run, and your movement speed is considerably faster. You do less damage and can take less damage though.</span>")
		if("Juggernaut")
			H.set_species(/datum/species/zombie/infectious/gamemode/juggernaut)
			Z.tank = new()
			H.AddAbility(Z.tank)
			to_chat(owner, "<span class='warning'>You can now take quite a beating, and heal a bit slower.</span>")
		if("Spitter")
			H.set_species(/datum/species/zombie/infectious/gamemode/spitter)
			Z.spit = new()
			Z.acid = new()
			H.AddAbility(Z.spit)
			H.AddAbility(Z.acid)
			to_chat(owner, "<span class='warning'>You can now right click on walls and doors, and cover them in acid! You are weaker in combat though.</span>")

	owner.visible_message("<span class='danger'>[owner] suddenly convulses, as [owner.p_they()] evolve into a [class]!</span>", "<span class='alien'>You have evolved into a [class]</span>")
	playsound(owner.loc, 'sound/hallucinations/far_noise.ogg', 50, 1)
	H.do_jitter_animation(15)
	Z.evolution.Remove(H)
	Z.class_chosen = TRUE

/datum/action/innate/zombie/choose_class/tier2
	name = "Evolve - Tier 2"
	desc = "Evolve into a Tier 2 special class."
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "cultfist"

/datum/action/innate/zombie/choose_class/tier2/IsAvailable()
	if(!isinfected(owner))
		return
	var/datum/antagonist/zombie/Z = locate() in owner.mind.antag_datums

	if(Z.class_chosen_2)
		return FALSE

	if(!Z.class_chosen)
		return FALSE
	return ..(TRUE)

/datum/action/innate/zombie/choose_class/tier2/Activate()
	var/selected = input(usr, "Choose a class to evolve into", "Evolution") as null|anything in list("Necromancer")
	if(!selected || !IsAvailable())
		return
	if(!isinfectedzombie(owner))
		return

	var/datum/game_mode/zombie/mode = SSticker.mode
	if(!mode.can_evolve_tier_2())
		to_chat(usr, "<span class='userdanger'>There are currently too many tier 2 zombies. Please wait.</span>")
		return
	evolve(selected)

/datum/action/innate/zombie/choose_class/tier2/evolve(class)
	var/mob/living/carbon/human/H = owner
	var/datum/antagonist/zombie/Z = locate() in owner.mind.antag_datums
	if(!isinfected(H))
		return
	switch(class)
		if("Necromancer")
			H.set_species(/datum/species/zombie/infectious/gamemode/necromancer)
			Z.necro = new()
			H.AddAbility(Z.necro)
			to_chat(owner, "<span class='warning'>You can now run, and your movement speed is considerably faster. You do less damage and can take less damage though.</span>")
		if("Coordinator")
			H.set_species(/datum/species/zombie/infectious/gamemode/coordinator)
			to_chat(owner, "<span class='warning'>You can now communicate with the horde!</span>")


	if(Z.spit)
		H.RemoveAbility(Z.spit)
	if(Z.acid)
		H.RemoveAbility(Z.acid)
	if(Z.adren)
		H.RemoveAbility(Z.adren)
	if(Z.tank)
		H.RemoveAbility(Z.tank)


	owner.visible_message("<span class='danger'>[owner] suddenly convulses, as [owner.p_they()] evolve into a [class]!</span>", "<span class='alien'>You have evolved into a [class]</span>")
	playsound(owner.loc, 'sound/hallucinations/far_noise.ogg', 50, 1)
	H.do_jitter_animation(15)
	Z.evolution2.Remove(H)
	Z.class_chosen_2 = TRUE

/obj/effect/proc_holder/zombie
	name = "Zombie Power"
	panel = "Zombie"
	has_action = TRUE
	base_action = /datum/action/spell_action
	action_icon = 'icons/mob/actions/actions_xeno.dmi'
	action_icon_state = "spell_default"
	action_background_icon_state = "bg_alien"
	var/ready = TRUE
	var/cooldown_ends = 0
	var/cooldown_time = 1 SECONDS

	var/silent = TRUE //Do you have to be conscious to use this?

/obj/effect/proc_holder/zombie/Initialize()
	. = ..()
	action = new(src)

/obj/effect/proc_holder/zombie/Click()
	if(!iscarbon(usr))
		return TRUE
	var/mob/living/carbon/user = usr
	if(can_cast(user))
		fire(user)
	return TRUE

/obj/effect/proc_holder/zombie/on_gain(mob/living/carbon/user)
	return

/obj/effect/proc_holder/zombie/on_lose(mob/living/carbon/user)
	return

/obj/effect/proc_holder/zombie/fire(mob/living/carbon/user)
	start_cooldown()
	return TRUE

/obj/effect/proc_holder/zombie/get_panel_text()
	. = ..()
	if((cooldown_ends - world.time) > 0)
		return "[(cooldown_ends - world.time) / 10] seconds"

/obj/effect/proc_holder/zombie/proc/can_cast(mob/living/carbon/user)
	if(!isinfected(user))
		return FALSE

	if(user.stat)
		if(!silent)
			to_chat(user, "<span class='userdanger'>You must be conscious to do this.</span>")
		return FALSE
	if(!ready)
		to_chat(user, "<span class='userdanger'>You can use this ability in [(cooldown_ends - world.time) / 10] seconds.</span>")

	return ready

/obj/effect/proc_holder/zombie/proc/reset_cooldown()
	ready = TRUE

/obj/effect/proc_holder/zombie/proc/start_cooldown()
	addtimer(CALLBACK(src, .proc/reset_cooldown), cooldown_time)
	cooldown_ends = world.time + cooldown_time
	ready = FALSE

#undef TIER_2_TIME