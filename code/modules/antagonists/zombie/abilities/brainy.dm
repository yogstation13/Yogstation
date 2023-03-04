/mob/living/simple_animal/horror/brainy
	name = "brainy" //tis
	desc = "An open head on what looks like 4 measly legs, what the hell?"
	icon_state = "brainy"
	icon_living = "brainy"
	icon_dead = "brainy_dead"
	icon_gib = "brainy_gib"
	health = 100
	maxHealth = 100
	speed = -1.1
	see_in_dark = 10
	pass_flags = PASSTABLE | PASSGRILLE
	abilities_to_give = list(/datum/action/innate/zombie/pounce, /datum/action/innate/horror/talk_to_host, /datum/action/innate/horror/toggle_hide, 
							/datum/action/innate/horror/talk_to_brain, /datum/action/innate/horror/take_control, /datum/action/innate/horror/leave_body,
							/datum/action/innate/horror/give_back_control)
	hud_type = /datum/hud/zombie
	var/leaping = FALSE
	var/full_control = FALSE
	var/datum/antagonist/zombie/zombie_owner = null

/mob/living/simple_animal/horror/brainy/Initialize()
	. = ..()
	real_name = name
	RefreshAbilities(TRUE)
	update_horror_hud()

/* /mob/living/simple_animal/horror/brainy/update_horror_hud() //i simply cannot get this to work
	var/datum/hud/zombie/Z = hud_used
	var/atom/movable/screen/counter = Z.infection_display
	counter.invisibility = 0
	if(zombie_owner.class_chosen)
		counter.add_overlay("overlay_[zombie_owner.class_chosen]")
	counter.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:7px'><font color='#E6E6C6'>[round(zombie_owner.infection, 1)]</font></div>" */

/mob/living/simple_animal/horror/brainy/update_icons()
	icon_state = leaping ? initial(icon_state) + "_leap" : initial(icon_state)

/mob/living/simple_animal/horror/brainy/RefreshAbilities(on_spawn = FALSE)
	if(on_spawn)
		GrantHorrorActions()
	if(!zombie_owner)
		return
	. = ..()

/mob/living/simple_animal/horror/brainy/add_ability(typepath)
	if(has_ability(typepath))
		return
	var/datum/action/ability = new typepath
	horrorabilities += ability
	if(istype(ability, /datum/action/innate/horror))
		var/datum/action/innate/horror/action = ability
		action.horror_owner = src //this surprisingly took a while
	RefreshAbilities()

/mob/living/simple_animal/horror/brainy/has_ability(typepath)
	for(var/datum/action/ability as anything in zombie_owner?.zombie_abilities)
		if(istype(ability, typepath))
			return ability
	return ..()

/mob/living/simple_animal/horror/brainy/regenerate_chemicals(amt)
	if(!IS_SPECIALINFECTED(src))
		return
	zombie_owner?.manage_infection(-amt)

/mob/living/simple_animal/horror/brainy/has_chemicals(amt)
	return zombie_owner?.infection >= amt

/mob/living/simple_animal/horror/brainy/use_chemicals(amt)
	return zombie_owner?.manage_infection(amt)

/mob/living/simple_animal/horror/brainy/detach()
	if(full_control && victim.stat != DEAD)
		victim.death()
		animate(victim, color = initial(color), time = 1 SECONDS)
		victim.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5, 60)
	. = ..()

/mob/living/simple_animal/horror/brainy/GrantHorrorActions()
	. = ..()
	var/list/abilities_to_grant = list(new /datum/action/innate/zombie/pounce) //hardcoded like this to prevent shitton of vars but if you want to refactor it go ahead
	for(var/datum/action/ability as anything in abilities_to_grant)
		ability.Grant(src)

/mob/living/simple_animal/horror/brainy/RemoveHorrorActions()
	. = ..()
	var/list/abilities_to_remove = list(/datum/action/innate/zombie/pounce)
	for(var/datum/action/ability as anything in zombie_owner?.zombie_abilities)
		if(is_type_in_list(ability, abilities_to_remove))
			ability.Remove(src)

/mob/living/simple_animal/horror/brainy/GrantInfestActions()
	. = ..()
	var/list/abilities_to_grant = list(new /datum/action/innate/zombie/default/takeover, new /datum/action/innate/zombie/default/infest, new /datum/action/innate/zombie/morph)
	for(var/datum/action/ability as anything in abilities_to_grant)
		ability.Grant(src)

