//this is mostly kind of bloodsucker abilities code since the base for powers there works very well
#define ZOMBIE_TOGGLEABLE "toggleable" //self explainable
#define ZOMBIE_FIREABLE "fireable" //same as above
#define ZOMBIE_INSTANT "instant" //yeah

/datum/action/innate/zombie
	name = "Putrid"
	desc = "make a bug report if you see this."
	background_icon_state = "bg_zombie"
	icon_icon = 'icons/mob/actions/actions_zombie.dmi'
	buttontooltipstyle = "cult"
	COOLDOWN_DECLARE(zombie_ability_cooldown)
	var/obj/effect/proc_holder/zombie/zombie_ph //proc_holder as in the one that holds the proc (it makes no sense)
	var/ability_type = null
	var/cooldown = 0
	var/fireable_power_usable = FALSE
	var/range = 99
	var/custom_mouse_icon = null

/datum/action/innate/zombie/New()
	. = ..()
	if(ability_type == ZOMBIE_FIREABLE)
		zombie_ph = new()
		zombie_ph.linked_power = src
	UpdateDesc()

/datum/action/innate/zombie/proc/UpdateDesc() //we ARE DOING THIS because i love information
	desc = initial(desc)
	if(cooldown)
		desc += "<br><br><b>COOLDOWN:</b><i> [name] has a cooldown of [cooldown / 10] seconds.</i>"

/datum/action/innate/zombie/Grant(mob/M)
	if(IS_INFECTED(M))
		var/datum/antagonist/zombie/zombie_owner = M.mind?.has_antag_datum(/datum/antagonist/zombie)
		zombie_owner.zombie_abilities += src
	. = ..()

/datum/action/innate/zombie/Remove(mob/M)
	if(IS_INFECTED(M))
		var/datum/antagonist/zombie/zombie_owner = M.mind?.has_antag_datum(/datum/antagonist/zombie)
		zombie_owner.zombie_abilities -= src
	. = ..()

/datum/action/innate/zombie/Destroy()
	if(active)
		STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/datum/action/innate/zombie/Trigger()
	if(!..())
		return FALSE

	if(ability_type == ZOMBIE_FIREABLE)
		var/mob/living/user = owner
		if(user.ranged_ability)
			user.ranged_ability.remove_ranged_ability()
		zombie_ph.add_ranged_ability(user)
	UpdateButtonIcon()
	return TRUE

/datum/action/innate/zombie/IsAvailable()
	if(!COOLDOWN_FINISHED(src, zombie_ability_cooldown))
		return FALSE
	if(!IS_INFECTED(owner))
		return FALSE
	. = ..()	

/datum/action/innate/zombie/Activate()
	switch(ability_type)
		if(ZOMBIE_TOGGLEABLE)
			START_PROCESSING(SSfastprocess, src)
		if(ZOMBIE_FIREABLE)
			fireable_power_usable = TRUE
			check_flags += AB_CHECK_CONSCIOUS
			owner?.client?.mouse_override_icon = custom_mouse_icon
		if(ZOMBIE_INSTANT)
			StartCooldown()
			return
	active = TRUE

/datum/action/innate/zombie/Deactivate(forced = FALSE)
	switch(ability_type)
		if(ZOMBIE_TOGGLEABLE)
			STOP_PROCESSING(SSfastprocess, src)
		if(ZOMBIE_FIREABLE)
			zombie_ph.remove_ranged_ability()
			fireable_power_usable = FALSE
	active = FALSE
	owner?.client?.mouse_override_icon = null
	owner?.update_mouse_pointer()
	UpdateButtonIcon()
	if(!forced && ability_type == ZOMBIE_FIREABLE)
		return
	StartCooldown()

/datum/action/innate/zombie/proc/StartCooldown()
	button.color = rgb(128,0,0,128)
	button.alpha = 100
	COOLDOWN_START(src, zombie_ability_cooldown, cooldown)
	addtimer(CALLBACK(src, .proc/alpha_in), cooldown)
	UpdateDesc() //qol

/datum/action/innate/zombie/proc/alpha_in()
	button.color = rgb(255,255,255,255)
	button.alpha = 255

/datum/action/innate/zombie/UpdateButtonIcon(force = FALSE)
	background_icon_state = active ? initial(background_icon_state) + "_on" : initial(background_icon_state)
	. = ..()

/datum/action/innate/zombie/proc/IsTargetable(atom/target_atom)
	if(!(target_atom in view(range, owner)))
		if(range > 1)
			to_chat(owner, span_warning("Target out of range."))
		return FALSE
	return istype(target_atom)

/datum/action/innate/zombie/proc/StartFiringAbility(atom/target_atom) //where we do initial checks and end
	if(target_atom == owner)
		return

	if(!fireable_power_usable)
		return

	if(!IsTargetable(target_atom))
		return

	UseFireableAbility(target_atom)
	Deactivate(TRUE)

/datum/action/innate/zombie/proc/UseFireableAbility(atom/target_atom)
	log_combat(owner, target_atom, "used zombie ability [name] on")
	
