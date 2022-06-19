/datum/hog_god_interaction/structure/shield
	name = "Shield"
	description = "Grants a builidng a temporary shield, that will protect it from EMP's and make it slowly regenerate integrity."
	cost = 75
	cooldown = 20 SECONDS
    var/processing = FALSE

/datum/hog_god_interaction/structure/shield/on_use(var/mob/camera/hog_god/user)
	if(owner.shield_integrity == 100)
        to_chat(user,span_danger("The building is alredy overcharged!")) 
        return
    

	. = ..()

	
/datum/hog_god_interaction/structure/shield/proc/discharge()
	if(owner.weapon && istype(owner.weapon, /obj/item/hog_item/prismatic_lance/guardian))
		owner.weapon.overcharged = FALSE
		owner.weapon.coldown = initial(owner.weapon.coldown)
		return
	else if(owner.weapon)
		qdel(owner.weapon)
		return
	return	
	
#undef OVERCHARGE_DURATION