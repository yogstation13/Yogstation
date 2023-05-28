//This is the innate action for "binding" and calling weapons to yourself. These weapons can appear and disappear at will.
//You can invoke a cooldown period by calling "weapon_reset(cooldown in deciseconds)." By default, this only applies to dismissing weapons.
/datum/action/innate/call_weapon
	name = "Call Weapon"
	desc = "This definitely shouldn't exist."
	button_icon = 'icons/mob/actions/actions_clockcult.dmi'
	button_icon_state = "ratvarian_spear"
	background_icon_state = "bg_clock"
	check_flags = AB_CHECK_HANDS_BLOCKED| AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS
	buttontooltipstyle = "clockcult"
	var/cooldown = 0
	var/obj/item/clockwork/weapon/weapon_type //The type of weapon to create
	var/obj/item/clockwork/weapon/weapon

/datum/action/innate/call_weapon/IsAvailable(feedback = FALSE)
	if(!is_servant_of_ratvar(owner))
		qdel(src)
		return
	if(cooldown > world.time)
		return
	return ..()

/datum/action/innate/call_weapon/Activate()
	if(!owner.get_empty_held_indexes())
		to_chat(usr, span_warning("You need an empty hand to call forth your [initial(weapon_type.name)]!"))
		return
	if(weapon)
		if(weapon.loc == owner)
			owner.visible_message(span_danger("[owner]'s [weapon.name] flickers and disappears!"))
			to_chat(owner, span_brass("You dismiss [weapon]."))
			QDEL_NULL(weapon)
			weapon_reset(RATVARIAN_SPEAR_COOLDOWN * 0.5)
			return
		else
			weapon.visible_message(span_warning("[weapon] suddenly flickers and disappears!"))
			owner.visible_message(span_danger("A [weapon.name] suddenly flickers into [owner]'s hands!"), span_brass("You recall [weapon] to you."))
	else
		weapon = new weapon_type (get_turf(usr), src)
		owner.visible_message(span_warning("A [weapon.name] materializes in [owner]'s hands!"), span_brass("You call forth your [weapon.name]!"))
	weapon.forceMove(get_turf(owner))
	owner.put_in_hands(weapon)
	owner.update_mob_action_buttons()
	return TRUE

/datum/action/innate/call_weapon/proc/weapon_reset(cooldown_time)
	cooldown = world.time + cooldown_time
	addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob, update_mob_action_buttons)), cooldown_time)
	owner.update_mob_action_buttons()
	QDEL_NULL(weapon)