/obj/effect/proc_holder/zombie
	var/datum/action/innate/zombie/linked_power

/obj/effect/proc_holder/zombie/InterceptClickOn(mob/living/caller, params, atom/targeted_atom)
	return linked_power.StartFiringAbility(targeted_atom)

///Default abilities that all roundstart special zombies get. They need use infection points to be used and provide a significant bonus.
/datum/action/innate/zombie/default
	var/cost = 0
	var/constant_cost = 0

/datum/action/innate/zombie/default/UpdateDesc()
	. = ..()
	if(cost || constant_cost)
		desc += "<br><br><b>COST:</b> name costs [cost] to activate [cost ? "and" : "but"] consumes [constant_cost] to maintain active."

/datum/action/innate/zombie/default/IsAvailable()
	var/datum/antagonist/zombie/zombie_owner = owner.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(zombie_owner?.infection < cost)
		return FALSE
	. = ..()

/datum/action/innate/zombie/default/Activate()
	var/datum/antagonist/zombie/zombie_owner = owner.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(zombie_owner.zombie_mutations["reduced_cost"] || ability_type != ZOMBIE_INSTANT)
		cost = initial(cost) / 2
	if(ability_type == ZOMBIE_TOGGLEABLE || ability_type == ZOMBIE_INSTANT)
		if(!zombie_owner.manage_infection(cost)) //failsafe
			to_chat(owner, span_warning("You don't have enough infection points to activate this ability!"))
			return
	. = ..()

/datum/action/innate/zombie/default/UseFireableAbility()
	. = ..()
	var/datum/antagonist/zombie/zombie_owner = owner.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(!zombie_owner.manage_infection(cost))
		to_chat(owner, span_warning("You don't have enough infection points to activate this ability!"))
		Deactivate()
		return

/datum/action/innate/zombie/default/process()
	UpdateButtonIcon()
	var/datum/antagonist/zombie/zombie_owner = owner.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(!zombie_owner.manage_infection(constant_cost))
		to_chat(owner, span_warning("You don't have enough infection points to maintain this ability active!"))
		Deactivate()
		return

/datum/action/innate/zombie/menu
	name = "Menu"
	desc = ""
	button_icon_state = "adaptation_menu"
	ability_type = ZOMBIE_INSTANT

/datum/action/innate/zombie/menu/Activate()
	var/datum/antagonist/zombie/zombie_owner = owner.mind?.has_antag_datum(/datum/antagonist/zombie)
	zombie_owner.ui_interact(owner)
	. = ..()

/datum/action/innate/zombie/zomb
	name = "Zombify!"
	desc = "Initiate the infection, and kill this host.. THIS ACTION IS INSTANT."
	button_icon_state = "zombify"
	ability_type = ZOMBIE_INSTANT

/datum/action/innate/zombie/zomb/Activate(forced = FALSE)
	var/mob/living/carbon/human/H = owner
	var/datum/antagonist/zombie/zombie_owner = H.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(!forced)
		if(tgui_alert(H, "Are you sure you want to kill yourself, and revive as a zombie some time after?", "Confirmation", list("Yes", "No")) == "No")
			return FALSE

	if(!H.getorganslot(ORGAN_SLOT_ZOMBIE))
		var/obj/item/organ/zombie_infection/gamemode/special/ZI = new()
		ZI.Insert(H)

	H.mind?.zombified = TRUE
	H.death()
	zombie_owner.zombify.Remove(H)
	zombie_owner.zombified = TRUE
	zombie_owner.uncuff.Grant(H)
	zombie_owner.advance_mutation_tier()
	. = ..()

/datum/action/innate/zombie/uncuff
	name = "Break Free!"
	desc = "Breaks you free from handcuffs."
	button_icon_state = "uncuff"

/datum/action/innate/zombie/uncuff/Activate(forced = FALSE)
	var/mob/living/carbon/human/H = usr
	H.uncuff()


/datum/action/innate/zombie/talk
	name = "Chat"
	desc = "Chat with your fellow infected."
	button_icon_state = "zombie_comms"

/datum/action/innate/zombie/talk/Activate()
	var/input = stripped_input(usr, "Please choose a message to tell to the other zombies.", "Infected Communications", "")
	if(!input || !IsAvailable())
		return

	talk(usr, input)

