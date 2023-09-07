/obj/item/pitchfork
	icon = 'icons/obj/weapons/spears.dmi'
	icon_state = "pitchfork0"
	base_icon_state = "pitchfork"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "pitchfork"
	desc = "A simple tool used for moving hay."
	force = 7
	throwforce = 15
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("attacked", "impaled", "pierced")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_POINTY
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 30)
	resistance_flags = FIRE_PROOF

	///How much damage the pitchfork will do while wielded.
	var/force_wielded = 8

/obj/item/pitchfork/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_unwielded = force, \
		force_wielded = force_wielded, \
		icon_wielded = "[base_icon_state]1", \
	)

/obj/item/pitchfork/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]0"

/obj/item/pitchfork/trident
	icon_state = "trident"
	name = "trident"
	desc = "A trident recovered from the ruins of atlantis"
	slot_flags = ITEM_SLOT_BELT
	force = 14
	throwforce = 23

	force_wielded = 6

/obj/item/pitchfork/demonic
	name = "demonic pitchfork"
	desc = "A red pitchfork, it looks like the work of the devil."
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_power = 6
	light_color = LIGHT_COLOR_RED
	block_chance = 50

	force = 2
	force_wielded = 6

/obj/item/pitchfork/IsReflect(def_zone)
	return HAS_TRAIT(src, TRAIT_WIELDED)

/obj/item/pitchfork/afterattack(mob/living/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!HAS_TRAIT(src, TRAIT_WIELDED) || (user == target) || !isliving(target))
		return
	target.fire_stacks = 4
	target.ignite_mob()

/obj/item/pitchfork/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] impales [user.p_them()]self in [user.p_their()] abdomen with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (BRUTELOSS)
