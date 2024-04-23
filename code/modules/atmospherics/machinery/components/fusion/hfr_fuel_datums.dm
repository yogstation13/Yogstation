///Global list of recipes for atmospheric machines to use
GLOBAL_LIST_INIT(hfr_fuels_list, hfr_fuels_create_list())

/*
 * Global proc to build the gas recipe global list
 */
/proc/hfr_fuels_create_list()
	. = list()
	for(var/fuel_mix_path in subtypesof(/datum/hfr_fuel))
		var/datum/hfr_fuel/fuel_mix = new fuel_mix_path()

		.[fuel_mix.id] = fuel_mix

/datum/hfr_fuel
	///Id for the mix
	var/id = ""
	///The gases that are going to be used as fuel ("GasX + GasY fuel")
	var/name = ""
	///Multiplier for the minimum heat output of the HFR (min 0.01)
	var/negative_temperature_multiplier = 1
	///Multiplier for the maximum heat output of the HFR (min 0.01)
	var/positive_temperature_multiplier = 1
	///Multiplier for the energy released (min 0.01)
	var/energy_concentration_multiplier = 1
	///Multiplier for the fuel consumption (min 0.01)
	var/fuel_consumption_multiplier = 1
	///Multiplier for the gas production (min 0.01)
	var/gas_production_multiplier = 1
	///Max allowed temperature multiplier, scales the max temperature we can hit, see FUSION_MAXIMUM_TEMPERATURE (Maxed at 1, don't go getting any ideas)
	var/temperature_change_multiplier = 1
	///These are the main fuels, only 2 gases that are the ones being consumed by the fusion reaction (eg. H2 and trit)
	var/requirements = list()
	///Gases that gets produced directly in the internal gasmix
	var/primary_products = list()
	///Gases that gets produced in the moderator gasmix or directly ejected (must be 6 gases), the order indicate at what power level the gases are going to be made (from power level 1 to 6)
	var/secondary_products = list()
	///Flags to decide what behaviour the meltdown will have depending on the fuel mix used
	var/meltdown_flags = HYPERTORUS_FLAG_BASE_EXPLOSION

/datum/hfr_fuel/New()
	. = ..()
	temperature_change_multiplier = min(temperature_change_multiplier, 1)

/datum/hfr_fuel/plasma_oxy_fuel
	id = "plasma_o2_fuel"
	name = "Plasma + Oxygen fuel"
	negative_temperature_multiplier = 2.5
	positive_temperature_multiplier = 0.1
	energy_concentration_multiplier = 10
	fuel_consumption_multiplier = 3.3
	gas_production_multiplier = 1.4
	temperature_change_multiplier = 0.6
	requirements = list(GAS_PLASMA, GAS_O2)
	primary_products = list(GAS_CO2, GAS_H2O)
	secondary_products = list(GAS_CO2, GAS_FREON, GAS_TRITIUM, GAS_H2, GAS_PLUOXIUM, GAS_HALON)
	meltdown_flags = HYPERTORUS_FLAG_BASE_EXPLOSION | HYPERTORUS_FLAG_MINIMUM_SPREAD

/datum/hfr_fuel/hydrogen_oxy_fuel
	id = "h2_o2_fuel"
	name = "Hydrogen + Oxygen fuel"
	negative_temperature_multiplier = 2
	positive_temperature_multiplier = 0.6
	energy_concentration_multiplier = 3
	fuel_consumption_multiplier = 1.1
	gas_production_multiplier = 0.9
	temperature_change_multiplier = 0.75
	requirements = list(GAS_H2, GAS_O2)
	primary_products = list(GAS_N2)
	secondary_products = list(GAS_PLASMA, GAS_FREON, GAS_BZ, GAS_HEALIUM, GAS_PLUOXIUM, GAS_HYPERNOB)
	meltdown_flags = HYPERTORUS_FLAG_BASE_EXPLOSION | HYPERTORUS_FLAG_EMP | HYPERTORUS_FLAG_MEDIUM_SPREAD

/datum/hfr_fuel/tritium_oxy_fuel
	id = "t2_o2_fuel"
	name = "Tritium + Oxygen fuel"
	negative_temperature_multiplier = 2.1
	positive_temperature_multiplier = 0.5
	energy_concentration_multiplier = 2
	fuel_consumption_multiplier = 1.2
	gas_production_multiplier = 0.8
	temperature_change_multiplier = 0.8
	requirements = list(GAS_TRITIUM, GAS_O2)
	primary_products = list(GAS_PLUOXIUM)
	secondary_products = list(GAS_PLASMA, GAS_PLUOXIUM, GAS_HEALIUM, GAS_H2, GAS_HALON, GAS_HYPERNOB)
	meltdown_flags = HYPERTORUS_FLAG_BASE_EXPLOSION | HYPERTORUS_FLAG_RADIATION_PULSE | HYPERTORUS_FLAG_MEDIUM_SPREAD

