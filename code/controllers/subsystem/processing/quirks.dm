//Used to process and handle roundstart quirks
// - Quirk strings are used for faster checking in code
// - Quirk datums are stored and hold different effects, as well as being a vector for applying trait string
PROCESSING_SUBSYSTEM_DEF(quirks)
	name = "Quirks"
	init_order = INIT_ORDER_QUIRKS
	flags = SS_BACKGROUND
	wait = 1 SECONDS
	runlevels = RUNLEVEL_GAME

	var/list/quirks = list()		//Assoc. list of all roundstart quirk datum types; "name" = /path/
	var/list/quirk_points = list()	//Assoc. list of quirk names and their "point cost"; positive numbers are good traits, and negative ones are bad
	var/list/quirk_objects = list()	//A list of all quirk objects in the game, since some may process
	var/list/quirk_blacklist = list() //A list a list of quirks that can not be used with each other. Format: list(quirk1,quirk2),list(quirk3,quirk4)

/datum/controller/subsystem/processing/quirks/Initialize(timeofday)
	if(!quirks.len)
		SetupQuirks()

	quirk_blacklist = list(
		list("Blind","Nearsighted"),
		list("Jolly","Depression","Apathetic","Hypersensitive"),
		list("Ageusia","Vegetarian","Deviant Tastes"),
		list("Ananas Affinity","Ananas Aversion"),
		list("Alcohol Tolerance","Light Drinker"),
		list("Prosthetic Limb (Left Arm)","Prosthetic Limb"),
		list("Prosthetic Limb (Right Arm)","Prosthetic Limb"),
		list("Prosthetic Limb (Left Leg)","Prosthetic Limb"),
		list("Prosthetic Limb (Right Leg)","Prosthetic Limb"),
		list("Prosthetic Limb (Left Leg)","Paraplegic"),
		list("Prosthetic Limb (Right Leg)","Paraplegic"),
		list("Prosthetic Limb","Paraplegic")
	)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/processing/quirks/proc/SetupQuirks()
	// Sort by Positive, Negative, Neutral; and then by name
	var/list/quirk_list = sortList(subtypesof(/datum/quirk), /proc/cmp_quirk_asc)

	for(var/V in quirk_list)
		var/datum/quirk/T = V
		quirks[initial(T.name)] = T
		quirk_points[initial(T.name)] = initial(T.value)

/datum/controller/subsystem/processing/quirks/proc/AssignQuirks(mob/living/user, client/cli, spawn_effects)
	if(!checkquirks(user,cli)) return// Yogs -- part of Adding Mood as Preference

	var/badquirk = FALSE

	for(var/V in cli.prefs.all_quirks)
		var/datum/quirk/Q = quirks[V]
		if(Q)
			user.add_quirk(Q, spawn_effects)
		else
			stack_trace("Invalid quirk \"[V]\" in client [cli.ckey] preferences")
			cli.prefs.all_quirks -= V
			badquirk = TRUE
	if(badquirk)
		cli.prefs.save_character()

/// Takes a list of quirk names and returns a new list of quirks that would
/// be valid.
/// If no changes need to be made, will return the same list.
/// Expects all quirk names to be unique, but makes no other expectations.
/datum/controller/subsystem/processing/quirks/proc/filter_invalid_quirks(list/quirks, client_or_prefs)
	var/list/new_quirks = list()
	var/list/positive_quirks = list()
	var/balance = 0

	var/datum/preferences/prefs = client_or_prefs

	if (istype(client_or_prefs, /client))
		var/client/client = client_or_prefs
		prefs = client.prefs

	// If moods are globally enabled, or this guy does indeed have his mood pref set to Enabled
	var/ismoody = (!CONFIG_GET(flag/disable_human_mood) || (prefs.yogtoggles & PREF_MOOD))

	for (var/quirk_name in quirks)
		var/datum/quirk/quirk = SSquirks.quirks[quirk_name]
		if (isnull(quirk))
			continue

		if (initial(quirk.mood_quirk) && !ismoody)
			continue

		// Returns error string, FALSE if quirk is okay to have
		var/datum/quirk/quirk_obj = new quirk(no_init = TRUE)
		if (quirk_obj?.check_quirk(prefs))
			continue
		qdel(quirk_obj)

		var/blacklisted = FALSE

		for (var/list/blacklist as anything in quirk_blacklist)
			if (!(quirk in blacklist))
				continue

			for (var/other_quirk in blacklist)
				if (other_quirk in new_quirks)
					blacklisted = TRUE
					break

			if (blacklisted)
				break

		if (blacklisted)
			continue

		var/value = initial(quirk.value)
		if (value > 0)
			if (positive_quirks.len == MAX_QUIRKS)
				continue

			positive_quirks[quirk_name] = value

		balance += value
		new_quirks += quirk_name

	if (balance > 0)
		var/balance_left_to_remove = balance

		for (var/positive_quirk in positive_quirks)
			var/value = positive_quirks[positive_quirk]
			balance_left_to_remove -= value
			new_quirks -= positive_quirk

			if (balance_left_to_remove <= 0)
				break

	// It is guaranteed that if no quirks are invalid, you can simply check through `==`
	if (new_quirks.len == quirks.len)
		return quirks

	return new_quirks
