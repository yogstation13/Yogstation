
/datum/admins/proc/create_mob(mob/user)
	var/static/create_mob_html
	if (!create_mob_html)
		var/mobjs = null
		mobjs = jointext(typesof(/mob), ";")
		create_mob_html = file2text('html/create_object.html')
		create_mob_html = replacetext(create_mob_html, "Create Object", "Create Mob")
		create_mob_html = replacetext(create_mob_html, "null /* object types */", "\"[mobjs]\"")

	user << browse(create_panel_helper(create_mob_html), "window=create_mob;size=425x475")

/proc/randomize_human(mob/living/carbon/human/human)
	human.gender = pick(MALE, FEMALE)
	human.real_name = human.dna?.species.random_name(human.gender) || random_unique_name(human.gender)
	human.name = human.real_name
	human.underwear = random_underwear(human.gender)
	human.skin_tone = random_skin_tone()
	human.hair_style = random_hair_style(human.gender)
	human.facial_hair_style = random_facial_hair_style(human.gender)
	human.hair_color = "#[random_color()]"
	human.facial_hair_color = human.hair_color
	human.eye_color = random_eye_color()
	human.dna.blood_type = random_blood_type()

	// Mutant randomizing, doesn't affect the mob appearance unless it's the specific mutant.
	human.dna.features["mcolor"] = "#[random_color()]"
	human.dna.features["pretcolor"] = GLOB.color_list_preternis[pick(GLOB.color_list_preternis)]
	human.dna.features["tail_lizard"] = pick(GLOB.tails_list_lizard)
	human.dna.features["tail_polysmorph"] = pick(GLOB.tails_list_polysmorph)
	human.dna.features["snout"] = pick(GLOB.snouts_list)
	human.dna.features["horns"] = pick(GLOB.horns_list)
	human.dna.features["frills"] = pick(GLOB.frills_list)
	human.dna.features["spines"] = pick(GLOB.spines_list)
	human.dna.features["body_markings"] = pick(GLOB.body_markings_list)
	human.dna.features["moth_wings"] = pick(GLOB.moth_wings_list)
	human.dna.features["teeth"] = pick(GLOB.teeth_list)
	human.dna.features["dome"] = pick(GLOB.dome_list)
	human.dna.features["dorsal_tubes"] = pick(GLOB.dorsal_tubes_list)
	human.dna.features["ethereal_mark"] = pick(GLOB.ethereal_mark_list)
	human.dna.features["preternis_weathering"] = pick(GLOB.preternis_weathering_list)
	human.dna.features["preternis_antenna"] = pick(GLOB.preternis_antenna_list)
	human.dna.features["preternis_eye"] = pick(GLOB.preternis_eye_list)
	human.dna.features["preternis_core"] = pick(GLOB.preternis_core_list)
	human.dna.features["pod_hair"] = pick(GLOB.pod_hair_list)
	human.dna.features["pod_flower"] = GLOB.pod_flower_list[human.dna.features["pod_hair"]]

	human.update_body()
	human.update_hair()
	human.update_body_parts()
