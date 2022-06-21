/obj/item/hog_item/upgradeable
    var/starting_force = 0   ///RTS moment
    var/upgrades = 0


/obj/item/hog_item/upgradeable/sword
	name = "divine blade"
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
	starting_force = 21


/obj/item/hog_item/upgradeable/sword/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 40, 100)


/obj/item/hog_item/upgradeable/shield
	name = "shield"
	icon = 'icons/obj/shields.dmi'
	max_integrity = 30  ///Not very strong, but can be upgraded to become more robust
	block_chance = 30
	armor = list(MELEE = 30, BULLET = 40, LASER = 20, ENERGY = 20, BOMB = 10, BIO = 0, RAD = 0, FIRE = 100, ACID = 70)
	starting_force = 10
	force = 10

/obj/item/hog_item/upgradeable/proc/on_shield_block(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	return TRUE    ///Sorry for shield code here

/obj/item/hog_item/upgradeable/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(owner)
		var/datum/antagonist/hog/cultist = IS_HOG_CULTIST(owner)
		if(!cultist || cultist.cult != src.cult)
			to_chat(owner, span_userdanger("The [src] starts to twirl in your hands, and then suddenly hits you!"))
			attack(owner, owner)
			return
	if(attack_type == THROWN_PROJECTILE_ATTACK)
		final_block_chance += 30
	if(attack_type == LEAP_ATTACK)
		final_block_chance = 100
	return ..()

/obj/item/restraints/handcuffs/energy/hogcult
	name = "celestial bound"
	desc = "Divine energy field that binds the wrists with celestial magic."
	trashtype = /obj/item/restraints/handcuffs/energy/used
	item_flags = DROPDEL

/obj/item/restraints/handcuffs/energy/hogcult/used/dropped(mob/user)
	user.visible_message(span_danger("[user]'s shackles shatter in a discharge of magic!"), \
							span_userdanger("Your [src] shatters in a discharge of magic!"))
	. = ..()
