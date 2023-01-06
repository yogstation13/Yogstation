GLOBAL_LIST_EMPTY(preferences_datums)

/datum/preferences
	var/client/parent
	//doohickeys for savefiles
	var/path
	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
	var/max_save_slots = 3

	//non-preference stuff
	var/muted = 0
	var/last_ip
	var/last_id

	//game-preferences
	var/lastchangelog = ""				//Saved changlog filesize to detect if there was a change
	var/ooccolor = "#c43b23"
	var/asaycolor = null
	var/enable_tips = TRUE
	var/tip_delay = 500 //tip delay in milliseconds

	//Antag preferences
	var/list/be_special = list()		//Special role selection
	var/tmp/old_be_special = 0			//Bitflag version of be_special, used to update old savefiles and nothing more
										//If it's 0, that's good, if it's anything but 0, the owner of this prefs file's antag choices were,
										//autocorrected this round, not that you'd need to check that.

	var/UI_style = null
	var/buttons_locked = FALSE
	var/hotkeys = TRUE

	/// Custom keybindings. Map of keybind names to keyboard inputs.
	/// For example, by default would have "swap_hands" -> list("X")
	var/list/key_bindings = list()

	/// Cached list of keybindings, mapping keys to actions.
	/// For example, by default would have "X" -> list("swap_hands")
	var/list/key_bindings_by_key = list()
	
	var/tgui_fancy = TRUE
	var/tgui_lock = FALSE
	var/windowflashing = TRUE
	var/toggles = TOGGLES_DEFAULT
	var/db_flags
	var/chat_toggles = TOGGLES_DEFAULT_CHAT
	var/extra_toggles = TOGGLES_DEFAULT_EXTRA
	var/ghost_form = "ghost"
	var/ghost_orbit = GHOST_ORBIT_CIRCLE
	var/ghost_accs = GHOST_ACCS_DEFAULT_OPTION
	var/ghost_others = GHOST_OTHERS_DEFAULT_OPTION
	var/ghost_hud = 1
	var/inquisitive_ghost = 1
	var/allow_midround_antag = 1
	var/preferred_map = null
	var/pda_style = MONO
	var/pda_color = "#808000"
	var/pda_theme = PDA_THEME_TITLE_NTOS
	var/id_in_pda = FALSE
	var/show_credits = TRUE
	var/uses_glasses_colour = 0

	var/list/player_alt_titles = new()

	///Whether emotes will be displayed on runechat. Requires chat_on_map to have effect. Boolean.
	var/see_rc_emotes = TRUE


	//character preferences
	var/real_name						//our character's name
	var/be_random_name = 0				//whether we'll have a random name every round
	var/be_random_body = 0				//whether we'll have a random body every round
	var/gender = MALE					//gender of character (well duh)
	var/age = 30						//age of character
	var/underwear = "Nude"				//underwear type
	var/undershirt = "Nude"				//undershirt type
	var/socks = "Nude"					//socks type
	var/backbag = DBACKPACK				//backpack type
	var/jumpsuit_style = PREF_SUIT      //suit/skirt
	var/hair_style = "Bald"				//Hair type
	var/hair_color = "000"				//Hair color
	var/facial_hair_style = "Shaved"	//Face hair type
	var/facial_hair_color = "000"		//Facial hair color
	var/skin_tone = "caucasian1"		//Skin color
	var/eye_color = "000"				//Eye color
	var/datum/species/pref_species = new /datum/species/human()	//Mutant race
	var/list/features = list("mcolor" = "FFF", "gradientstyle" = "None", "gradientcolor" = "000", "ethcolor" = "9c3030", "pretcolor" = "FFFFFF", "tail_lizard" = "Smooth", "tail_human" = "None", "snout" = "Round", "horns" = "None", "ears" = "None", "wings" = "None", "frills" = "None", "spines" = "None", "body_markings" = "None", "legs" = "Normal Legs", "moth_wings" = "Plain", "tail_polysmorph" = "Polys", "teeth" = "None", "dome" = "None", "dorsal_tubes" = "No", "ethereal_mark" = "None", "pod_hair" = "Cabbage", "pod_flower" = "Cabbage", "ipc_screen" = "Blue", "ipc_antenna" = "None", "ipc_chassis" = "Morpheus Cyberkinetics(Greyscale)","plasmaman_helmet" = "None")
	var/list/genders = list(MALE, FEMALE, PLURAL)
	var/list/friendlyGenders = list("Male" = "male", "Female" = "female", "Other" = "plural")

	var/list/random_locks = list()

	var/list/custom_names = list()
	var/preferred_ai_core_display = "Blue"
	var/prefered_security_department = SEC_DEPT_RANDOM
	var/prefered_engineering_department = ENG_DEPT_RANDOM

	//Quirk list
	var/list/all_quirks = list()

	var/mood_tail_wagging = TRUE

	//Job preferences 2.0 - indexed by job title , no key or value implies never
	var/list/job_preferences = list()

	// Want randomjob if preferences already filled - Donkie
	var/joblessrole = BERANDOMJOB  //defaults to 1 for fewer assistants

	// 0 = character settings, 1 = game preferences
	var/current_tab = 0

	var/unlock_content = 0

	var/list/ignoring = list()

	var/clientfps = 40

	var/parallax

	var/ambientocclusion = TRUE
	///Should we automatically fit the viewport?
	var/auto_fit_viewport = TRUE
	///Should we be in the widescreen mode set by the config?
	var/widescreenpref = TRUE
	///What size should pixels be displayed as? 0 is strech to fit
	var/pixel_size = 0
	///What scaling method should we use?
	var/scaling_method = "normal"

	var/uplink_spawn_loc = UPLINK_PDA

	var/skillcape = 1 /// Old skillcape value
	var/skillcape_id = "None" /// Typepath of selected skillcape, null for none

	var/map = 1
	var/flare = 1

	var/bar_choice = "Random"

	var/list/exp = list()
	var/list/menuoptions

	var/action_buttons_screen_locs = list()

	var/chat_on_map = TRUE
	var/max_chat_length = CHAT_MESSAGE_MAX_LENGTH
	var/see_chat_non_mob = TRUE
	/// If we have persistent scars enabled
	var/persistent_scars = TRUE

	var/disable_alternative_announcers = FALSE
	var/icon/background = "floor"
	var/list/background_options = list(
		"floor" = "Default Tile",
		"white" = "Default White Tile",
		"darkfull" = "Default Dark Tile",
		"wood" = "Wood",
		"rockvault" = "Rock Vault",
		"grass4" = "Grass",
		"black" = "Pure Black",
		"grey" = "Pure Grey",
		"pure_white" = "Pure White"
	)

	var/disable_balloon_alerts = FALSE



	var/list/randomise = list()

	/// The current window, PREFERENCE_TAB_* in [`code/__DEFINES/preferences.dm`]
	var/current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES

	/// A preview of the current character
	var/atom/movable/screen/character_preview_view/character_preview_view

	/// A list of instantiated middleware
	var/list/datum/preference_middleware/middleware = list()

	/// The savefile relating to core preferences, PREFERENCE_PLAYER
	var/savefile/game_savefile

	/// The savefile relating to character preferences, PREFERENCE_CHARACTER
	var/savefile/character_savefile

	/// A list of keys that have been updated since the last save.
	var/list/recently_updated_keys = list()

	/// A cache of preference entries to values.
	/// Used to avoid expensive READ_FILE every time a preference is retrieved.
	var/value_cache = list()

	/// If set to TRUE, will update character_profiles on the next ui_data tick.
	var/tainted_character_profiles = FALSE

