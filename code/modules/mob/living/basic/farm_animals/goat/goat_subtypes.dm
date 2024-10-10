/mob/living/basic/goat/pete // Pete!
	name = "Pete"
	gender = MALE

/mob/living/basic/goat/pete/examine()
	. = ..()
	var/area/goat_area = get_area(src)
	if((bodytemperature < T20C) || istype(goat_area, /area/station/service/kitchen/coldroom))
		. += span_notice("[p_They()] [p_do()]n't seem to be too bothered about the cold.") // special for pete

/mob/living/basic/goat/pete/add_udder()
	return //no thank you

/mob/living/basic/goat/pete/icebox
	name = "Snowy Pete"
	desc = parent_type::desc + " This one seems a bit more hardy to the cold."
	bodytemp_cold_damage_limit = ICEBOX_MIN_TEMPERATURE - 5 KELVIN
	habitable_atmos = list(
		"min_oxy" = 1,
		"max_oxy"= 0,
		"min_plas" = 0,
		"max_plas" = 1,
		"min_co2" = 0,
		"max_co2" = 5,
		"min_n2" = 0,
		"max_n2" = 0,
	)
