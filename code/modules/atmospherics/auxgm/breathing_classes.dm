// Breathing classes are, yes, just a list of gases, associated with numbers.
// But they're very simple: pluoxium's status as O2 * 8 is represented here,
// with a single line of code, no hardcoding and special-casing across the codebase.
// Not only that, but they're very general: you could have a negative value
// to simulate asphyxiants, e.g. if I add krypton it could go into the oxygen
// breathing class at -7, simulating krypton narcosis.

/datum/breathing_class
	///Gases that we consume and count as respirable
	var/list/gases
	///Gases that we breathe out
	var/list/products
	///Reagent generated if we breathe in too much of the gases in the gas_max value of gases defined in lungs
	var/danger_reagent
	///Catergory of the alert generated if we do not have enough required gases
	var/low_alert_category = "not_enough_oxy"
	///Type of the alert generated if we do not have enough required gases
	var/low_alert_datum = /atom/movable/screen/alert/not_enough_oxy
	///Catergory of the alert generated if we breathe in too much of the gases in the gas_max value of gases defined in lungs
	var/high_alert_category = "too_much_oxy"
	///Type of the alert generated if we breathe in too much of the gases in the gas_max value of gases defined in lungs
	var/high_alert_datum = /atom/movable/screen/alert/too_much_oxy

/datum/breathing_class/proc/get_effective_pp(datum/gas_mixture/breath)
	var/mol = 0
	for(var/gas in gases)
		mol += breath.get_moles(gas) * gases[gas]
	return (mol/breath.total_moles()) * breath.return_pressure()

/datum/breathing_class/oxygen
	gases = list(
		GAS_O2 = 1,
		GAS_PLUOXIUM = 8,
		GAS_CO2 = -0.7, // CO2 isn't actually toxic, just an asphyxiant
	)
	products = list(
		GAS_CO2 = 1,
	)

/datum/breathing_class/oxygen_plas
	gases = list(
		GAS_O2 = 1,
		GAS_PLUOXIUM = 8,
		GAS_CO2 = -0.7, // CO2 isn't actually toxic, just an asphyxiant
		GAS_PLASMA = 1
	)
	products = list(
		GAS_CO2 = 1,
	)

/datum/breathing_class/oxygen_co2
	gases = list(
		GAS_O2 = 1,
		GAS_PLUOXIUM = 8,
		GAS_CO2 = 1, 
	)
	products = list(
		GAS_CO2 = 1,
	)

/datum/breathing_class/plasma
	gases = list(
		GAS_PLASMA = 1
	)
	products = list(
		GAS_CO2 = 1
	)
	low_alert_category = "not_enough_tox"
	low_alert_datum = /atom/movable/screen/alert/not_enough_tox
	high_alert_category = "too_much_tox"
	high_alert_datum = /atom/movable/screen/alert/too_much_tox

/datum/breathing_class/oxygen_vapor
	gases = list(
		GAS_O2 = 1,
		GAS_PLUOXIUM = 8,
		GAS_CO2 = -0.7, // CO2 isn't actually toxic, just an asphyxiant
		GAS_H2O = 1,
	)
	products = list(
		GAS_CO2 = 1,
	)
