/datum/reagent
	///Whether it will evaporate if left untouched on a liquids simulated puddle
	var/evaporates = FALSE

	///How much fire power does the liquid have, for burning on simulated liquids. Not enough fire power/unit of entire mixture may result in no fire
	var/liquid_fire_power = 0

	///How fast does the liquid burn on simulated turfs, if it does
	var/liquid_fire_burnrate = 0

	///Whether a fire from this requires oxygen in the atmosphere
	var/fire_needs_oxygen = TRUE

/*
*	ALCOHOL REAGENTS
*/
/datum/reagent/consumable/ethanol
	liquid_fire_power = 10
	liquid_fire_burnrate = 0.1

// 0 fire power
/datum/reagent/consumable/ethanol/beer/light
	liquid_fire_power = 0

/datum/reagent/consumable/ethanol/threemileisland
	liquid_fire_power = 0

/datum/reagent/consumable/ethanol/grog
	liquid_fire_power = 0

/datum/reagent/consumable/ethanol/fetching_fizz
	liquid_fire_power = 0

/datum/reagent/consumable/ethanol/sugar_rush
	liquid_fire_power = 0

/datum/reagent/consumable/ethanol/crevice_spike
	liquid_fire_power = 0

/datum/reagent/consumable/ethanol/fanciulli
	liquid_fire_power = 0

// 2 fire power
/datum/reagent/consumable/ethanol/beer
	liquid_fire_power = 2

/datum/reagent/consumable/ethanol/wine
	liquid_fire_power = 2

/datum/reagent/consumable/ethanol/lizardwine
	liquid_fire_power = 2

/datum/reagent/consumable/ethanol/amaretto
	liquid_fire_power = 2

/datum/reagent/consumable/ethanol/goldschlager
	liquid_fire_power = 2

/datum/reagent/consumable/ethanol/gintonic
	liquid_fire_power = 2

/datum/reagent/consumable/ethanol/iced_beer
	liquid_fire_power = 2

/datum/reagent/consumable/ethanol/irishcarbomb
	liquid_fire_power = 2

/datum/reagent/consumable/ethanol/hcider
	liquid_fire_power = 2

/datum/reagent/consumable/ethanol/narsour
	liquid_fire_power = 2

/datum/reagent/consumable/ethanol/peppermint_patty
	liquid_fire_power = 2

/datum/reagent/consumable/ethanol/blank_paper
	liquid_fire_power = 2

/datum/reagent/consumable/ethanol/applejack
	liquid_fire_power = 2

/datum/reagent/consumable/ethanol/jack_rose
	liquid_fire_power = 2

/datum/reagent/consumable/ethanol/old_timer
	liquid_fire_power = 2

/datum/reagent/consumable/ethanol/duplex
	liquid_fire_power = 2

/datum/reagent/consumable/ethanol/painkiller
	liquid_fire_power = 2

// 3 fire power
/datum/reagent/consumable/ethanol/longislandicedtea
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/irishcoffee
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/margarita
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/manhattan
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/snowwhite
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/bahama_mama
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/singulo
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/red_mead
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/mead
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/aloe
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/andalusia
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/alliescocktail
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/amasec
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/erikasurprise
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/whiskey_sour
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/triple_sec
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/creme_de_menthe
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/creme_de_cacao
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/creme_de_coconut
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/quadruple_sec
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/grasshopper
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/stinger
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/bastion_bourbon
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/squirt_cider
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/amaretto_alexander
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/sidecar
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/mojito
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/moscow_mule
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/fruit_wine
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/champagne
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/pina_colada
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/ginger_amaretto
	liquid_fire_power = 3

// 4 fire power
/datum/reagent/consumable/ethanol/rum_coke
	liquid_fire_power = 4

/datum/reagent/consumable/ethanol/booger
	liquid_fire_power = 4

/datum/reagent/consumable/ethanol/tequila_sunrise
	liquid_fire_power = 4

/*
*	PYROTECHNIC REAGENTS
*/
/datum/reagent/thermite
	liquid_fire_power = 20
	liquid_fire_burnrate = 0.1

/datum/reagent/phlogiston
	liquid_fire_power = 20
	liquid_fire_burnrate = 0.1

/datum/reagent/clf3
	liquid_fire_power = 30
	liquid_fire_burnrate = 0.1

/datum/reagent/napalm
	liquid_fire_power = 30
	liquid_fire_burnrate = 0.1

/*
*	OTHER
*/

/datum/reagent/fuel
	liquid_fire_power = 10
	liquid_fire_burnrate = 0.1

/proc/mix_color_from_reagent_list(list/reagent_list)
	var/mixcolor
	var/vol_counter = 0
	var/vol_temp
	var/cached_color
	var/datum/reagent/raw_reagent

	for(var/reagent_type in reagent_list)
		vol_temp = reagent_list[reagent_type]
		vol_counter += vol_temp
		raw_reagent = reagent_type // Not initialized
		cached_color = initial(raw_reagent.color)

		if(!mixcolor)
			mixcolor = cached_color
		else if (length(mixcolor) >= length(cached_color))
			mixcolor = BlendRGB(mixcolor, cached_color, vol_temp/vol_counter)
		else
			mixcolor = BlendRGB(cached_color, mixcolor, vol_temp/vol_counter)

	return mixcolor