/mob/living/simple_animal/horror/brainy/RemoveInfestActions()
	. = ..()
	var/list/abilities_to_remove = list(/datum/action/innate/zombie/default/takeover, /datum/action/innate/zombie/default/infest, /datum/action/innate/zombie/morph)
	for(var/datum/action/ability as anything in zombie_owner?.zombie_abilities)
		if(is_type_in_list(ability, abilities_to_remove))
			ability.Remove(src)

/mob/living/simple_animal/horror/brainy/GrantControlActions()
	. = ..()
	var/list/abilities_to_grant = list(new /datum/action/innate/zombie/morph)
	for(var/datum/action/ability as anything in abilities_to_grant)
		ability.Grant(victim)

/mob/living/simple_animal/horror/brainy/RemoveControlActions()
	. = ..()
	var/list/abilities_to_remove = list(/datum/action/innate/zombie/morph)
	for(var/datum/action/ability as anything in zombie_owner?.zombie_abilities)
		if(is_type_in_list(ability, abilities_to_remove))
			ability.Remove(victim)

////////////////////////////////////////////////////////////////////////////ABILITY LINE BREAKER////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////->IF YOU WANT TO ADD NEW ABILITIES REMEMBER TO ADD THEM TO THE LISTS ABOVE<-//////////////////////////////////////////////////////
/datum/action/innate/horror/UpdateButtonIcon(force = FALSE)
	icon_icon = isbrainy(horror_owner) ? 'icons/mob/actions/actions_zombie.dmi' : initial(icon_icon)
	background_icon_state = isbrainy(horror_owner) ? "bg_zombie" :  initial(background_icon_state)
	. = ..()

/datum/action/innate/zombie/pounce
	name = "Pounce"
	desc = "Jump in a single direction, squeezing through what you can and knocking down what you can't."
	button_icon_state = "pounce"
	ability_type = ZOMBIE_FIREABLE
	cooldown = 7.5 SECONDS
	custom_mouse_icon = 'icons/effects/mouse_pointers/zombie_pounce.dmi'

/datum/action/innate/zombie/pounce/Trigger()
	if(isbrainy(owner))
		var/mob/living/simple_animal/horror/brainy/B = owner
		B.leaping = !B.leaping
		B.update_icons()
	. = ..()

/datum/action/innate/zombie/pounce/IsTargetable(atom/target_atom)
	return isliving(target_atom) || isopenturf(target_atom) || istype(target_atom, /obj/machinery/door)

/datum/action/innate/zombie/pounce/UseFireableAbility(atom/target_atom)
	. = ..()
	var/mob/living/L = owner
	owner.throw_at(get_turf(target_atom), 7, 1, owner, FALSE, callback = CALLBACK(src, .proc/throw_end))
	L.Immobilize(30 SECONDS)
	RegisterSignal(L, COMSIG_MOVABLE_BUMP, .proc/pounce_end, override = TRUE)

/datum/action/innate/zombie/pounce/proc/pounce_end(mob/living/user, atom/victim)
	if(isliving(victim))
		var/mob/living/L = victim
		to_chat(L, span_danger("You feel something hit your head, dropping you to the ground!"))
		L.Immobilize(5 SECONDS)
		L.Knockdown(10 SECONDS)
	if(isclosedturf(victim))
		throw_end()
	if(isstructure(victim) || ismachinery(victim))
		var/obj/O = victim
		if(istype(O, /obj/machinery/door))
			if(istype(O, /obj/machinery/door/window))
				var/obj/machinery/door/D = O
				D.open()
			owner.forceMove(get_turf(O)) //plop
		O.take_damage(10)
		user.adjustBruteLoss(2.5) //hurtie
	throw_end()

/datum/action/innate/zombie/pounce/proc/throw_end()
	var/mob/living/L = owner
	UnregisterSignal(L, COMSIG_MOVABLE_BUMP)
	L.SetImmobilized(0)
	if(isbrainy(owner))
		var/mob/living/simple_animal/horror/brainy/brainy_owner = owner
		brainy_owner.leaping = FALSE
	owner.update_icons()

/datum/action/innate/zombie/default/takeover
	name = "Brain Hijacking"
	desc = "Immediately takes control of your current hosts, but permanently rots their brain, rotting them from inside and exposing your presence."
	button_icon_state = "takeover"
	ability_type = ZOMBIE_INSTANT
	cost = 100
	var/doing_it = FALSE

