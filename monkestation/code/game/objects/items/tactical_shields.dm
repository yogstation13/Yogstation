/// Tutel shield, designed to work with the Bobr
/// Comes with a built-in 8 round ammobox to allow for easy reloading
/// I based it off of ammo_box instead of shield because I believe ammo_box is more complicated

/obj/item/ammo_box/tacshield/tutel/
	name = "Tutel tactical buckler"
	desc = "A lightweight titanium-alloy shield. It has an integrated shotgun speedloader, allowing you to reload without putting down the shield."
	icon = 'icons/obj/weapons/shields.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	icon_state = "tutel"
	inhand_icon_state = "tutel"
	worn_icon_state = "ammobox"
	ammo_type = /obj/item/ammo_casing/shotgun
	max_ammo = 8
	caliber = CALIBER_SHOTGUN
	multitype = TRUE
	block_chance = 35
	max_integrity = 55 //breaks on the second slug block, survives the first
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT
	force = 15
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("shoves", "bashes")
	attack_verb_simple = list("shove", "bash")
	armor_type = /datum/armor/item_shield
	block_sound = 'sound/weapons/block_shield.ogg'
	start_empty = TRUE
	spriteshift = FALSE
	var/tutel_break_leftover = /obj/item/broken_shield

/obj/item/ammo_box/tacshield/tutel/examine(mob/user)
	. = ..()
	var/healthpercent = round((atom_integrity/max_integrity) * 100, 1)
	switch(healthpercent)
		if(50 to 99)
			. += span_info("It looks slightly damaged.")
		if(25 to 50)
			. += span_info("It appears heavily damaged.")
		if(0 to 25)
			. += span_warning("It's falling apart!")

/obj/item/ammo_box/tacshield/tutel/proc/shatter(mob/living/carbon/human/owner)
	playsound(owner, 'sound/effects/bang.ogg', 50)
	explosion(owner, 0, 0, 0, 0) //Shield breaking should be extremely obvious, and a little silly
	new tutel_break_leftover(get_turf(src))


/obj/item/ammo_box/tacshield/tutel/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	. = ..()
	if(.)
		if (atom_integrity <= damage)
			var/turf/owner_turf = get_turf(owner)
			owner_turf.visible_message(span_warning("[hitby] destroys [src]!"))
			shatter(owner)
			var/turf_mag = get_turf(src)
			for(var/obj/item/ammo in stored_ammo)
				ammo.forceMove(turf_mag)
				stored_ammo -= ammo
			qdel(src)
			return TRUE
		take_damage(damage)
		return TRUE

/obj/item/ammo_box/tacshield/tutel/attackby(obj/item/attackby_item, mob/user, params)
	if(istype(attackby_item, /obj/item/stack/sheet/mineral/titanium))
		if (atom_integrity >= max_integrity)
			to_chat(user, span_warning("[src] is already in perfect condition."))
			return
		if(!do_after(user, 1 SECONDS, src, timed_action_flags = IGNORE_USER_LOC_CHANGE, interaction_key = "doafter_shieldrepair"))
			to_chat(user, span_warning("You were interrupted."))
			return
		var/obj/item/stack/sheet/mineral/titanium/titanium_sheet = attackby_item
		titanium_sheet.use(1)
		atom_integrity = max_integrity
		to_chat(user, span_notice("You repair [src] with [titanium_sheet]."))
		return
	return ..()

/obj/item/broken_shield
	name = "broken Tutel"
	desc = "A broken tactical shield, it looks as though you could repair it with some titanium.."
	icon = 'icons/obj/weapons/shields.dmi'
	icon_state = "brokentutel"
	flags_1 = CONDUCT_1
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT + SMALL_MATERIAL_AMOUNT * 3)
	attack_verb_continuous = list("hits", "bludgeons", "whacks", "bonks")
	attack_verb_simple = list("hit", "bludgeon", "whack", "bonk")

/obj/item/broken_shield/Initialize(mapload)
	. = ..()

	var/static/list/hovering_item_typechecks = list(
		/obj/item/stack/sheet/mineral/titanium = list(
			SCREENTIP_CONTEXT_LMB = "Repair shield",
		),

	)

	AddElement(/datum/element/contextual_screentip_item_typechecks, hovering_item_typechecks)

/obj/item/broken_shield/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/stack/sheet/mineral/titanium))
		var/datum/crafting_recipe/recipe_to_use = /datum/crafting_recipe/tutel
		user.balloon_alert(user, "repairing shield...")
		if(do_after(user, initial(recipe_to_use.time), src)) // we do initial work here to get the correct timer
			var/obj/item/ammo_box/tacshield/tutel/crafted_tutel = new /obj/item/ammo_box/tacshield/tutel/()

			remove_item_from_storage(user)
			if (!user.transferItemToLoc(attacking_item, crafted_tutel))
				return
			crafted_tutel.CheckParts(list(attacking_item))
			qdel(src)

			user.put_in_hands(crafted_tutel)
			user.balloon_alert(user, "repaired shield")
		return
	return ..()

/datum/crafting_recipe/tutel
	name = "Tutel Repair"
	result = /obj/item/ammo_box/tacshield/tutel/
	reqs = list(
		/obj/item/broken_shield = 1,
		/obj/item/stack/sheet/mineral/titanium = 1,
	)
	time = 3 SECONDS
	category = CAT_WEAPON_MELEE

