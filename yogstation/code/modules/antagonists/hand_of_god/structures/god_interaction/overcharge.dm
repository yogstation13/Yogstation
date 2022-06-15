/datum/hog_god_interaction/structure/overcharge
	name = "Overcharge"
	description = "Grants a builidng a temporary weapon, that will shoot all the enemies of your cult. Prismatic lance's just get increased attack speed."
	cost = 115
	cooldown = 20 SECONDS

#define OVERCHARGE_DURATION 15 SECONDS

/datum/hog_god_interaction/structure/overcharge/on_use(var/mob/camera/hog_god/user)
	if(owner.weapon.overcharged) ///Only prismatic lance weapon can be overcharged
		to_chat(user, span_warning("This building is alredy overcharged!"))
		return
	if(owner.weapon && istype(owner.weapon, /obj/item/hog_item/prismatic_lance/guardian))
		owner.weapon.overcharged = TRUE
		owner.weapon.coldown = 1 SECONDS //Enjoy 15 DPS
		addtimer(CALLBACK(src, .proc/discharge), OVERCHARGE_DURATION)
	if(!owner.weapon)
		owner.weapon = new /obj/item/hog_item/prismatic_lance(src)
		owner.weapon.cult = owner.cult 
		addtimer(CALLBACK(src, .proc/discharge), OVERCHARGE_DURATION)

	. = ..()

	
/datum/hog_god_interaction/structure/overcharge/proc/discharge()
	if(owner.weapon && istype(owner.weapon, /obj/item/hog_item/prismatic_lance/guardian))
		owner.weapon.overcharged = FALSE
		owner.weapon.coldown = initial(owner.weapon.coldown)
		return
	else if(owner.weapon)
		qdel(owner.weapon)
		return
	return	
	
#undef OVERCHARGE_DURATION