/datum/hfr_fuel/hydrogen_tritium_fuel
	id = "h2_t2_fuel"
	name = "Hydrogen + Tritium fuel"
	negative_temperature_multiplier = 1
	positive_temperature_multiplier = 1
	energy_concentration_multiplier = 1
	fuel_consumption_multiplier = 1
	gas_production_multiplier = 1
	temperature_change_multiplier = 0.85
	requirements = list(GAS_H2, GAS_TRITIUM)
	primary_products = list(GAS_PLUOXIUM)
	secondary_products = list(GAS_N2, GAS_HEALIUM, GAS_DILITHIUM, GAS_HEXANE, GAS_HYPERNOB, GAS_ANTINOB)
	meltdown_flags = HYPERTORUS_FLAG_MEDIUM_EXPLOSION | HYPERTORUS_FLAG_RADIATION_PULSE | HYPERTORUS_FLAG_EMP | HYPERTORUS_FLAG_MEDIUM_SPREAD

/datum/hfr_fuel/hypernob_hydrogen_fuel
	id = "hypernob_hydrogen_fuel"
	name = "Hypernoblium + Hydrogen fuel"
	negative_temperature_multiplier = 0.2
	positive_temperature_multiplier = 2.2
	energy_concentration_multiplier = 0.2
	fuel_consumption_multiplier = 0.55
	gas_production_multiplier = 1.4
	temperature_change_multiplier = 0.9
	requirements = list(GAS_HYPERNOB, GAS_H2)
	primary_products = list(GAS_ANTINOB)
	secondary_products = list(GAS_ANTINOB, GAS_HEALIUM, GAS_PLUOXIUM, GAS_PLUONIUM, GAS_ZAUKER, GAS_NITRIUM)
	meltdown_flags = HYPERTORUS_FLAG_DEVASTATING_EXPLOSION | HYPERTORUS_FLAG_RADIATION_PULSE | HYPERTORUS_FLAG_EMP | HYPERTORUS_FLAG_BIG_SPREAD

/datum/hfr_fuel/hypernob_trit_fuel
	id = "hypernob_trit_fuel"
	name = "Hypernoblium + Tritium fuel"
	negative_temperature_multiplier = 0.1
	positive_temperature_multiplier = 2.5
	energy_concentration_multiplier = 0.1
	fuel_consumption_multiplier = 0.45
	gas_production_multiplier = 1.7
	temperature_change_multiplier = 0.95
	requirements = list(GAS_HYPERNOB, GAS_TRITIUM)
	primary_products = list(GAS_ANTINOB)
	secondary_products = list(GAS_ANTINOB, GAS_HEALIUM, GAS_PLUONIUM, GAS_ZAUKER, GAS_NITRIUM, GAS_MIASMA)
	meltdown_flags = HYPERTORUS_FLAG_DEVASTATING_EXPLOSION | HYPERTORUS_FLAG_RADIATION_PULSE | HYPERTORUS_FLAG_EMP | HYPERTORUS_FLAG_BIG_SPREAD

/datum/hfr_fuel/pluox_antinob_fuel
	id = "pluox_antinob_fuel"
	name = "Pluoxium + Antinoblium fuel"
	negative_temperature_multiplier = 0.1
	positive_temperature_multiplier = 2.7
	energy_concentration_multiplier = 1.5
	fuel_consumption_multiplier = 0.05
	gas_production_multiplier = 2
	temperature_change_multiplier = 0.97
	requirements = list(GAS_PLUOXIUM, GAS_ANTINOB)
	primary_products = list(GAS_HYPERNOB, GAS_MIASMA)
	secondary_products = list(GAS_HALON, GAS_HEXANE, GAS_BZ, GAS_NITRIUM, GAS_HEALIUM, GAS_ZAUKER)
	meltdown_flags = HYPERTORUS_FLAG_DEVASTATING_EXPLOSION | HYPERTORUS_FLAG_RADIATION_PULSE | HYPERTORUS_FLAG_EMP | HYPERTORUS_FLAG_MASSIVE_SPREAD

/datum/hfr_fuel/hypernob_antinob_fuel
	id = "hypernob_antinob_fuel"
	name = "Hypernoblium + Antinoblium fuel"
	negative_temperature_multiplier = 0.01
	positive_temperature_multiplier = 3.5
	energy_concentration_multiplier = 2
	fuel_consumption_multiplier = 0.01
	gas_production_multiplier = 3
	temperature_change_multiplier = 1
	requirements = list(GAS_HYPERNOB, GAS_ANTINOB)
	primary_products = list(GAS_ZAUKER, GAS_MIASMA)
	secondary_products = list(GAS_O2, GAS_NITRIUM, GAS_BZ, GAS_PLUONIUM, GAS_HEXANE, GAS_HEALIUM)
	meltdown_flags = HYPERTORUS_FLAG_DEVASTATING_EXPLOSION | HYPERTORUS_FLAG_RADIATION_PULSE | HYPERTORUS_FLAG_EMP | HYPERTORUS_FLAG_MASSIVE_SPREAD | HYPERTORUS_FLAG_CRITICAL_MELTDOWN
