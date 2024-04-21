/datum/breathing_class/vox
	gases = list(
		GAS_N2 = 1,
		GAS_CO2 = -0.7,
	)
	products = list(
		GAS_CO2 = 1
	)
	low_alert_category = "not_enough_nitro"
	low_alert_datum = /atom/movable/screen/alert/not_enough_nitro
	high_alert_category = "too_much_nitro"
	high_alert_datum = /atom/movable/screen/alert/too_much_nitro
