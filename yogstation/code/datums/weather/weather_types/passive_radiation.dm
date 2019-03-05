/datum/weather/passive_rads
	name = "passive radiation"
	desc = "Old radiation, presumably from detonated nuclear weapons."

	telegraph_duration = 1
	telegraph_message = ""

	weather_message = ""
	weather_duration_lower = 900000000 //WHY IS THERE NOT AN INFINITE OPTION
	weather_duration_upper = 900000000 //WHY IS THERE NOT AN INFINITE OPTION
	weather_color = "green"
	weather_sound = 'sound/misc/bloblarm.ogg'

	end_duration = 100
	end_message = "<span class='notice'>The air seems to be cooling off again.</span>"

	area_type = /area/metro/passive_radiation/lowrad

/datum/weather/passive_rads/weather_act(mob/living/L)
	var/area/metro/passive_radiation/user_area = get_area(L)
	if(istype(L.get_item_by_slot(SLOT_WEAR_MASK), /obj/item/clothing/mask/gas/metro))
		if(L.get_item_by_slot(SLOT_WEAR_MASK).CanBreathe())
			L.get_item_by_slot(SLOT_WEAR_MASK).Breathe(L)
			L.adjustOxyLoss(rand(user_area.extreme_min_mask_oxy_loss, user_area.extreme_max_mask_oxy_loss)/4)
			L.adjustToxLoss(rand(user_area.extreme_min_mask_tox_loss, user_area.extreme_max_mask_tox_loss)/4)
		else
			L.adjustOxyLoss(rand(user_area.min_mask_oxy_loss, user_area.max_mask_oxy_loss)/4)
			L.adjustToxLoss(rand(user_area.min_mask_tox_loss, user_area.max_mask_tox_loss)/4)
	else
		L.adjustOxyLoss(rand(user_area.min_oxy_loss, user_area.max_oxy_loss)/4)
		L.adjustToxLoss(rand(user_area.min_tox_loss, user_area.min_tox_loss)/4)


/datum/weather/passive_rads/extreme
	name = "powerful passive radiation"
	desc = "Old radiation, presumably from detonated nuclear weapons."

	telegraph_duration = 1
	telegraph_message = ""

	weather_message = ""
	weather_duration_lower = 900000000 //WHY IS THERE NOT AN INFINITE OPTION
	weather_duration_upper = 900000000 //WHY IS THERE NOT AN INFINITE OPTION
	weather_color = "green"
	weather_sound = 'sound/misc/bloblarm.ogg'

	end_duration = 100
	end_message = "<span class='notice'>The air seems to be cooling off again.</span>"

	area_type = /area/metro/passive_radiation/highrad

/datum/weather/passive_rads/extreme/weather_act(mob/living/L)
	var/area/metro/passive_radiation/user_area = get_area(L)
	if(istype(L.get_item_by_slot(SLOT_WEAR_MASK), /obj/item/clothing/mask/gas/metro))
		if(L.get_item_by_slot(SLOT_WEAR_MASK).CanBreathe())
			L.get_item_by_slot(SLOT_WEAR_MASK).Breathe(L, 2)
			L.adjustOxyLoss(rand(user_area.extreme_min_mask_oxy_loss, user_area.extreme_max_mask_oxy_loss)/4)
			L.adjustToxLoss(rand(user_area.extreme_min_mask_tox_loss, user_area.extreme_max_mask_tox_loss)/4)
		else
			L.adjustOxyLoss(rand(user_area.min_mask_oxy_loss, user_area.max_mask_oxy_loss)/4)
			L.adjustToxLoss(rand(user_area.min_mask_tox_loss, user_area.max_mask_tox_loss)/4)
	else
		L.adjustOxyLoss(rand(user_area.min_oxy_loss, user_area.max_oxy_loss)/4)
		L.adjustToxLoss(rand(user_area.min_tox_loss, user_area.min_tox_loss)/4)