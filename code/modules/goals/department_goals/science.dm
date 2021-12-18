/datum/department_goal/sci
	account = ACCOUNT_SCI


/datum/department_goal/sci/borgs
	name = "4 borgs"
	desc = "Have 4 borgs alive and active on the station"
	reward = "50000"

/datum/department_goal/sci/borgs/check_complete()
	var/borgs = 0
	for(var/mob/mob in GLOB.player_list)
		if(istype(mob, /mob/living/silicon/robot) && is_station_level(mob.z) && mob.client)
			borgs++
	return borgs >= 4
