//UNIMPLEMENTED
//spits weak knockdown projectiles
/datum/species/zombie/infectious/spitter
	name = "Spitter Zombie"
	id = SPECIES_ZOMBIE_INFECTIOUS_SPITTER
	bodypart_overlay_icon_states = list(BODY_ZONE_CHEST = "spitter-chest", BODY_ZONE_HEAD = "spitter_head", BODY_ZONE_R_ARM = "spitter-right-hand", BODY_ZONE_L_ARM = "spitter-left-hand")
	granted_action_types = list(
		/datum/action/cooldown/zombie/spit,
	)


//Just stole aliens stuff, needs some rewording
/datum/action/cooldown/zombie/spit
	name = "Spit"
	desc = "Spit at someone, causing them to fall down and get burnt."
	background_icon_state = "bg_zombie"
	button_icon_state = "spit_off"
	cooldown_time = 8 SECONDS
	click_to_activate = TRUE

/datum/action/cooldown/zombie/spit/IsAvailable(feedback = FALSE)
	if(owner.is_muzzled())
		return FALSE

	if(!isturf(owner.loc))
		return FALSE
	return ..()

/datum/action/cooldown/zombie/spit/set_click_ability(mob/on_who)
	. = ..()
	if(!.)
		return

	to_chat(on_who, span_notice("You prepare to spit. <B>Left-click to fire at a target!</B>"))

	button_icon_state = "spit_on"
	build_all_button_icons()
	on_who.update_icons()

/datum/action/cooldown/zombie/spit/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(!.)
		return

	if(refund_cooldown)
		to_chat(on_who, span_notice("You empty your mouth."))

	button_icon_state = "spit_off"
	build_all_button_icons()
	on_who.update_icons()

// We do this in InterceptClickOn() instead of Activate()
// because we use the click parameters for aiming the projectile
// (or something like that)
/datum/action/cooldown/zombie/spit/InterceptClickOn(mob/living/user, params, atom/target)
	. = ..()
	if(!.)
		unset_click_ability(user, refund_cooldown = FALSE)
		return FALSE

	var/modifiers = params2list(params)
	user.visible_message(
		span_danger("[user] spits!"),
		span_alert("You spit."),
	)
	var/obj/projectile/neurotoxin/zombie/spit = new(user.loc)
	spit.preparePixelProjectile(target, user, modifiers)
	spit.firer = user
	spit.fire()
	user.newtonian_move(get_dir(target, user))
	return TRUE

// Has to return TRUE, otherwise is skipped.
/datum/action/cooldown/zombie/spit/Activate(atom/target)
	return TRUE

/obj/projectile/neurotoxin/zombie
	name = "spit"
	icon_state = "glob_projectile"
	damage = 20
	damage_type = BURN
