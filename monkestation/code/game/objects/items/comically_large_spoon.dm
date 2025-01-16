/obj/item/comically_large_spoon
	name = "comically large spoon"
	desc = "For when you're only allowed one spoonful of something."
	icon = 'monkestation/icons/obj/items_and_weapons.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/back.dmi'
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/melee_righthand.dmi'
	inhand_icon_state = "comically_large_spoon"
	base_icon_state = "comically_large_spoon"
	icon_state = "comically_large_spoon"
	hitsound = 'sound/items/trayhit1.ogg'

	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 9)

	force = 2 // It's a bit unwieldy for one hand.
	sharpness = NONE // spoon.
	armour_penetration = -50 // Literally couldn't possibly be a worse weapon for hitting armor.
	throwforce = 1 // It's terribly weighted, what do you expect?
	throw_range = 1
	wound_bonus = 30 // Bit more than a lead pipe.
	demolition_mod = 0.5 // you gotta wield it to have some oomph

	/// The block_chance the spoon has when wielded.
	var/block_chance_wielded = 15
	/// The demolition_mod the spoon has when wielded.
	var/demolition_mod_wielded = 2 // IT'S A BIG METAL SPOON.
/*
	/// Is this spoon currently empowered?
	var/empowered = FALSE
*/

/obj/item/comically_large_spoon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		require_twohands = FALSE, \
		force_wielded = 16, \
		force_unwielded = src::force, \
		wield_callback = CALLBACK(src, PROC_REF(on_wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(on_unwield)), \
	)
	//AddComponent(/datum/component/liquids_interaction, TYPE_PROC_REF(/obj/item/comically_large_spoon, try_scoop_liquids))

/*
/obj/item/comically_large_spoon/examine(mob/user)
	. = ..()
	if(empowered)
		. += span_big(span_warning("It seems to be unusually powerful!"))
	else
		. += span_smallnoticeital("Something special may happen if you scoop oil or blood off the floor with it.")
*/

/obj/item/comically_large_spoon/update_icon_state()
	inhand_icon_state = "[base_icon_state][HAS_TRAIT(src, TRAIT_WIELDED) ? "_wielded" : ""]"
	return ..()

/obj/item/comically_large_spoon/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is taking two spoonfuls with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	ADD_TRAIT(src, TRAIT_NODROP, SPOON_SUICIDE_TRAIT)
	ADD_TRAIT(user, TRAIT_NO_TRANSFORM, SPOON_SUICIDE_TRAIT)
	user.anchored = TRUE
	user.move_resist = INFINITY
	lightningbolt(user)
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, gib), TRUE), 1 SECONDS)
	addtimer(TRAIT_CALLBACK_REMOVE(src, TRAIT_NODROP, SPOON_SUICIDE_TRAIT), 1 SECONDS)
	return MANUAL_SUICIDE

/obj/item/comically_large_spoon/proc/on_wield(atom/source, mob/living/user)
	hitsound = 'monkestation/sound/weapons/bat_hit.ogg'
	block_chance = block_chance_wielded
	demolition_mod = demolition_mod_wielded

/obj/item/comically_large_spoon/proc/on_unwield(atom/source, mob/living/user)
	hitsound = src::hitsound
	block_chance = src::block_chance
	demolition_mod = src::demolition_mod

/* REMOVED UNTIL I CAN ACTUALLY BALANCE THIS
// touhou hijack lol
// also i know this is a spoon and not a spork, i don't care
/obj/item/comically_large_spoon/proc/try_scoop_liquids(obj/item/comically_large_spoon/spoon, turf/target, mob/user, obj/effect/abstract/liquid_turf/liquids)
	SIGNAL_HANDLER
	if(empowered || !user.CanReach(target))
		return FALSE
	if(QDELETED(liquids) || QDELETED(liquids.liquid_group))
		return FALSE
	var/datum/liquid_group/liquid_group = liquids.liquid_group
	if(liquid_group.reagents.has_reagent(/datum/reagent/blood, 20))
		liquid_group.remove_specific(liquids, 20, /datum/reagent/blood)
		empower(blood = TRUE)
		user.visible_message(span_danger("[user] scoops some blood off the ground with \the [src]!"), span_boldnotice("You scoop some blood off the ground with \the [src], and it seems far more powerful!"))
		return TRUE
	else if(liquid_group.reagents.has_reagent(/datum/reagent/fuel/oil, 30))
		liquid_group.remove_specific(liquids, 30, /datum/reagent/fuel/oil)
		empower(blood = FALSE)
		user.visible_message(span_warning("[user] scoops some oil off the ground with \the [src]!"), span_boldnotice("You scoop some oil off the ground with \the [src], and it seems a bit more powerful!"))
		return TRUE
	return FALSE

/obj/item/comically_large_spoon/proc/empower(blood = FALSE)
	if(empowered)
		return
	var/datum/component/two_handed/two_handed = GetComponent(/datum/component/two_handed)
	var/old_force_wielded = two_handed.force_wielded
	var/old_block_chance_wielded = block_chance_wielded
	var/old_armour_penetration = armour_penetration
	var/old_demolition_mod_wielded = demolition_mod_wielded
	two_handed.force_wielded = blood ? 25 : 20
	block_chance_wielded = blood ? 50 : 35
	armour_penetration = blood ? 10 : 0
	demolition_mod_wielded = blood ? 5 : 3
	add_atom_colour(blood ? /datum/reagent/blood::color : /datum/reagent/fuel/oil::color, TEMPORARY_COLOUR_PRIORITY)
	update_inhand_icon()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		force = two_handed.force_wielded
		on_wield()
	empowered = TRUE
	addtimer(CALLBACK(src, PROC_REF(end_empower), old_force_wielded, old_block_chance_wielded, old_armour_penetration, old_demolition_mod_wielded), blood ? 3 MINUTES : 1.5 MINUTES, TIMER_UNIQUE)

/obj/item/comically_large_spoon/proc/end_empower(old_force_wielded, old_block_chance_wielded, old_armour_penetration, old_demolition_mod_wielded)
	if(!empowered)
		return
	var/datum/component/two_handed/two_handed = GetComponent(/datum/component/two_handed)
	two_handed.force_wielded = old_force_wielded
	block_chance_wielded = old_block_chance_wielded
	armour_penetration = old_armour_penetration
	demolition_mod_wielded = old_demolition_mod_wielded
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		force = old_force_wielded
		on_wield()
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	update_inhand_icon()
	empowered = FALSE
*/
