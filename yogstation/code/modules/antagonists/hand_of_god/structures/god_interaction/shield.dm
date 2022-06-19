/datum/hog_god_interaction/structure/shield
	name = "Shield"
	description = "Grants a builidng a temporary shield, that will protect it from EMP's and make it slowly regenerate integrity."
	cost = 75
	cooldown = 20 SECONDS
    var/processing = FALSE

#define SHIELDING_DURATION 15 SECONDS
#define SHIELDING_SHIELD_HP 100

/datum/hog_god_interaction/structure/shield/on_use(var/mob/camera/hog_god/user)
	if(owner.shield_integrity >= SHIELDING_SHIELD_HP)
        to_chat(user,span_danger("The building is alredy overcharged!")) 
        return
	owner.shield_integrity = SHIELDING_SHIELD_HP
	owner.update_hog_icons()
    

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
	
#undef SHIELDING_DURATION
#undef SHIELDING_SHIELD_HP