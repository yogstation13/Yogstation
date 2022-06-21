/obj/item/hog_item/upgradeable
    var/starting_force = 0   ///RTS moment
    var/upgrades = 0


/obj/item/hog_item/upgradeable/sword
	name = "hoggers"
	desc = "A long, sinistery looking sword."
	resistance_flags = FIRE_PROOF
	icon_state = "sword"
	original_icon = "sword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_BULKY
	force = 21
	throwforce = 10
	wound_bonus = -80
	bare_wound_bonus = 30
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "rended")
    starting_force


/obj/item/hog_item/upgradeable/sword/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 40, 100)


/obj/item/hog_item/shield
	name = "shield"
	icon = 'icons/obj/shields.dmi'
	max_integrity = 30  ///Not very strong, but can be upgraded to become more robust
	block_chance = 30
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 0, BOMB = 30, BIO = 0, RAD = 0, FIRE = 80, ACID = 70)
	var/transparent = FALSE	// makes beam projectiles pass through the shield

/obj/item/hog_item/shield/proc/on_shield_block(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	return TRUE

/obj/item/hog_item/shield/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == THROWN_PROJECTILE_ATTACK)
		final_block_chance += 30
	if(attack_type == LEAP_ATTACK)
		final_block_chance = 100
	return ..()