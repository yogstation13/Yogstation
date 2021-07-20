
	//The mob should have a gender you want before running this proc. Will run fine without H
/datum/preferences/proc/random_character(gender_override)
	if(gender_override)
		gender = gender_override
	else
		gender = pick(MALE,FEMALE)
	if(!random_locks["underwear"])
		underwear = random_underwear(gender)
	if(!random_locks["undershirt"])
		undershirt = random_undershirt(gender)
	if(!random_locks["socks"])
		socks = random_socks()
	if(!random_locks["skin_tone"])
		skin_tone = random_skin_tone()
	if(!random_locks["hair_style"])
		hair_style = random_hair_style(gender)
	if(!random_locks["facial_hair_style"])
		facial_hair_style = random_facial_hair_style(gender)
	if(!random_locks["hair"])
		hair_color = random_short_color()
	if(!random_locks["facial"])
		facial_hair_color = hair_color
	if(!random_locks["eye_color"])
		eye_color = random_eye_color()
	if(!pref_species)
		var/rando_race = pick(GLOB.roundstart_races)
		pref_species = new rando_race()
	var/temp_features = random_features()
	if(random_locks["mcolor"])
		temp_features["mcolor"] = features["mcolor"]
	if(random_locks["ethcolor"])
		temp_features["ethcolor"] = features["ethcolor"]
	if(random_locks["tail_lizard"])
		temp_features["tail_lizard"] = features["tail_lizard"]
	if(random_locks["tail_human"])
		temp_features["tail_human"] = features["tail_human"]
	if(random_locks["wings"])
		temp_features["wings"] = features["wings"]
	if(random_locks["snout"])
		temp_features["snout"] = features["snout"]
	if(random_locks["horns"])
		temp_features["horns"] = features["horns"]
	if(random_locks["ears"])
		temp_features["ears"] = features["ears"]
	if(random_locks["frills"])
		temp_features["frills"] = features["frills"]
	if(random_locks["spines"])
		temp_features["spines"] = features["spines"]
	if(random_locks["body_markings"])
		temp_features["body_markings"] = features["body_markings"]
	if(random_locks["legs"])
		temp_features["legs"] = features["legs"]
	if(random_locks["caps"])
		temp_features["caps"] = features["caps"]
	if(random_locks["moth_wings"])
		temp_features["moth_wings"] = features["moth_wings"]
	if(random_locks["tail_polysmorph"])
		temp_features["tail_polysmorph"] = features["tail_polysmorph"]
	if(random_locks["teeth"])
		temp_features["teeth"] = features["teeth"]
	if(random_locks["dome"])
		temp_features["dome"] = features["dome"]
	if(random_locks["dorsal_tubes"])
		temp_features["dorsal_tubes"] = features["dorsal_tubes"]
	features = temp_features
	age = rand(AGE_MIN,AGE_MAX)

/datum/preferences/proc/update_preview_icon()
	// Determine what job is marked as 'High' priority, and dress them up as such.
	var/datum/job/previewJob
	var/highest_pref = 0
	for(var/job in job_preferences)
		if(job_preferences[job] > highest_pref)
			previewJob = SSjob.GetJob(job)
			highest_pref = job_preferences[job]

	if(previewJob)
		// Silicons only need a very basic preview since there is no customization for them.
		if(istype(previewJob,/datum/job/ai))
			parent.show_character_previews(image('icons/mob/ai.dmi', icon_state = resolve_ai_icon(preferred_ai_core_display), dir = SOUTH))
			return
		if(istype(previewJob,/datum/job/cyborg))
			parent.show_character_previews(image('icons/mob/robots.dmi', icon_state = "robot", dir = SOUTH))
			return

	// Set up the dummy for its photoshoot
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
	copy_to(mannequin)

	if(previewJob)
		mannequin.job = previewJob.title
		previewJob.equip(mannequin, TRUE, preference_source = parent)

	COMPILE_OVERLAYS(mannequin)
	parent.show_character_previews(new /mutable_appearance(mannequin))
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
