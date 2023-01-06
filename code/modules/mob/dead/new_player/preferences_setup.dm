
/// Fully randomizes everything in the character.
/datum/preferences/proc/randomise_appearance_prefs(randomize_flags = ALL)
	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (!preference.included_in_randomization_flags(randomize_flags))
			continue

		if (preference.is_randomizable())
			write_preference(preference, preference.create_random_value(src))

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
	for(var/i in temp_features)
		if(random_locks[i])
			i = features[i]
	features = temp_features
	age = rand(AGE_MIN,AGE_MAX)

/// Returns what job is marked as highest
/datum/preferences/proc/get_highest_priority_job()
	var/datum/job/preview_job
	var/highest_pref = 0

	for(var/job in job_preferences)
		if(job_preferences[job] > highest_pref)
			preview_job = SSjob.GetJob(job)
			highest_pref = job_preferences[job]

	return preview_job

/datum/preferences/proc/render_new_preview_appearance(mob/living/carbon/human/dummy/mannequin)
	var/datum/job/preview_job = get_highest_priority_job()

	if(preview_job)
		// Silicons only need a very basic preview since there is no customization for them.
		if (istype(preview_job,/datum/job/ai))
			return image('icons/mob/ai.dmi', icon_state = resolve_ai_icon(read_preference(/datum/preference/choiced/ai_core_display)), dir = SOUTH)
		if (istype(preview_job,/datum/job/cyborg))
			return image('icons/mob/robots.dmi', icon_state = "robot", dir = SOUTH)

	// Set up the dummy for its photoshoot
	mannequin.add_overlay(mutable_appearance('icons/turf/floors.dmi', background, layer = SPACE_LAYER))
	copy_to(mannequin)

	if(preview_job)
		mannequin.job = preview_job.title
		mannequin.dress_up_as_job(preview_job, TRUE)

	COMPILE_OVERLAYS(mannequin)
	return mannequin.appearance
