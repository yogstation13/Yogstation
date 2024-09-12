/datum/artifact_effect/smoke
	weight = ARTIFACT_UNCOMMON
	type_name = "Smoke Machine (Colorful) Effect"
	activation_message = "starts spewing out colorful smoke!"
	deactivation_message = "becomes silent."

	research_value = 250

	examine_discovered = span_warning("It appears to be some sort of checmical aerolyzer for coloring things")

	var/list/valid_chemicals = list(
		/datum/reagent/colorful_reagent,
		/datum/reagent/colorful_reagent/powder/black,
		/datum/reagent/colorful_reagent/powder/blue,
		/datum/reagent/colorful_reagent/powder/purple,
		/datum/reagent/colorful_reagent/powder/orange,
		/datum/reagent/colorful_reagent/powder/red,
		/datum/reagent/colorful_reagent/powder/yellow,
	)
	var/per_chemical_amount	= 5
	var/chemicals_chosen = 2
	var/list/chemicals = list()
	var/smoke_range = 3

/datum/artifact_effect/smoke/setup()
	per_chemical_amount = rand(5, 10)
	chemicals_chosen = rand(1, 5)
	smoke_range = rand(1, 5)
	potency += per_chemical_amount * 3 + chemicals_chosen * 3 + smoke_range * 2

	for(var/i = 1 to chemicals_chosen)
		chemicals += pick(valid_chemicals)

/datum/artifact_effect/smoke/effect_activate(silent)
	if(our_artifact.holder)
		for(var/chemical in chemicals)
			do_chem_smoke(smoke_range, holder = our_artifact.holder, location = get_turf(our_artifact.holder), reagent_type = chemical, reagent_volume = per_chemical_amount, log = TRUE)
		our_artifact.artifact_deactivate()

/datum/artifact_effect/smoke/toxin
	weight = ARTIFACT_RARE
	type_name = "Smoke Machine (Harmful) Effect"
	activation_message = "starts spewing out toxic smoke!"
	valid_chemicals = list(
		/datum/reagent/toxin/bonehurtingjuice,
		/datum/reagent/toxin/itching_powder,
		/datum/reagent/toxin/mindbreaker,
		/datum/reagent/toxin/spewium,
	)
	examine_discovered = span_danger("It appears to be some sort of checmical aerolyzer for harming things!")

/datum/artifact_effect/smoke/flesh
	type_name = "Smoke Machine (Synthflesh) Effect"
	weight = ARTIFACT_RARE
	activation_message = "starts spewing out flesh mending smoke!"
	valid_chemicals = list(
		/datum/reagent/medicine/c2/synthflesh
	)
	examine_discovered = span_info("It appears to be some sort of checmical aerolyzer for healing things!")

/datum/artifact_effect/smoke/exotic
	type_name = "Smoke Machine (Exotic) Effect"
	weight = ARTIFACT_RARE
	activation_message = "starts spewing out exotic smoke!"

	examine_discovered = span_warning("It appears to be some sort of checmical aerolyzer for... not sure actually.")
	valid_chemicals = list(
		/datum/reagent/wittel,
		/datum/reagent/medicine/omnizine/protozine,
		/datum/reagent/water/hollowwater,
		/datum/reagent/plasma_oxide,
		/datum/reagent/australium,
		/datum/reagent/shakeium,
	)