/datum/action/innate/zombie/talk/proc/talk(mob/living/user, message)
	var/my_message
	if(!message)
		return
	my_message = span_cult("<font size = 5>(Zombie)</font> <font size = 4>[findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]: [message]</font>")
	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(IS_INFECTED(M))
			to_chat(M, my_message)
		else if(M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [my_message]")

	user.log_talk(message, LOG_SAY, tag="zombie")

/datum/action/innate/zombie/choose_class
	name = "Evolve"
	desc = "Evolve into a special class."
	button_icon_state = "evolve"
	ability_type = ZOMBIE_INSTANT

/datum/action/innate/zombie/choose_class/Activate()
	var/list/zombie_classes = list(SMOKER, RUNNER, SPITTER, JUGGERNAUT) //brainy is currently broken
	var/selected = null
	var/list/radial_menu = list()
	for(var/I in zombie_classes)
		radial_menu[I] = image('icons/mob/zombie_base.dmi', icon_state = "[I]")
	selected = show_radial_menu(owner, owner, radial_menu, tooltips = TRUE)
	if(!selected || !IsAvailable())
		return
	if(!isinfectedzombie(owner))
		return
	evolve(selected)
	. = ..()

/datum/action/innate/zombie/choose_class/IsAvailable(forced = FALSE)
	if(!IS_INFECTED(owner))
		return
	var/datum/antagonist/zombie/Z = locate() in owner.mind.antag_datums

	if(Z.class_chosen && !forced)
		return FALSE
	return ..()

/datum/action/innate/zombie/choose_class/proc/evolve(class)
	var/mob/living/carbon/human/H = owner
	var/datum/antagonist/zombie/zombie_owner = owner?.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(!IS_INFECTED(H))
		return
	var/list/class_powers = list()
	switch(class)
		if(SMOKER)
			class_powers = list(new /datum/action/innate/zombie/default/smoke, new /datum/action/innate/zombie/scorch)
			H.set_species(/datum/species/zombie/infectious/gamemode/smoker)
		if(RUNNER)
			class_powers = list(new /datum/action/innate/zombie/default/endure, new /datum/action/innate/zombie/parkour)
			H.set_species(/datum/species/zombie/infectious/gamemode/runner)
			to_chat(owner, span_warning("You can now run, and your movement speed is considerably faster. You do less damage and can take less damage though."))
		if(SPITTER)
			class_powers = list(new /datum/action/innate/zombie/default/overclock, new /datum/action/innate/zombie/default/spit)
			H.set_species(/datum/species/zombie/infectious/gamemode/spitter)
			to_chat(owner, span_warning("You can now click on walls and doors, and cover them in acid! You are weaker in combat though."))
		if(JUGGERNAUT)
			class_powers = list(new /datum/action/innate/zombie/default/rage, new /datum/action/innate/zombie/charge)
			H.set_species(/datum/species/zombie/infectious/gamemode/juggernaut)
			to_chat(owner, span_warning("You can now take quite a beating, and heal a bit slower."))
		if(BRAINY)
			var/mob/living/simple_animal/horror/brainy/B = new(get_turf(owner))
			B?.zombie_owner = zombie_owner
			owner.mind.transfer_to(B)
			qdel(owner)
	if(class_powers.len)
		for(var/datum/action/innate/zombie/ability as anything in class_powers)
			ability.Grant(owner)

	owner.visible_message(span_danger("[owner] suddenly convulses, as [owner.p_they()] evolve into a [class]!"), span_alien("You have evolved into a [class]"))
	playsound(owner.loc, 'sound/hallucinations/far_noise.ogg', 50, TRUE)
	Remove(owner)
	zombie_owner.class_chosen = class
	if(ishuman(owner))
		H.do_jitter_animation(15)

/datum/action/innate/zombie/last_resort
	name = "Evolve"
	desc = "Evolve into a special class."
	button_icon_state = "evolve"
	ability_type = ZOMBIE_INSTANT

/datum/action/innate/zombie/last_resort/Activate()
	if(tgui_alert(owner, "Are you sure you want to violently leave your host?", "Horror Hotline", list("Yes", "No")) == "No")
		return
	var/mob/living/carbon/host_body = owner
	var/mob/living/simple_animal/hostile/headcrab/horrorworm/escape = new(get_turf(owner))
	owner.mind.transfer_to(escape)
	var/obj/item/organ/brain/brain = host_body.getorganslot(ORGAN_SLOT_BRAIN) //from /obj/item/gun/ballistic/suicide_act
	var/turf/T = get_turf(host_body)
	host_body.visible_message(span_warning("[host_body]'s blows up, spraying blood everywhere!"))
	var/turf/target = get_ranged_target_turf(host_body, turn(host_body.dir, 180), 3)
	brain.Remove(host_body)
	brain.forceMove(T)
	var/datum/callback/gibspawner = CALLBACK(GLOBAL_PROC, /proc/spawn_atom_to_turf, /obj/effect/gibspawner/generic, brain, 1, FALSE, host_body)
	brain.throw_at(target, 3, 1, callback=gibspawner)	
	. = ..()

/datum/action/innate/zombie/bite //common zombie W
	name = "Rotten Bite"
	desc = "Charges your mouth with a powerful agent."
	button_icon_state = "bite"
	ability_type = ZOMBIE_FIREABLE

/datum/action/innate/zombie/bite/IsTargetable(atom/target_atom)
	return isliving(target_atom)

/datum/action/innate/zombie/bite/UseFireableAbility()
	. = ..()
	var/mob/living/le_target = target
	le_target.apply_status_effect(STATUS_EFFECT_ZOMBIE_ROT)