/datum/preferences/Destroy(force, ...)
	QDEL_NULL(character_preview_view)
	QDEL_LIST(middleware)
	value_cache = null
	return ..()

/datum/preferences/New(client/C)
	parent = C

	for (var/middleware_type in subtypesof(/datum/preference_middleware))
		middleware += new middleware_type(src)

	if(istype(C))
		if(!IsGuestKey(C.key))
			load_path(C.ckey)
			unlock_content |= C.IsByondMember() // yogs - Donor features
			if(unlock_content)
				max_save_slots += 2
			// yogs start - Donor features
			if(is_donator(C) || (C.ckey in get_donators())) // the Latter handles race cases where the prefs are not fully loaded in, or GLOB.donators hasn't loaded in yet
				max_save_slots += DONOR_CHARACTER_SLOTS
			// yogs end

	// give them default keybinds and update their movement keys
	key_bindings = deepCopyList(GLOB.default_hotkeys)
	key_bindings_by_key = get_key_bindings_by_key(key_bindings)
	randomise = get_default_randomization()

	var/loaded_preferences_successfully = load_preferences()
	if(loaded_preferences_successfully)
		if(load_character())
			return
	//we couldn't load character data so just randomize the character appearance + name
	random_character()		//let's create a random character then - rather than a fat, bald and naked man.
	if(C)
		apply_all_client_preferences()
		C.set_macros()
	if(!loaded_preferences_successfully)
		save_preferences()
	save_character()		//let's save this new random character so it doesn't keep generating new ones.

