/obj/item/clothing/gloves/infinity
	name = "Infinity Gauntlet"
	desc = "A gauntlet made of near-indestructable metal, made to hold the stones of absolute power, bringing all the stones together will grant the ultimate spell..."
	icon = 'icons/obj/gauntlet.dmi'
	icon_state = "gauntlet"
	item_state = "gauntlet"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	attack_verb = list("ponched", "punched", "pwned")
	force = 50
	throwforce = 10
	throw_range = 7
	strip_delay = 15 SECONDS
	cold_protection = HANDS
	heat_protection = HANDS
	w_class = WEIGHT_CLASS_NORMAL
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100, ELECTRIC = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/list/abilities = list()

/obj/item/clothing/gloves/infinity/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_HANDS && LAZYLEN(abilities))
		for(var/datum/action/ability as anything in abilities)
			if(istype(ability))
				ability.Grant(user)

/obj/item/clothing/gloves/infinity/dropped(mob/user)
	. = ..()
	for(var/datum/action/ability as anything in abilities)
		if(istype(ability))
			ability.Remove(user)
	return ..()

/obj/item/clothing/gloves/infinity/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/infinity_stone))
		var/obj/item/infinity_stone/stone = A
		stone.install(src, user)
	else
		..()

/obj/item/clothing/gloves/infinity/proc/update_abilities(mob/user)
	for(var/datum/action/ability as anything in abilities)
		if(istype(ability))
			ability.Remove(user)
	if(H.get_item_by_slot(ITEM_SLOT_GLOVES) == src)
		for(var/datum/action/ability as anything in abilities)
			if(istype(ability))
				ability.Grant(user)
