/datum/quirk/item_quirk/feeble
	name = "Feeble"
	desc = "All it takes is a strong gust of wind to knock you over, doing anything physical takes much longer and good luck using anything with recoil."
	value = -14
	gain_text = span_danger("You feel really weak.")
	lose_text = span_notice("You feel much less weak.")
	medical_record_text = "Patient is suffering from poor dexterity and general physical strength."
	mob_trait = TRAIT_FEEBLE
	icon = FA_ICON_PERSON_CANE
	mail_goodies = list(/obj/item/cane, /obj/item/cane/white, /obj/item/cane/crutch, /obj/item/cane/crutch/wood)

/datum/quirk/item_quirk/feeble/add_unique(client/client_source)
	give_item_to_holder(/obj/item/cane, list(LOCATION_HANDS = ITEM_SLOT_HANDS, LOCATION_BACKPACK = ITEM_SLOT_BACKPACK))

/datum/movespeed_modifier/feeble_quirk_ground
	variable = TRUE
	movetypes = GROUND

/datum/movespeed_modifier/feeble_quirk_not_ground
	multiplicative_slowdown = 1
	blacklisted_movetypes = GROUND

/datum/actionspeed_modifier/feeble_quirk
	multiplicative_slowdown = 2.2

/datum/quirk/item_quirk/feeble/add()
	quirk_holder.add_movespeed_modifier(/datum/movespeed_modifier/feeble_quirk_not_ground)
	quirk_holder.add_actionspeed_modifier(/datum/actionspeed_modifier/feeble_quirk)
	feeble_quirk_update_slowdown(quirk_holder)

/datum/quirk/item_quirk/feeble/remove()
	quirk_holder.remove_movespeed_modifier(/datum/movespeed_modifier/feeble_quirk_ground)
	quirk_holder.remove_movespeed_modifier(/datum/movespeed_modifier/feeble_quirk_not_ground)
	quirk_holder.remove_actionspeed_modifier(/datum/actionspeed_modifier/feeble_quirk)

/proc/feeble_quirk_update_slowdown(mob/living/target)
	var/slowdown = 2.2 // Same slowdown as the walk intent
	var/list/slowdown_mods = list()
	SEND_SIGNAL(target, COMSIG_LIVING_FEEBLE_MOVESPEED_UPDATE, slowdown_mods)
	for(var/num in slowdown_mods)
		slowdown *= num
	target.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/feeble_quirk_ground, multiplicative_slowdown = slowdown)

/proc/feeble_quirk_wound_chest(mob/living/carbon/target, hugger = null, force = FALSE)
	if(!istype(target))
		return
	var/obj/item/bodypart/chest = target.get_bodypart(BODY_ZONE_CHEST)
	if(!force && !prob((locate(/datum/wound/blunt) in chest.wounds) ? 30 : 15))
		return
	if(hugger)
		to_chat(hugger, span_danger("You feel something break inside [target]!"))
	if(locate(/datum/wound/blunt/bone/critical) in chest.wounds)
		playsound(target, 'sound/effects/wounds/crack2.ogg', 70 + (20 * 3), TRUE)
	else if(locate(/datum/wound/blunt/bone/severe) in chest.wounds)
		chest.force_wound_upwards(/datum/wound/blunt/bone/critical)
	else if(locate(/datum/wound/blunt/bone/rib_break) in chest.wounds)
		chest.force_wound_upwards(/datum/wound/blunt/bone/severe)
	else
		chest.force_wound_upwards(/datum/wound/blunt/bone/rib_break)
	chest.receive_damage(brute = 15)

/proc/feeble_quirk_slow_interact(mob/living/carbon/user, action, atom)
	if(!HAS_TRAIT(user, TRAIT_FEEBLE))
		return FALSE
	user.visible_message(span_notice("[user] struggles to [action] [atom]."), \
			span_notice("You struggle to [action] [atom]."))
	return !do_after(user, 2 SECONDS, target = atom)

/proc/feeble_quirk_recoil(mob/living/user, direction, is_gunshot)
	if(user.body_position == LYING_DOWN || user.buckled)
		if(is_gunshot)
			var/item = user.get_active_held_item()
			user.dropItemToGround(item)
			user.visible_message(span_danger("[item] flies out of [user]'s hand!"), \
				span_danger("The recoil makes [item] fly out of your hand!"))
		return FALSE
	user.Knockdown(4 SECONDS)
	user.visible_message(span_danger("[user] looses [user.p_their()] balance!"), \
		span_danger("You loose your balance!"))
	var/shove_dir = turn(direction, 180)
	if(!is_gunshot && prob(0.01))
		user.safe_throw_at(get_edge_target_turf(user, shove_dir), 8, 3, user, spin=FALSE)
	else
		var/turf/target_shove_turf = get_step(user.loc, shove_dir)
		var/turf/target_old_turf = user.loc
		user.Move(target_shove_turf, shove_dir)
		SEND_SIGNAL(target_shove_turf, COMSIG_CARBON_DISARM_COLLIDE, user, user, get_turf(user) == target_old_turf)