/datum/preferences/ui_interact(mob/user, datum/tgui/ui)
	// If you leave and come back, re-register the character preview
	if (!isnull(character_preview_view) && !(character_preview_view in user.client?.screen))
		user.client?.register_map_obj(character_preview_view)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PreferencesMenu")
		ui.set_autoupdate(FALSE)
		ui.open()

		// HACK: Without this the character starts out really tiny because of some BYOND bug.
		// You can fix it by changing a preference, so let's just forcably update the body to emulate this.
		addtimer(CALLBACK(character_preview_view, /atom/movable/screen/character_preview_view/proc/update_body), 1 SECONDS)

/datum/preferences/ui_state(mob/user)
	return GLOB.always_state

// Without this, a hacker would be able to edit other people's preferences if
// they had the ref to Topic to.
/datum/preferences/ui_status(mob/user, datum/ui_state/state)
	return user.client == parent ? UI_INTERACTIVE : UI_CLOSE

/datum/preferences/ui_data(mob/user)
	var/list/data = list()

	if (isnull(character_preview_view))
		character_preview_view = create_character_preview_view(user)
	else if (character_preview_view.client != parent)
		// The client re-logged, and doing this when they log back in doesn't seem to properly
		// carry emissives.
		character_preview_view.register_to_client(parent)

	if (tainted_character_profiles)
		data["character_profiles"] = create_character_profiles()
		tainted_character_profiles = FALSE

	data["character_preferences"] = compile_character_preferences(user)

	data["active_slot"] = default_slot

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		data += preference_middleware.get_ui_data(user)

	return data

/datum/preferences/ui_static_data(mob/user)
	var/list/data = list()

	data["character_profiles"] = create_character_profiles()

	data["character_preview_view"] = character_preview_view.assigned_map
	data["overflow_role"] = SSjob.GetJob(SSjob.overflow_role).title
	data["window"] = current_window

	data["content_unlocked"] = unlock_content

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		data += preference_middleware.get_ui_static_data(user)

	return data

/datum/preferences/ui_assets(mob/user)
	var/list/assets = list(
		get_asset_datum(/datum/asset/spritesheet/preferences),
		get_asset_datum(/datum/asset/json/preferences),
	)

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		assets += preference_middleware.get_ui_assets()

	return assets

/datum/preferences/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	switch (action)
		if ("change_slot")
			// Save existing character
			save_character()

			// SAFETY: `load_character` performs sanitization the slot number
			if (!load_character(params["slot"]))
				tainted_character_profiles = TRUE
				randomise_appearance_prefs()
				save_character()

			for (var/datum/preference_middleware/preference_middleware as anything in middleware)
				preference_middleware.on_new_character(usr)

			character_preview_view.update_body()

			return TRUE
		if ("rotate")
			character_preview_view.dir = turn(character_preview_view.dir, -90)

			return TRUE
		if ("set_preference")
			var/requested_preference_key = params["preference"]
			var/value = params["value"]

			for (var/datum/preference_middleware/preference_middleware as anything in middleware)
				if (preference_middleware.pre_set_preference(usr, requested_preference_key, value))
					return TRUE

			var/datum/preference/requested_preference = GLOB.preference_entries_by_key[requested_preference_key]
			if (isnull(requested_preference))
				return FALSE

			// SAFETY: `update_preference` performs validation checks
			if (!update_preference(requested_preference, value))
				return FALSE

			if (istype(requested_preference, /datum/preference/name))
				tainted_character_profiles = TRUE

			return TRUE
		if ("set_color_preference")
			var/requested_preference_key = params["preference"]

			var/datum/preference/requested_preference = GLOB.preference_entries_by_key[requested_preference_key]
			if (isnull(requested_preference))
				return FALSE

			if (!istype(requested_preference, /datum/preference/color) \
				&& !istype(requested_preference, /datum/preference/color_legacy) \
			)
				return FALSE

			var/default_value = read_preference(requested_preference.type)
			if (istype(requested_preference, /datum/preference/color_legacy))
				default_value = expand_three_digit_color(default_value)

			// Yielding
			var/new_color = input(
				usr,
				"Select new color",
				null,
				default_value || COLOR_WHITE,
			) as color | null

			if (!new_color)
				return FALSE

			if (!update_preference(requested_preference, new_color))
				return FALSE

			return TRUE

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		var/delegation = preference_middleware.action_delegations[action]
		if (!isnull(delegation))
			return call(preference_middleware, delegation)(params, usr)

	return FALSE

/datum/preferences/ui_close(mob/user)
	save_character()
	save_preferences()
	QDEL_NULL(character_preview_view)

