//spears
/obj/item/melee/spear
	icon = 'icons/obj/weapons/spears.dmi'
	icon_state = "spearglass0"
	base_icon_state = "spearglass"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	force = 10
	max_integrity = 100
	weapon_stats = list(SWING_SPEED = 1, ENCUMBRANCE = 0, ENCUMBRANCE_TIME = 0, REACH = 1, DAMAGE_LOW = 2, DAMAGE_HIGH = 5)
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throwforce = 20
	throw_speed = 4
	embedding = list("embedded_impact_pain_multiplier" = 3)
	armour_penetration = 10
	materials = list(/datum/material/iron=1150, /datum/material/glass=2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")
	sharpness = SHARP_EDGED
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 30)
	break_message = "%SRC's cable binding suddenly snaps"
	wound_bonus = -15
	bare_wound_bonus = 15

	///How much extra damage to deal when wielded.
	var/force_wielded = 8
	///Whether the spear can have an explosive attached to it.
	var/can_be_explosive = TRUE

/obj/item/melee/spear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_wielded = force_wielded, \
		icon_wielded = "[base_icon_state]1", \
		wielded_stats = list(SWING_SPEED = 1, ENCUMBRANCE = 0.4, ENCUMBRANCE_TIME = 5, REACH = 2, DAMAGE_LOW = 2, DAMAGE_HIGH = 5), \
	)
	AddComponent(/datum/component/butchering, 100, 70) //decent in a pinch, but pretty bad.

/obj/item/melee/spear/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to sword-swallow \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/melee/spear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/jousting)

/obj/item/melee/spear/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]0"

/obj/item/melee/spear/deconstruct() //we drop our rod and maybe the glass shard used
	new /obj/item/stack/rods(get_turf(src))
	if(!prob(20)) //20% chance to save our spearhead
		break_message += " and its head smashes into pieces!"
		return ..()
	var/spearhead = base_icon_state == "spear_plasma" ? /obj/item/shard/plasma : /obj/item/shard //be honest we have this stored  //we do NOT have this stored
	new spearhead(get_turf(src))
	break_message += "!"
	..()

/obj/item/melee/spear/CheckParts(list/parts_list)
	var/obj/item/shard/tip = locate() in parts_list
	if (istype(tip, /obj/item/shard/plasma))
		force_wielded += 1
		force += 1
		throwforce += 1
		righthand_file = 'yogstation/icons/mob/inhands/weapons/polearms_righthand.dmi' //yogs
		mob_overlay_icon = 'yogstation/icons/mob/clothing/back.dmi' //yogs
		base_icon_state = "spearplasma"
	update_appearance(UPDATE_ICON)
	qdel(tip)
	var/obj/item/grenade/G = locate() in parts_list
	if(G && can_be_explosive)
		var/obj/item/melee/spear/explosive/lance = new /obj/item/melee/spear/explosive(src.loc, G)
		lance.force_wielded = force_wielded
		lance.force = force
		lance.throwforce = throwforce
		lance.base_icon_state = base_icon_state
		parts_list -= G
		qdel(src)
	..()


/obj/item/melee/spear/explosive
	name = "explosive lance"
	base_icon_state = "spearbomb"

	///The grenade attached to the explosive spear.
	var/obj/item/grenade/explosive
	///The war cry, editable by the player, that gets yelled when attacking.
	var/war_cry = "AAAAARGH!!!"

/obj/item/melee/spear/explosive/Initialize(mapload, obj/item/grenade/default_grenade)
	. = ..()
	if(!default_grenade)
		default_grenade = new /obj/item/grenade/iedcasing() //For admin-spawned explosive lances
	default_grenade.forceMove(src)
	explosive = default_grenade
	desc = "A makeshift spear with [default_grenade] attached to it"
	update_appearance(UPDATE_ICON)

/obj/item/melee/spear/explosive/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to sword-swallow \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	user.say("[war_cry]", forced = "spear warcry")
	explosive.forceMove(user)
	explosive.prime()
	user.gib()
	qdel(src)
	return BRUTELOSS

/obj/item/melee/spear/explosive/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to set your war cry.")

/obj/item/melee/spear/explosive/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	. = ..()
	if(istype(user) && loc == user)
		var/input = stripped_input(user,"What do you want your war cry to be? You will shout it when you hit someone in melee.", ,"", 50)
		if(input)
			war_cry = input

