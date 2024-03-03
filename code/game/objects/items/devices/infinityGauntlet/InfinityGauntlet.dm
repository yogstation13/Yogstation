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


/obj/item/infinity_stone
	desc = "you shouldn't have this"
	
/obj/item/infinity_stone/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/clothing/gloves/infinity))
		install(A, user)
	else
		..()

/obj/item/infinity_stone/proc/install(obj/item/item, mob/user)
	. = TRUE
	if(istype(item, /obj/item/infinity_stone/mind))
		var/datum/action/cooldown/spell/aoe/repulse/wizard/mind_stone/repulse = new(user)
		repulse.Grant(user)
		
