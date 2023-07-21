/// Middleware for skillcapes

/// Generate list of valid skillcapes
/datum/preference_middleware/skillcape/get_ui_static_data()
	. = list()
	.["earned_skillcapes"] = list("None")

	var/max_earned = TRUE
	for(var/id in GLOB.skillcapes)
		var/datum/skillcape/cape_check = GLOB.skillcapes[id]
		if(!cape_check.job)
			continue

		if(preferences.exp[cape_check.job] < cape_check.minutes)
			max_earned = FALSE
			continue
		
		.["earned_skillcapes"] += id
	
	if(max_earned)
		.["earned_skillcapes"] += "max"