/obj/item/melee/spear/explosive/afterattack(atom/movable/AM, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		user.say("[war_cry]", forced = "spear warcry")
		explosive.forceMove(AM)
		explosive.prime()
		qdel(src)

/**
 * Grey Tide
 */
/obj/item/melee/spear/grey_tide
	icon_state = "spearglass0"
	name = "\improper Grey Tide"
	desc = "Recovered from the aftermath of a revolt aboard Defense Outpost Theta Aegis, in which a seemingly endless tide of Assistants caused heavy casualities among Nanotrasen military forces."
	force = 15
	weapon_stats = list(SWING_SPEED = 1, ENCUMBRANCE = 0, ENCUMBRANCE_TIME = 0, REACH = 1, DAMAGE_LOW = 0, DAMAGE_HIGH = 0)
	throwforce = 20
	throw_speed = 4
	attack_verb = list("gored")

	force_wielded = 10

/obj/item/melee/spear/grey_tide/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_wielded = force_wielded, \
		icon_wielded = "[base_icon_state]1", \
		wielded_stats = list(SWING_SPEED = 1, ENCUMBRANCE = 0, ENCUMBRANCE_TIME = 0, REACH = 2, DAMAGE_LOW = 0, DAMAGE_HIGH = 0), \
	)

/obj/item/melee/spear/grey_tide/afterattack(atom/movable/AM, mob/living/user, proximity)
	. = ..()
	if(!proximity)
		return
	user.faction |= "greytide([REF(user)])"
	if(isliving(AM))
		var/mob/living/L = AM
		if(istype (L, /mob/living/simple_animal/hostile/illusion))
			return
		if(!L.stat && prob(50))
			var/mob/living/simple_animal/hostile/illusion/M = new(user.loc)
			M.faction = user.faction.Copy()
			M.Copy_Parent(user, 100, user.health/2.5, 12, 30)
			M.GiveTarget(L)

/*
 * Bone Spear
 */
/obj/item/melee/spear/bonespear //Blatant imitation of spear, but made out of bone. Not valid for explosive modification.
	icon = 'icons/obj/weapons/spears.dmi'
	icon_state = "bone_spear0"
	base_icon_state = "bone_spear"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "bone spear"
	desc = "A haphazardly-constructed yet still deadly weapon. The pinnacle of modern technology."
	force = 11
	max_integrity = 100
	weapon_stats = list(SWING_SPEED = 1, ENCUMBRANCE = 0, ENCUMBRANCE_TIME = 0, REACH = 1, DAMAGE_LOW = 0, DAMAGE_HIGH = 0)
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throwforce = 22
	throw_speed = 4
	embedding = list("embedded_impact_pain_multiplier" = 3)
	armour_penetration = 15 //Enhanced armor piercing
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")
	sharpness = SHARP_EDGED

	force_wielded = 9 //I have no idea how to balance
	can_be_explosive = FALSE

/obj/item/melee/spear/bonespear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_wielded = force_wielded, \
		icon_wielded = "[base_icon_state]1", \
		wielded_stats = list(SWING_SPEED = 1, ENCUMBRANCE = 0.4, ENCUMBRANCE_TIME = 5, REACH = 2, DAMAGE_LOW = 0, DAMAGE_HIGH = 0), \
	)

/obj/item/melee/spear/bonespear/chitinspear //like a mix of a bone spear and bone axe, but more like a bone spear. And better.
	icon = 'icons/obj/weapons/spears.dmi'
	icon_state = "chitin_spear0"
	base_icon_state = "chitin_spear"
	name = "chitin spear"
	desc = "A well constructed spear with a sharpened edge akin to a naginata, making it equally great for slicing and throwing."
	force = 13
	throwforce = 25
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored", "sliced", "ripped", "cut")

	force_wielded = 10

/obj/item/melee/spear/bamboospear
	icon = 'icons/obj/weapons/spears.dmi'
	icon_state = "bamboo_spear0"
	base_icon_state = "bamboo_spear"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "bamboo spear"
	desc = "A haphazardly-constructed bamboo stick with a sharpened tip, ready to poke holes into unsuspecting people."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throwforce = 22
	throw_speed = 4
	embedding = list("embedded_impact_pain_multiplier" = 2)
	armour_penetration = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")
	sharpness = SHARP_EDGED

	force_wielded = 8
	can_be_explosive = FALSE