/datum/preferences/Topic(href, list/href_list)
	. = ..()
	if (.)
		return

	if (href_list["open_keybindings"])
		current_window = PREFERENCE_TAB_KEYBINDINGS
		update_static_data(usr)
		ui_interact(usr)
		return TRUE

/datum/preferences/Topic(href, list/href_list)
	. = ..()
	if (.)
		return

	if (href_list["open_keybindings"])
		current_window = PREFERENCE_TAB_KEYBINDINGS
		update_static_data(usr)
		ui_interact(usr)
		return TRUE

/datum/preferences/proc/create_character_preview_view(mob/user)
	character_preview_view = new(null, src, user.client)
	character_preview_view.update_body()
	character_preview_view.register_to_client(user.client)

	return character_preview_view

/datum/preferences/proc/compile_character_preferences(mob/user)
	var/list/preferences = list()

	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (!preference.is_accessible(src))
			continue

		LAZYINITLIST(preferences[preference.category])

		var/value = read_preference(preference.type)
		var/data = preference.compile_ui_data(user, value)

		preferences[preference.category][preference.savefile_key] = data

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		var/list/append_character_preferences = preference_middleware.get_character_preferences(user)
		if (isnull(append_character_preferences))
			continue

		for (var/category in append_character_preferences)
			if (category in preferences)
				preferences[category] += append_character_preferences[category]
			else
				preferences[category] = append_character_preferences[category]

	return preferences

/// Applies all PREFERENCE_PLAYER preferences
/datum/preferences/proc/apply_all_client_preferences()
	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (preference.savefile_identifier != PREFERENCE_PLAYER)
			continue

		value_cache -= preference.type
		preference.apply_to_client(parent, read_preference(preference.type))

// This is necessary because you can open the set preferences menu before
// the atoms SS is done loading.
INITIALIZE_IMMEDIATE(/atom/movable/screen/character_preview_view)

/// A preview of a character for use in the preferences menu
/atom/movable/screen/character_preview_view
	name = "character_preview"
	del_on_map_removal = FALSE
	layer = GAME_PLANE
	plane = GAME_PLANE

	/// The body that is displayed
	var/mob/living/carbon/human/dummy/body

	/// The preferences this refers to
	var/datum/preferences/preferences

	var/list/plane_masters = list()

	/// The client that is watching this view
	var/client/client

/atom/movable/screen/character_preview_view/Initialize(mapload, datum/preferences/preferences, client/client)
	. = ..()

	assigned_map = "character_preview_[REF(src)]"
	set_position(1, 1)

	src.preferences = preferences

/atom/movable/screen/character_preview_view/Destroy()
	QDEL_NULL(body)

	for (var/plane_master in plane_masters)
		client?.screen -= plane_master
		qdel(plane_master)

	client?.clear_map(assigned_map)
	client?.screen -= src

	preferences?.character_preview_view = null

	client = null
	plane_masters = null
	preferences = null

	return ..()

/// Updates the currently displayed body
/atom/movable/screen/character_preview_view/proc/update_body()
	if (isnull(body))
		create_body()
	else
		body.wipe_state()
	appearance = preferences.render_new_preview_appearance(body)

/atom/movable/screen/character_preview_view/proc/create_body()
	QDEL_NULL(body)

	body = new

	// Without this, it doesn't show up in the menu
	body.appearance_flags &= ~KEEP_TOGETHER

/// Registers the relevant map objects to a client
/atom/movable/screen/character_preview_view/proc/register_to_client(client/client)
	QDEL_LIST(plane_masters)

	src.client = client

	if (!client)
		return

	for (var/plane_master_type in subtypesof(/atom/movable/screen/plane_master))
		var/atom/movable/screen/plane_master/plane_master = new plane_master_type
		plane_master.screen_loc = "[assigned_map]:CENTER"
		client?.screen |= plane_master

		plane_masters += plane_master

	client?.register_map_obj(src)

/datum/preferences/proc/create_character_profiles()
	var/list/profiles = list()

	var/savefile/savefile = new(path)
	for (var/index in 1 to max_save_slots)
		// It won't be updated in the savefile yet, so just read the name directly
		if (index == default_slot)
			profiles += read_preference(/datum/preference/name/real_name)
			continue

		savefile.cd = "/character[index]"

		var/name
		READ_FILE(savefile["real_name"], name)

		if (isnull(name))
			profiles += null
			continue

		profiles += name

	return profiles

/// Returns the default `randomise` variable ouptut
/datum/preferences/proc/get_default_randomization()
	var/list/default_randomization = list()

	for (var/preference_key in GLOB.preference_entries_by_key)
		var/datum/preference/preference = GLOB.preference_entries_by_key[preference_key]
		if (preference.is_randomizable() && preference.randomize_by_default)
			default_randomization[preference_key] = RANDOM_ENABLED

	return default_randomization

