/area/metro
	name = "base metro"
	noteleport = TRUE			//Are you forbidden from teleporting to the area? (centcom, mobs, wizard, hand teleporter)
	hidden = TRUE 			//Hides area from player Teleport function.
	safe = TRUE
	requires_power = FALSE
	ambientsounds = RUINS
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/metro/radfree
	name = "rad free metro"

/area/metro/passive_radiation
	name = "passive radiation area"
	//Damage taken with filterless mask
	var/max_mask_oxy_loss = 5
	var/min_mask_oxy_loss = 3
	var/min_mask_tox_loss = 2
	var/max_mask_tox_loss = 3
	//Damage taken without mask
	var/min_oxy_loss = 3
	var/max_oxy_loss = 5
	var/min_tox_loss = 3
	var/max_tox_loss = 4
	//Damage taken with working mask
	var/extreme_max_mask_oxy_loss = 0
	var/extreme_min_mask_oxy_loss = 0
	var/extreme_min_mask_tox_loss = 0
	var/extreme_max_mask_tox_loss = 0

/area/metro/passive_radiation/lowrad
	name = "low rad metro"

/area/metro/passive_radiation/lowrad/Initialize()
	SSweather.run_weather(/datum/weather/passive_rads, 2)
	..()



/area/metro/passive_radiation/highrad
	name = "high rad metro"
	//with mask
	max_mask_oxy_loss = 7
	min_mask_oxy_loss = 5
	min_mask_tox_loss = 4
	max_mask_tox_loss = 5
	//Without mask
	min_oxy_loss = 5
	max_oxy_loss = 7
	min_tox_loss = 5
	max_tox_loss = 6
	//With mask, in extreme area
	extreme_max_mask_oxy_loss = 3
	extreme_min_mask_oxy_loss = 2
	extreme_min_mask_tox_loss = 2
	extreme_max_mask_tox_loss = 3

/area/metro/passive_radiation/highrad/Initialize()
	SSweather.run_weather(/datum/weather/passive_rads/extreme, 2)
	..()

/area/metro/passive_radiation/highrad/Entered(mob/living/user)
	to_chat(user, "<span class='boldwarning'>You have entered an area with unusually high radiation levels! Even your mask will not fully protect you here. Filters take 2 times as much damage.</span>")
	..()

/area/metro/passive_radiation/lowrad/Entered(mob/living/user)
	to_chat(user, "<span class='boldwarning'>You have entered an area with radiation! If you do not put on a gas mask with a filter you will take damage!</span>")
	..()

/area/metro/radfree/Entered(mob/living/user)
	to_chat(user, "<span class='warning'>You have entered an area without radiation. You are not required to use a mask, and your mask will not deplete its filter.</span>")
	..()