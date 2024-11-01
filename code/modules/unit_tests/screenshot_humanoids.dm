/// A screenshot test for every humanoid species with a handful of jobs.
/datum/unit_test/screenshot_humanoids

/datum/unit_test/screenshot_humanoids/Run()
	// Test lizards as their own thing so we can get more coverage on their features
	var/mob/living/carbon/human/lizard = allocate(/mob/living/carbon/human/dummy/consistent)
	var/datum/color_palette/generic_colors/located = lizard.dna.color_palettes[/datum/color_palette/generic_colors]
	located.mutant_color = "#099"
	lizard.dna.features["tail_lizard"] = "Light Tiger"
	lizard.dna.features["snout"] = "Sharp + Light"
	lizard.dna.features["horns"] = "Simple"
	lizard.dna.features["frills"] = "Aquatic"
	lizard.dna.features["legs"] = "Normal Legs"
	lizard.set_species(/datum/species/lizard)
	lizard.equipOutfit(/datum/outfit/job/engineer)
	test_screenshot("[/datum/species/lizard]", get_flat_icon_for_all_directions(lizard))

	// let me have this
	var/mob/living/carbon/human/moth = allocate(/mob/living/carbon/human/dummy/consistent)
	moth.dna.features["moth_antennae"] = "Firewatch"
	moth.dna.features["moth_markings"] = "None"
	moth.dna.features["moth_wings"] = "Firewatch"
	moth.set_species(/datum/species/moth)
	moth.equipOutfit(/datum/outfit/job/cmo, visualsOnly = TRUE)
	test_screenshot("[/datum/species/moth]", get_flat_icon_for_all_directions(moth))

	//MONKESTATION ADDITION START
	var/mob/living/carbon/human/tundramoth = allocate(/mob/living/carbon/human/dummy/consistent)
	tundramoth.dna.features["moth_antennae"] = "Tundra"
	tundramoth.dna.features["moth_markings"] = "Tundra"
	tundramoth.dna.features["moth_wings"] = "Tundra"
	tundramoth.set_species(/datum/species/moth/tundra)
	tundramoth.equipOutfit(/datum/outfit/job/doctor, visualsOnly = TRUE)
	test_screenshot("[/datum/species/moth/tundra]", get_flat_icon_for_all_directions(tundramoth))

	var/mob/living/carbon/human/apid = allocate(/mob/living/carbon/human/dummy/consistent)
	apid.dna.features["apid_antenna"] = "Horns"
	apid.dna.features["apid_wings"] = "Normal" // Just in case someone ever adds more
	apid.set_species(/datum/species/apid)
	apid.equipOutfit(/datum/outfit/job/botanist)
	test_screenshot("[/datum/species/apid]", get_flat_icon_for_all_directions(apid))
	//MONKESTATION ADDITION END

	// The rest of the species
	for (var/datum/species/species_type as anything in subtypesof(/datum/species) - typesof(/datum/species/moth) - /datum/species/lizard - /datum/species/apid)
		test_screenshot("[species_type]", get_flat_icon_for_all_directions(make_dummy(species_type, /datum/outfit/job/assistant/consistent)))

/datum/unit_test/screenshot_humanoids/proc/make_dummy(species, job_outfit)
	var/mob/living/carbon/human/dummy/consistent/dummy = allocate(/mob/living/carbon/human/dummy/consistent)
	dummy.set_species(species)
	dummy.equipOutfit(job_outfit, visualsOnly = TRUE)
	return dummy
