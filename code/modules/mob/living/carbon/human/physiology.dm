//Stores several modifiers in a way that isn't cleared by changing species

/datum/physiology
	var/brute_mod = TRUE   	// % of brute damage taken from all sources
	var/burn_mod = TRUE    	// % of burn damage taken from all sources
	var/tox_mod = TRUE     	// % of toxin damage taken from all sources
	var/oxy_mod = TRUE     	// % of oxygen damage taken from all sources
	var/clone_mod = TRUE   	// % of clone damage taken from all sources
	var/stamina_mod = TRUE 	// % of stamina damage taken from all sources
	var/brain_mod = TRUE   	// % of brain damage taken from all sources

	var/pressure_mod = 1	// % of brute damage taken from low or high pressure (stacks with brute_mod)
	var/heat_mod = TRUE    	// % of burn damage taken from heat (stacks with burn_mod)
	var/cold_mod = TRUE    	// % of burn damage taken from cold (stacks with burn_mod)

	var/damage_resistance = FALSE // %damage reduction from all sources

	var/siemens_coeff = TRUE 	// resistance to shocks

	var/stun_mod = TRUE      	// % stun modifier
	var/bleed_mod = TRUE     	// % bleeding modifier
	var/datum/armor/armor 	// internal armor datum

	var/hunger_mod = 1		//% of hunger rate taken per tick.

	var/do_after_speed = TRUE //Speed mod for do_after. Lower is better. If temporarily adjusting, please only modify using *= and /=, so you don't interrupt other calculations.

/datum/physiology/New()
	armor = new
