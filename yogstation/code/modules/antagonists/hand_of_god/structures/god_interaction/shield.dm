/datum/hog_god_interaction/structure/shield
	name = "Shield"
	description = "Grants a builidng a temporary shield, that will protect it from EMP's and make it slowly regenerate integrity."
	cost = 90
	cooldown = 20 SECONDS
    var/processing = FALSE
	var/when_stopped

#define SHIELDING_DURATION 15 SECONDS
#define SHIELDING_SHIELD_HP 100
#define SHIELDING_REPAIR_AMOUNT 2

/datum/hog_god_interaction/structure/shield/on_use(var/mob/camera/hog_god/user)
	if(owner.shield_integrity >= SHIELDING_SHIELD_HP)
        to_chat(user,span_danger("The building is alredy shielded!")) 
        return
	owner.shield_integrity = SHIELDING_SHIELD_HP
	owner.update_hog_icons()
	when_stopped = world.time + SHIELDING_DURATION
	if(!processing)
		addtimer(CALLBACK(src, .proc/repair), 1 SECONDS)
		processing = TRUE
        to_chat(user,span_danger("You cast a shield on the [owner]!")) 
	else
        to_chat(user,span_danger("You restore the shield integrity to the [owner]!")) 
	. = ..()

	
/datum/hog_god_interaction/structure/shield/proc/repair()
	if(when_stopped <= world.time)
		owner.shield_integrity = 0
		owner.update_hog_icons()
		processing = FALSE
		return
	owner.take_damage(-SHIELDING_REPAIR_AMOUNT, BURN, MELEE, FALSE , get_dir(src, src), 100)
	addtimer(CALLBACK(src, .proc/repair), 1 SECONDS)
	
#undef SHIELDING_DURATION
#undef SHIELDING_SHIELD_HP
#undef SHIELDING_REPAIR_AMOUNT