/datum/action/innate/zombie/default/takeover/Activate()
	if(doing_it)
		return
	doing_it = TRUE
	if(tgui_alert(owner, "Doing this will give you immediate full control but slowly rot your host, are you sure you wanna do this?", "Saving grace", list("Yes", "No")) != "Yes")
		return
	if(!isbrainy(owner))
		return
	var/mob/living/simple_animal/horror/brainy/brainy_owner = owner
	if(!brainy_owner.victim)	
		to_chat(owner, "[brainy_owner.victim] has no mind!") //for now
		return
	. = ..() //this comes here so you don't actually pay if you don't activate the ability
	brainy_owner.full_control = TRUE
	to_chat(brainy_owner, span_warning("You mush your host's brain with your claws. [brainy_owner.victim.p_their(TRUE)] corpse will rot quickly."))
	rot(brainy_owner.victim)
	brainy_owner.assume_control()

/datum/action/innate/zombie/default/takeover/proc/rot(mob/living/victim)
	animate(victim, color = rgb(140, 163, 46), time = 20 MINUTES)
	addtimer(CALLBACK(victim, .proc/brain_failure, victim), 2.5 MINUTES)
	addtimer(CALLBACK(src, .proc/protude), 2.5 MINUTES)

/datum/action/innate/zombie/default/takeover/proc/brain_failure(mob/living/victim)
	if(victim?.stat != DEAD)
		victim.death()

/datum/action/innate/zombie/default/takeover/proc/protude()
	var/mutable_appearance/brainy = mutable_appearance('icons/mob/zombie_base.dmi', "brainy_head")
	var/mob/living/simple_animal/horror/brainy/brainy_owner = owner
	if(ishuman(brainy_owner.victim))
		brainy_owner.victim.add_overlay(brainy)

/datum/action/innate/zombie/default/infest
	name = "Release Spores"
	desc = "Inject spores into the hosts body, slowly converting them into a mindless zombie."
	button_icon_state = "infest"
	ability_type = ZOMBIE_INSTANT
	cost = 20

/datum/action/innate/zombie/default/infest/Activate()
	. = ..()
	var/mob/living/simple_animal/horror/brainy/brainy_owner = owner
	try_to_zombie_infect(brainy_owner.victim, /obj/item/organ/zombie_infection/gamemode)
	to_chat(brainy_owner.victim, span_danger("You feel a sharp pain in the back of your skull."))

/datum/action/innate/zombie/morph
	name = "Shapeshift Mass"
	desc = "Adapt whatever weapon your host's holding into their cells, making them replicatable at will."
	button_icon_state = "morph"
	ability_type = ZOMBIE_TOGGLEABLE
	cooldown = 10 SECONDS
	var/obj/item/gun/brainy/linked_flesh_gun = null

/datum/action/innate/zombie/morph/Activate()
	var/mob/living/simple_animal/horror/brainy/brainy_owner = isbrainy(owner) ? owner : owner.has_horror_inside()
	if(!ishuman(brainy_owner.victim))
		return
	var/mob/living/carbon/human/H = isbrainy(owner) ? brainy_owner.victim : owner
	var/list/available_guns = list(/obj/item/gun/ballistic/shotgun/automatic/combat, /obj/item/gun/energy/laser) //add here
	var/list/radial_menu = list()
	var/obj/item/weapon = H.get_active_held_item() || H.get_inactive_held_item()
	var/obj/item/selected_replicant
	for(var/I in available_guns)
		var/obj/item/item_options = available_guns[I]
		radial_menu[I] = image(initial(item_options.icon), src, initial(item_options.icon_state))
	selected_replicant = show_radial_menu(owner, owner, radial_menu, tooltips = TRUE)
	if(weapon && !H.dropItemToGround(weapon))
		to_chat(owner, span_warning("[weapon] is stuck to your [brainy_owner.controlling ? "" : "hosts"] hand!"))
		return
	linked_flesh_gun = new /obj/item/gun/brainy(get_turf(owner))
	linked_flesh_gun.mimic(selected_replicant)
	H.put_in_hands(linked_flesh_gun)
	playsound(get_turf(owner), 'sound/effects/blobattack.ogg', 30, TRUE)
	. = ..()

/datum/action/innate/zombie/morph/Deactivate()
	QDEL_NULL(linked_flesh_gun)
	playsound(get_turf(owner), 'sound/effects/blobattack.ogg', 30, TRUE)
	. = ..()