/// Inverts the key_bindings list such that it can be used for key_bindings_by_key
/datum/preferences/proc/get_key_bindings_by_key(list/key_bindings)
	var/list/output = list()

	for (var/action in key_bindings)
		for (var/key in key_bindings[action])
			LAZYADD(output[key], action)



/datum/preferences/proc/GetPlayerAltTitle(datum/job/job)
	return player_alt_titles.Find(job.title) > 0 \
		? player_alt_titles[job.title] \
		: job.title

/datum/preferences/proc/SetPlayerAltTitle(datum/job/job, new_title)
	// remove existing entry
	if(player_alt_titles.Find(job.title))
		player_alt_titles -= job.title
	// add one if it's not default
	if(job.title != new_title)
		player_alt_titles[job.title] = new_title

/datum/preferences/proc/set_job_preference_level(datum/job/job, level)
	if (!job)
		return FALSE

	if (level == JP_HIGH)
		var/datum/job/overflow_role = SSjob.overflow_role
		var/overflow_role_title = initial(overflow_role.title)

		for(var/other_job in job_preferences)
			if(job_preferences[other_job] == JP_HIGH)
				// Overflow role needs to go to NEVER, not medium!
				if(other_job == overflow_role_title)
					job_preferences[other_job] = null
				else
					job_preferences[other_job] = JP_MEDIUM

	if(level == null)
		job_preferences -= job.title
	else
		job_preferences[job.title] = level

	return TRUE

/datum/preferences/proc/GetQuirkBalance()
	var/bal = 0
	for(var/V in all_quirks)
		var/datum/quirk/T = SSquirks.quirks[V]
		bal -= initial(T.value)
	return bal

/datum/preferences/proc/GetPositiveQuirkCount()
	var/sum = 0
	for(var/q in all_quirks)
		if(SSquirks.quirk_points[q] > 0)
			sum++
	return sum

/datum/preferences/proc/copy_to(mob/living/carbon/human/character, icon_updates = 1, roundstart_checks = TRUE)
	if(be_random_name)
		real_name = pref_species.random_name(gender)

	if(be_random_body)
		random_character(gender)

	if(roundstart_checks)
		if(CONFIG_GET(flag/humans_need_surnames) && (pref_species.id == "human"))
			var/firstspace = findtext(real_name, " ")
			var/name_length = length(real_name)
			if(!firstspace)	//we need a surname
				real_name += " [pick(GLOB.last_names)]"
			else if(firstspace == name_length)
				real_name += "[pick(GLOB.last_names)]"

	character.real_name = real_name
	character.name = character.real_name

	character.gender = gender
	character.age = age

	character.eye_color = eye_color
	var/obj/item/organ/eyes/organ_eyes = character.getorgan(/obj/item/organ/eyes)
	if(organ_eyes)
		if(!initial(organ_eyes.eye_color))
			organ_eyes.eye_color = eye_color
		organ_eyes.old_eye_color = eye_color
	character.hair_color = hair_color
	character.facial_hair_color = facial_hair_color
	character.grad_color = features["gradientcolor"]

	character.skin_tone = skin_tone
	character.hair_style = hair_style
	character.facial_hair_style = facial_hair_style
	character.grad_style = features["gradientstyle"]
	character.underwear = underwear
	character.undershirt = undershirt
	character.socks = socks

	character.backbag = backbag

	character.jumpsuit_style = jumpsuit_style

	var/datum/species/chosen_species
	chosen_species = pref_species.type
	if(roundstart_checks && !(pref_species.id in GLOB.roundstart_races) &&  (!(pref_species.id in GLOB.mentor_races) && !is_mentor(character))  && !(pref_species.id in (CONFIG_GET(keyed_list/roundstart_no_hard_check))))
		chosen_species = /datum/species/human
		pref_species = new /datum/species/human
		save_character()

	character.dna.features = features.Copy()
	character.set_species(chosen_species, icon_update = FALSE, pref_load = TRUE)
	character.dna.real_name = character.real_name

	if("tail_lizard" in pref_species.default_features)
		character.dna.species.mutant_bodyparts |= "tail_lizard"

	if("tail_polysmorph" in pref_species.default_features)
		character.dna.species.mutant_bodyparts |= "tail_polysmorph"

	if(icon_updates)
		character.icon_render_key = null //turns out if you don't set this to null update_body_parts does nothing, since it assumes the operation was cached
		character.update_body()
		character.update_hair()
		character.update_body_parts()
