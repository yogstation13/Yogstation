/datum/mind
	var/super_credits = -1

/datum/mind/proc/initialize_credits()
	if(super_credits == -1)
		super_credits = 10
		if(is_donator(current))
			super_credits += 10
		if(is_donator(current) && (!is_admin(current) && !is_deadmin(current) && !is_mentor(current))) //actual donators get 20 more
			super_credits += 20

/mob/sync_mind()
	. = ..()
	mind?.initialize_credits()
