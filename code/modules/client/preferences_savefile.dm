//This is the lowest supported version, anything below this is completely obsolete and the entire savefile will be wiped.
#define SAVEFILE_VERSION_MIN	18

//This is the current version, anything below this will attempt to update (if it's not obsolete)
//	You do not need to raise this if you are adding new values that have sane defaults.
//	Only raise this value when changing the meaning/format/name/layout of an existing value
//	where you would want the updater procs below to run
#define SAVEFILE_VERSION_MAX	39

/*
SAVEFILE UPDATING/VERSIONING - 'Simplified', or rather, more coder-friendly ~Carn
	This proc checks if the current directory of the savefile S needs updating
	It is to be used by the load_character and load_preferences procs.
	(S.cd=="/" is preferences, S.cd=="/character[integer]" is a character slot, etc)

	if the current directory's version is below SAVEFILE_VERSION_MIN it will simply wipe everything in that directory
	(if we're at root "/" then it'll just wipe the entire savefile, for instance.)

	if its version is below SAVEFILE_VERSION_MAX but above the minimum, it will load data but later call the
	respective update_preferences() or update_character() proc.
	Those procs allow coders to specify format changes so users do not lose their setups and have to redo them again.

	Failing all that, the standard sanity checks are performed. They simply check the data is suitable, reverting to
	initial() values if necessary.
*/
/datum/preferences/proc/savefile_needs_update(savefile/S)
	var/savefile_version
	READ_FILE(S["version"], savefile_version)

	if(savefile_version < SAVEFILE_VERSION_MIN)
		S.dir.Cut()
		return -2
	if(savefile_version < SAVEFILE_VERSION_MAX)
		return savefile_version
	return -1

//should these procs get fairly long
//just increase SAVEFILE_VERSION_MIN so it's not as far behind
//SAVEFILE_VERSION_MAX and then delete any obsolete if clauses
//from these procs.
//This only really meant to avoid annoying frequent players
//if your savefile is 3 months out of date, then 'tough shit'.

/datum/preferences/proc/update_preferences(current_version, savefile/S)
	// Fixes savefile corruption caused by https://github.com/yogstation13/Yogstation/pull/9767
	if(current_version < 25) // This is the only thing that makes V25 different.
		if(LAZYFIND(be_special,"Ragin"))
			be_special -= "Ragin"
			be_special += "Ragin Mages"
	if (current_version < 35)
		toggles |= SOUND_ALT
	if (current_version < 37)
		chat_toggles |= CHAT_TYPING_INDICATOR
	return

/datum/preferences/proc/update_character(current_version, savefile/S)
	if(current_version < 19)
		pda_style = "mono"
	if(current_version < 20)
		pda_color = "#808000"
	if((current_version < 21) && features["ethcolor"] && (features["ethcolor"] == "#9c3030"))
		features["ethcolor"] = "#9c3030"
	if(current_version < 22)
		job_preferences = list() //It loaded null from nonexistant savefile field.
		var/job_civilian_high = 0
		var/job_civilian_med = 0
		var/job_civilian_low = 0

		var/job_medsci_high = 0
		var/job_medsci_med = 0
		var/job_medsci_low = 0

		var/job_engsec_high = 0
		var/job_engsec_med = 0
		var/job_engsec_low = 0

		READ_FILE(S["job_civilian_high"], job_civilian_high)
		READ_FILE(S["job_civilian_med"], job_civilian_med)
		READ_FILE(S["job_civilian_low"], job_civilian_low)
		READ_FILE(S["job_medsci_high"], job_medsci_high)
		READ_FILE(S["job_medsci_med"], job_medsci_med)
		READ_FILE(S["job_medsci_low"], job_medsci_low)
		READ_FILE(S["job_engsec_high"], job_engsec_high)
		READ_FILE(S["job_engsec_med"], job_engsec_med)
		READ_FILE(S["job_engsec_low"], job_engsec_low)

		//Can't use SSjob here since this happens right away on login
		for(var/job in subtypesof(/datum/job))
			var/datum/job/J = job
			var/new_value
			var/fval = initial(J.flag)
			switch(initial(J.department_flag))
				if(CIVILIAN)
					if(job_civilian_high & fval)
						new_value = JP_HIGH
					else if(job_civilian_med & fval)
						new_value = JP_MEDIUM
					else if(job_civilian_low & fval)
						new_value = JP_LOW
				if(MEDSCI)
					if(job_medsci_high & fval)
						new_value = JP_HIGH
					else if(job_medsci_med & fval)
						new_value = JP_MEDIUM
					else if(job_medsci_low & fval)
						new_value = JP_LOW
				if(ENGSEC)
					if(job_engsec_high & fval)
						new_value = JP_HIGH
					else if(job_engsec_med & fval)
						new_value = JP_MEDIUM
					else if(job_engsec_low & fval)
						new_value = JP_LOW
			if(new_value)
				job_preferences[initial(J.title)] = new_value
	if(current_version < 23)
		all_quirks -= "Physically Obstructive"
		all_quirks -= "Neat"
		all_quirks -= "NEET"
	if(current_version < 26) //The new donator hats system obsolesces the old one entirely, we need to update.
		donor_hat = null
		donor_item = null
	if(current_version < 27)
		map = TRUE
		flare = TRUE
	if(current_version < 28)
		if(!job_preferences)
			job_preferences = list()
	if(current_version < 29)
		purrbation = FALSE
	if(current_version < 30) //Someone doesn't know how to code and make savefiles get corrupted
		if(!ispath(donor_hat))
			donor_hat = null
		if(!ispath(donor_item))
			donor_item = null
	if(current_version < 31) //Someone doesn't know how to code and make jukebox and autodeadmin the same thing
		toggles &= ~DEADMIN_ALWAYS
		toggles &= ~DEADMIN_ANTAGONIST
		toggles &= ~DEADMIN_POSITION_HEAD
		toggles &= ~DEADMIN_POSITION_SECURITY
		toggles &= ~DEADMIN_POSITION_SILICON //This last one is technically a no-op but it looks cleaner and less like someone forgot
	if(current_version < 32) // Changed skillcape storage
		if(skillcape != 1)
			var/path = subtypesof(/datum/skillcape)[skillcape]
			var/datum/skillcape/cape = new path()
			skillcape_id = cape.id
			qdel(cape)
	if(current_version < 33) //Reset map preference to no choice
		if(preferred_map)
			to_chat(parent, span_userdanger("Your preferred map has been reset to nothing. Please set it to the map you wish to play on."))
		preferred_map = null
	if(current_version < 34) // default to on
		toggles |= SOUND_VOX
	if(current_version < 39)
		save_character()
		to_chat(parent, span_userdanger(span_big("Color code has been reworked. Check all your character preferences, especially colors, before playing.")))

/datum/preferences/proc/load_path(ckey,filename="preferences.sav")
	if(!ckey)
		return
	path = "data/player_saves/[ckey[1]]/[ckey]/[filename]"

/datum/preferences/proc/load_preferences()
	if(!path)
		return FALSE
	if(!fexists(path))
		return FALSE

	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/"

	var/needs_update = savefile_needs_update(S)
	if(needs_update == -2)		//fatal, can't load any data
		return FALSE

	//general preferences
	READ_FILE(S["asaycolor"], asaycolor)
	READ_FILE(S["ooccolor"], ooccolor)
	READ_FILE(S["lastchangelog"], lastchangelog)
	READ_FILE(S["UI_style"], UI_style)
	READ_FILE(S["hotkeys"], hotkeys)
	READ_FILE(S["chat_on_map"], chat_on_map)
	READ_FILE(S["max_chat_length"], max_chat_length)
	READ_FILE(S["see_chat_non_mob"] , see_chat_non_mob)
	READ_FILE(S["see_rc_emotes"] , see_rc_emotes)
	READ_FILE(S["tgui_fancy"], tgui_fancy)
	READ_FILE(S["tgui_lock"], tgui_lock)
	READ_FILE(S["buttons_locked"], buttons_locked)
	READ_FILE(S["windowflash"], windowflashing)
	READ_FILE(S["be_special"] , be_special)
	READ_FILE(S["player_alt_titles"], player_alt_titles)

	READ_FILE(S["default_slot"], default_slot)
	READ_FILE(S["chat_toggles"], chat_toggles)
	READ_FILE(S["toggles"], toggles)
	READ_FILE(S["ghost_form"], ghost_form)
	READ_FILE(S["ghost_orbit"], ghost_orbit)
	READ_FILE(S["ghost_accs"], ghost_accs)
	READ_FILE(S["ghost_others"], ghost_others)
	READ_FILE(S["preferred_map"], preferred_map)
	READ_FILE(S["ignoring"], ignoring)
	READ_FILE(S["ghost_hud"], ghost_hud)
	READ_FILE(S["inquisitive_ghost"], inquisitive_ghost)
	READ_FILE(S["uses_glasses_colour"], uses_glasses_colour)
	READ_FILE(S["clientfps"], clientfps)
	READ_FILE(S["parallax"], parallax)
	READ_FILE(S["ambientocclusion"], ambientocclusion)
	READ_FILE(S["auto_fit_viewport"], auto_fit_viewport)
	READ_FILE(S["widescreenpref"], widescreenpref)
	READ_FILE(S["pixel_size"], pixel_size)
	READ_FILE(S["scaling_method"], scaling_method)
	READ_FILE(S["menuoptions"], menuoptions)
	READ_FILE(S["enable_tips"], enable_tips)
	READ_FILE(S["tip_delay"], tip_delay)
	READ_FILE(S["pda_style"], pda_style)
	READ_FILE(S["pda_color"], pda_color)
	READ_FILE(S["id_in_pda"], id_in_pda)

	READ_FILE(S["skillcape"], skillcape)
	READ_FILE(S["skillcape_id"], skillcape_id)
	READ_FILE(S["map"], map)
	READ_FILE(S["flare"], flare)
	READ_FILE(S["bar_choice"], bar_choice)
	READ_FILE(S["show_credits"], show_credits)
	READ_FILE(S["alternative_announcers"] , disable_alternative_announcers)
	
	// yogs start - Donor features
	READ_FILE(S["donor_pda"], donor_pda)
	READ_FILE(S["donor_hat"], donor_hat)
	READ_FILE(S["borg_hat"], borg_hat)
	READ_FILE(S["donor_item"], donor_item)
	READ_FILE(S["purrbation"], purrbation)
	READ_FILE(S["yogtoggles"], yogtoggles)

	READ_FILE(S["accent"], accent) // Accents, too!

	READ_FILE(S["mood_tail_wagging"], mood_tail_wagging)
	// yogs end

	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_preferences(needs_update, S)		//needs_update = savefile_version if we need an update (positive integer)

	//Sanitize
	asaycolor			= sanitize_ooccolor(sanitize_hexcolor(asaycolor, DEFAULT_HEX_COLOR_LEN, FALSE, initial(asaycolor)))
	ooccolor			= sanitize_ooccolor(sanitize_hexcolor(ooccolor, DEFAULT_HEX_COLOR_LEN, FALSE, initial(ooccolor)))
	lastchangelog		= sanitize_text(lastchangelog, initial(lastchangelog))
	UI_style			= sanitize_inlist(UI_style, GLOB.available_ui_styles, GLOB.available_ui_styles[1])
	hotkeys				= sanitize_integer(hotkeys, FALSE, TRUE, initial(hotkeys))
	chat_on_map			= sanitize_integer(chat_on_map, FALSE, TRUE, initial(chat_on_map))
	max_chat_length 	= sanitize_integer(max_chat_length, 1, CHAT_MESSAGE_MAX_LENGTH, initial(max_chat_length))	
	see_chat_non_mob	= sanitize_integer(see_chat_non_mob, FALSE, TRUE, initial(see_chat_non_mob))
	see_rc_emotes		= sanitize_integer(see_rc_emotes, FALSE, TRUE, initial(see_rc_emotes))
	tgui_fancy			= sanitize_integer(tgui_fancy, FALSE, TRUE, initial(tgui_fancy))
	tgui_lock			= sanitize_integer(tgui_lock, FALSE, TRUE, initial(tgui_lock))
	buttons_locked		= sanitize_integer(buttons_locked, FALSE, TRUE, initial(buttons_locked))
	windowflashing		= sanitize_integer(windowflashing, FALSE, TRUE, initial(windowflashing))
	default_slot		= sanitize_integer(default_slot, 1, max_save_slots, initial(default_slot))
	toggles				= sanitize_integer(toggles, 0, ~0, initial(toggles)) // Yogs -- Fixes toggles not having >16 bits of flagspace
	clientfps			= sanitize_integer(clientfps, 0, 1000, 0)
	parallax			= sanitize_integer(parallax, PARALLAX_INSANE, PARALLAX_DISABLE, null)
	ambientocclusion	= sanitize_integer(ambientocclusion, FALSE, TRUE, initial(ambientocclusion))
	auto_fit_viewport	= sanitize_integer(auto_fit_viewport, FALSE, TRUE, initial(auto_fit_viewport))
	widescreenpref  	= sanitize_integer(widescreenpref, FALSE, TRUE, initial(widescreenpref))
	pixel_size			= sanitize_integer(pixel_size, PIXEL_SCALING_AUTO, PIXEL_SCALING_3X, initial(pixel_size))
	scaling_method  	= sanitize_text(scaling_method, initial(scaling_method))
	ghost_form			= sanitize_inlist(ghost_form, GLOB.ghost_forms, initial(ghost_form))
	ghost_orbit 		= sanitize_inlist(ghost_orbit, GLOB.ghost_orbits, initial(ghost_orbit))
	ghost_accs			= sanitize_inlist(ghost_accs, GLOB.ghost_accs_options, GHOST_ACCS_DEFAULT_OPTION)
	ghost_others		= sanitize_inlist(ghost_others, GLOB.ghost_others_options, GHOST_OTHERS_DEFAULT_OPTION)
	menuoptions			= SANITIZE_LIST(menuoptions)
	be_special			= SANITIZE_LIST(be_special)
	pda_style			= sanitize_inlist(pda_style, GLOB.pda_styles, initial(pda_style))
	pda_color			= sanitize_hexcolor(pda_color, DEFAULT_HEX_COLOR_LEN, FALSE, initial(pda_color))
	skillcape       	= sanitize_integer(skillcape, 1, 82, initial(skillcape))
	skillcape_id		= sanitize_text(skillcape_id, initial(skillcape_id))

	if(skillcape_id != "None" && !(skillcape_id in GLOB.skillcapes))
		skillcape_id = "None"

	map					= sanitize_integer(map, FALSE, TRUE, initial(map))
	flare				= sanitize_integer(flare, FALSE, TRUE, initial(flare))
	bar_choice			= sanitize_text(bar_choice, initial(bar_choice))
	disable_alternative_announcers	= sanitize_integer(disable_alternative_announcers, FALSE, TRUE, initial(disable_alternative_announcers))

	var/bar_sanitize = FALSE
	for(var/A in GLOB.potential_box_bars)
		if(bar_choice == A)
			bar_sanitize = TRUE
			break
	if(!bar_sanitize)
		bar_choice = "Random"
	if(!player_alt_titles) player_alt_titles = new()
	show_credits	= sanitize_integer(show_credits, FALSE, TRUE, initial(show_credits))

	// yogs start - Donor features & yogtoggles
	yogtoggles		= sanitize_integer(yogtoggles, 0, (1 << 23), initial(yogtoggles))
	donor_pda		= sanitize_integer(donor_pda, 1, GLOB.donor_pdas.len, 1)
	purrbation      = sanitize_integer(purrbation, FALSE, TRUE, initial(purrbation))

	accent			= sanitize_text(accent, initial(accent)) // Can't use sanitize_inlist since it doesn't support falsely default values.
	// yogs end

	load_keybindings(S) // yogs - Custom keybindings

	return TRUE

/datum/preferences/proc/save_preferences()
	if(!path)
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/"

	WRITE_FILE(S["version"] , SAVEFILE_VERSION_MAX)		//updates (or failing that the sanity checks) will ensure data is not invalid at load. Assume up-to-date

	//general preferences
	WRITE_FILE(S["asaycolor"], asaycolor)
	WRITE_FILE(S["ooccolor"], ooccolor)
	WRITE_FILE(S["lastchangelog"], lastchangelog)
	WRITE_FILE(S["UI_style"], UI_style)
	WRITE_FILE(S["hotkeys"], hotkeys)
	WRITE_FILE(S["chat_on_map"], chat_on_map)
	WRITE_FILE(S["max_chat_length"], max_chat_length)
	WRITE_FILE(S["see_chat_non_mob"], see_chat_non_mob)
	WRITE_FILE(S["see_rc_emotes"], see_rc_emotes)
	WRITE_FILE(S["tgui_fancy"], tgui_fancy)
	WRITE_FILE(S["tgui_lock"], tgui_lock)
	WRITE_FILE(S["buttons_locked"], buttons_locked)
	WRITE_FILE(S["windowflash"], windowflashing)
	WRITE_FILE(S["be_special"], be_special)
	WRITE_FILE(S["player_alt_titles"], player_alt_titles)
	WRITE_FILE(S["default_slot"], default_slot)
	WRITE_FILE(S["toggles"], toggles)
	WRITE_FILE(S["chat_toggles"], chat_toggles)
	WRITE_FILE(S["ghost_form"], ghost_form)
	WRITE_FILE(S["ghost_orbit"], ghost_orbit)
	WRITE_FILE(S["ghost_accs"], ghost_accs)
	WRITE_FILE(S["ghost_others"], ghost_others)
	WRITE_FILE(S["preferred_map"], preferred_map)
	WRITE_FILE(S["ignoring"], ignoring)
	WRITE_FILE(S["ghost_hud"], ghost_hud)
	WRITE_FILE(S["inquisitive_ghost"], inquisitive_ghost)
	WRITE_FILE(S["uses_glasses_colour"], uses_glasses_colour)
	WRITE_FILE(S["clientfps"], clientfps)
	WRITE_FILE(S["parallax"], parallax)
	WRITE_FILE(S["ambientocclusion"], ambientocclusion)
	WRITE_FILE(S["auto_fit_viewport"], auto_fit_viewport)
	WRITE_FILE(S["widescreenpref"], widescreenpref)
	WRITE_FILE(S["pixel_size"], pixel_size)
	WRITE_FILE(S["scaling_method"], scaling_method)
	WRITE_FILE(S["menuoptions"], menuoptions)
	WRITE_FILE(S["enable_tips"], enable_tips)
	WRITE_FILE(S["tip_delay"], tip_delay)
	WRITE_FILE(S["pda_style"], pda_style)
	WRITE_FILE(S["pda_color"], pda_color)
	WRITE_FILE(S["id_in_pda"], id_in_pda)
	WRITE_FILE(S["skillcape"], skillcape)
	WRITE_FILE(S["skillcape_id"], skillcape_id)
	WRITE_FILE(S["show_credits"], show_credits)
	WRITE_FILE(S["map"], map)
	WRITE_FILE(S["flare"], flare)
	WRITE_FILE(S["bar_choice"], bar_choice)
	WRITE_FILE(S["alternative_announcers"], disable_alternative_announcers)

	// yogs start - Donor features & Yogstoggle
	WRITE_FILE(S["yogtoggles"], yogtoggles)
	WRITE_FILE(S["donor_pda"], donor_pda)
	WRITE_FILE(S["donor_hat"], donor_hat)
	WRITE_FILE(S["borg_hat"], borg_hat)
	WRITE_FILE(S["donor_item"], donor_item)
	WRITE_FILE(S["purrbation"], purrbation)

	WRITE_FILE(S["accent"], accent) // Accents, too!
	
	WRITE_FILE(S["mood_tail_wagging"], mood_tail_wagging)
	// yogs end

	save_keybindings(S) // yogs - Custom keybindings

	return TRUE

/datum/preferences/proc/load_character(slot)
	if(!path)
		return FALSE
	if(!fexists(path))
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/"
	if(!slot)
		slot = default_slot
	slot = sanitize_integer(slot, 1, max_save_slots, initial(default_slot))
	if(slot != default_slot)
		default_slot = slot
		WRITE_FILE(S["default_slot"] , slot)

	S.cd = "/character[slot]"
	var/needs_update = savefile_needs_update(S)
	if(needs_update == -2)		//fatal, can't load any data
		return FALSE

	//Species
	var/species_id
	READ_FILE(S["species"], species_id)
	if(species_id)
		var/newtype = GLOB.species_list[species_id]
		if(newtype)
			pref_species = new newtype

	if(!S["feature_mcolor"] || S["feature_mcolor"] == "#000000")//|| !findtext(S["feature_mcolor"],"#")
		WRITE_FILE(S["feature_mcolor"]	, "#FFFF77")

	if(!S["feature_ethcolor"] || S["feature_ethcolor"] == "#000000")//|| !findtext(S["feature_ethcolor"],"#")
		WRITE_FILE(S["feature_ethcolor"]	, "#9C3030")

	//Character
	READ_FILE(S["real_name"], real_name)
	READ_FILE(S["name_is_always_random"], be_random_name)
	READ_FILE(S["body_is_always_random"], be_random_body)
	READ_FILE(S["gender"], gender)
	READ_FILE(S["age"], age)
	READ_FILE(S["hair_color"], hair_color)
	READ_FILE(S["facial_hair_color"], facial_hair_color)
	READ_FILE(S["eye_color"], eye_color)
	READ_FILE(S["skin_tone"], skin_tone)
	READ_FILE(S["hair_style_name"], hair_style)
	READ_FILE(S["facial_style_name"], facial_hair_style)
	READ_FILE(S["underwear"], underwear)
	READ_FILE(S["undershirt"], undershirt)
	READ_FILE(S["socks"], socks)
	READ_FILE(S["backbag"], backbag)
	READ_FILE(S["jumpsuit_style"], jumpsuit_style)
	READ_FILE(S["uplink_loc"], uplink_spawn_loc)
	READ_FILE(S["feature_mcolor"], features["mcolor"])
	READ_FILE(S["feature_gradientstyle"], features["gradientstyle"])
	READ_FILE(S["feature_gradientcolor"], features["gradientcolor"])
	READ_FILE(S["feature_ethcolor"], features["ethcolor"])
	READ_FILE(S["feature_lizard_tail"], features["tail_lizard"])
	READ_FILE(S["feature_lizard_snout"], features["snout"])
	READ_FILE(S["feature_lizard_horns"], features["horns"])
	READ_FILE(S["feature_lizard_frills"], features["frills"])
	READ_FILE(S["feature_lizard_spines"], features["spines"])
	READ_FILE(S["feature_lizard_body_markings"], features["body_markings"])
	READ_FILE(S["feature_lizard_legs"], features["legs"])
	READ_FILE(S["feature_moth_wings"], features["moth_wings"])
	READ_FILE(S["feature_polysmorph_tail"], features["tail_polysmorph"])
	READ_FILE(S["feature_polysmorph_teeth"], features["teeth"])
	READ_FILE(S["feature_polysmorph_dome"], features["dome"])
	READ_FILE(S["feature_polysmorph_dorsal_tubes"], features["dorsal_tubes"])
	READ_FILE(S["feature_ethereal_mark"], features["ethereal_mark"])
	READ_FILE(S["feature_pod_hair"], features["pod_hair"])
	READ_FILE(S["feature_pod_flower"], features["pod_flower"])
	READ_FILE(S["feature_ipc_screen"], features["ipc_screen"])
	READ_FILE(S["feature_ipc_antenna"], features["ipc_antenna"])
	READ_FILE(S["feature_ipc_chassis"], features["ipc_chassis"])

	READ_FILE(S["persistent_scars"], persistent_scars)
	if(!CONFIG_GET(flag/join_with_mutant_humans))
		features["tail_human"] = "none"
		features["ears"] = "none"
	else
		READ_FILE(S["feature_human_tail"], features["tail_human"])
		READ_FILE(S["feature_human_ears"], features["ears"])

	//Custom names
	for(var/custom_name_id in GLOB.preferences_custom_names)
		var/savefile_slot_name = custom_name_id + "_name" //TODO remove this
		READ_FILE(S[savefile_slot_name], custom_names[custom_name_id])

	READ_FILE(S["preferred_ai_core_display"], preferred_ai_core_display)
	READ_FILE(S["prefered_security_department"], prefered_security_department)
	READ_FILE(S["prefered_engineering_department"], prefered_engineering_department)

	//Jobs
	READ_FILE(S["joblessrole"], joblessrole)
	//Load prefs

	READ_FILE(S["job_preferences"], job_preferences)

	if(!job_preferences)
		job_preferences = list()

	//Quirks
	READ_FILE(S["all_quirks"], all_quirks)

	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_character(needs_update, S)		//needs_update == savefile_version if we need an update (positive integer)

	//Sanitize

	real_name = reject_bad_name(real_name, pref_species.allow_numbers_in_name)
	gender = sanitize_gender(gender)
	if(!real_name)
		real_name = random_unique_name(gender)

	for(var/custom_name_id in GLOB.preferences_custom_names)
		var/namedata = GLOB.preferences_custom_names[custom_name_id]
		custom_names[custom_name_id] = reject_bad_name(custom_names[custom_name_id],namedata["allow_numbers"])
		if(!custom_names[custom_name_id])
			custom_names[custom_name_id] = get_default_name(custom_name_id)

	if(!features["mcolor"] || features["mcolor"] == "#000000")
		features["mcolor"] = "#[pick("7F","FF")][pick("7F","FF")][pick("7F","FF")]"

	if(!features["ethcolor"] || features["ethcolor"] == "#000000")
		features["ethcolor"] = GLOB.color_list_ethereal[pick(GLOB.color_list_ethereal)]

	be_random_name	= sanitize_integer(be_random_name, 0, 1, initial(be_random_name))
	be_random_body	= sanitize_integer(be_random_body, 0, 1, initial(be_random_body))

	if(gender == MALE)
		hair_style			= sanitize_inlist(hair_style, GLOB.hair_styles_male_list)
		facial_hair_style			= sanitize_inlist(facial_hair_style, GLOB.facial_hair_styles_male_list)
		underwear		= sanitize_inlist(underwear, GLOB.underwear_m)
		undershirt 		= sanitize_inlist(undershirt, GLOB.undershirt_m)
	else if(gender == FEMALE)
		hair_style			= sanitize_inlist(hair_style, GLOB.hair_styles_female_list)
		facial_hair_style			= sanitize_inlist(facial_hair_style, GLOB.facial_hair_styles_female_list)
		underwear		= sanitize_inlist(underwear, GLOB.underwear_f)
		undershirt		= sanitize_inlist(undershirt, GLOB.undershirt_f)
	else
		hair_style			= sanitize_inlist(hair_style, GLOB.hair_styles_list)
		facial_hair_style			= sanitize_inlist(facial_hair_style, GLOB.facial_hair_styles_list)
		underwear		= sanitize_inlist(underwear, GLOB.underwear_list)
		undershirt 		= sanitize_inlist(undershirt, GLOB.undershirt_list)


	socks			= sanitize_inlist(socks, GLOB.socks_list)
	age				= sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	hair_color			= sanitize_hexcolor(hair_color, default = FALSE)
	facial_hair_color			= sanitize_hexcolor(facial_hair_color, default = FALSE)
	eye_color		= sanitize_hexcolor(eye_color, default = FALSE)
	skin_tone		= sanitize_inlist(skin_tone, GLOB.skin_tones)
	backbag			= sanitize_inlist(backbag, GLOB.backbaglist, initial(backbag))
	jumpsuit_style	= sanitize_inlist(jumpsuit_style, GLOB.jumpsuitlist, initial(jumpsuit_style))
	uplink_spawn_loc = sanitize_inlist(uplink_spawn_loc, GLOB.uplink_spawn_loc_list, initial(uplink_spawn_loc))
	features["mcolor"]	= sanitize_hexcolor(features["mcolor"], default = FALSE)
	features["gradientstyle"]			= sanitize_inlist(features["gradientstyle"], GLOB.hair_gradients_list)
	features["gradientcolor"]		= sanitize_hexcolor(features["gradientcolor"], default = FALSE)
	features["ethcolor"]	= sanitize_hexcolor(features["ethcolor"])
	features["tail_lizard"]	= sanitize_inlist(features["tail_lizard"], GLOB.tails_list_lizard)
	features["tail_polysmorph"]	= sanitize_inlist(features["tail_polysmorph"], GLOB.tails_list_polysmorph)
	features["tail_human"] 	= sanitize_inlist(features["tail_human"], GLOB.tails_list_human, "None")
	features["snout"]	= sanitize_inlist(features["snout"], GLOB.snouts_list)
	features["horns"] 	= sanitize_inlist(features["horns"], GLOB.horns_list)
	features["ears"]	= sanitize_inlist(features["ears"], GLOB.ears_list, "None")
	features["frills"] 	= sanitize_inlist(features["frills"], GLOB.frills_list)
	features["spines"] 	= sanitize_inlist(features["spines"], GLOB.spines_list)
	features["body_markings"] 	= sanitize_inlist(features["body_markings"], GLOB.body_markings_list)
	features["feature_lizard_legs"]	= sanitize_inlist(features["legs"], GLOB.legs_list, "Normal Legs")
	features["moth_wings"] 	= sanitize_inlist(features["moth_wings"], GLOB.moth_wings_list, "Plain")
	features["teeth"]	= sanitize_inlist(features["teeth"], GLOB.teeth_list)
	features["dome"]	= sanitize_inlist(features["dome"], GLOB.dome_list)
	features["dorsal_tubes"]	= sanitize_inlist(features["dorsal_tubes"], GLOB.dorsal_tubes_list)
	features["ethereal_mark"]	= sanitize_inlist(features["ethereal_mark"], GLOB.ethereal_mark_list)
	features["pod_hair"]	= sanitize_inlist(features["pod_hair"], GLOB.pod_hair_list)
	features["pod_flower"]	= sanitize_inlist(features["pod_flower"], GLOB.pod_flower_list)
	features["ipc_screen"]	= sanitize_inlist(features["ipc_screen"], GLOB.ipc_screens_list)
	features["ipc_antenna"]	 = sanitize_inlist(features["ipc_antenna"], GLOB.ipc_antennas_list)
	features["ipc_chassis"]	 = sanitize_inlist(features["ipc_chassis"], GLOB.ipc_chassis_list)

	persistent_scars = sanitize_integer(persistent_scars)

	joblessrole	= sanitize_integer(joblessrole, 1, 3, initial(joblessrole))
	//Validate job prefs
	for(var/j in job_preferences)
		if(job_preferences[j] != JP_LOW && job_preferences[j] != JP_MEDIUM && job_preferences[j] != JP_HIGH)
			job_preferences -= j

	all_quirks = SANITIZE_LIST(all_quirks)

	return TRUE

/datum/preferences/proc/save_character()
	if(!path)
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/character[default_slot]"

	WRITE_FILE(S["version"]			, SAVEFILE_VERSION_MAX)	//load_character will sanitize any bad data, so assume up-to-date.)

	//Character
	WRITE_FILE(S["real_name"]			, real_name)
	WRITE_FILE(S["name_is_always_random"] , be_random_name)
	WRITE_FILE(S["body_is_always_random"] , be_random_body)
	WRITE_FILE(S["gender"]				, gender)
	WRITE_FILE(S["age"]				, age)
	WRITE_FILE(S["hair_color"]			, hair_color)
	WRITE_FILE(S["facial_hair_color"]	, facial_hair_color)
	WRITE_FILE(S["eye_color"]			, eye_color)
	WRITE_FILE(S["skin_tone"]			, skin_tone)
	WRITE_FILE(S["hair_style_name"]	, hair_style)
	WRITE_FILE(S["facial_style_name"]	, facial_hair_style)
	WRITE_FILE(S["underwear"]			, underwear)
	WRITE_FILE(S["undershirt"]			, undershirt)
	WRITE_FILE(S["socks"]				, socks)
	WRITE_FILE(S["backbag"]			, backbag)
	WRITE_FILE(S["jumpsuit_style"]  , jumpsuit_style)
	WRITE_FILE(S["uplink_loc"]			, uplink_spawn_loc)
	WRITE_FILE(S["species"]			, pref_species.id)
	WRITE_FILE(S["feature_mcolor"]					, features["mcolor"])
	WRITE_FILE(S["feature_gradientstyle"]	, features["gradientstyle"])
	WRITE_FILE(S["feature_gradientcolor"]	, 	features["gradientcolor"])
	WRITE_FILE(S["feature_ethcolor"]					, features["ethcolor"])
	WRITE_FILE(S["feature_lizard_tail"]			, features["tail_lizard"])
	WRITE_FILE(S["feature_polysmorph_tail"]			, features["tail_polysmorph"])
	WRITE_FILE(S["feature_human_tail"]				, features["tail_human"])
	WRITE_FILE(S["feature_lizard_snout"]			, features["snout"])
	WRITE_FILE(S["feature_lizard_horns"]			, features["horns"])
	WRITE_FILE(S["feature_human_ears"]				, features["ears"])
	WRITE_FILE(S["feature_lizard_frills"]			, features["frills"])
	WRITE_FILE(S["feature_lizard_spines"]			, features["spines"])
	WRITE_FILE(S["feature_lizard_body_markings"]	, features["body_markings"])
	WRITE_FILE(S["feature_lizard_legs"]			, features["legs"])
	WRITE_FILE(S["feature_moth_wings"]			, features["moth_wings"])
	WRITE_FILE(S["feature_polysmorph_teeth"]			, features["teeth"])
	WRITE_FILE(S["feature_polysmorph_dome"]			, features["dome"])
	WRITE_FILE(S["feature_polysmorph_dorsal_tubes"]			, features["dorsal_tubes"])
	WRITE_FILE(S["feature_ethereal_mark"]			, features["ethereal_mark"])
	WRITE_FILE(S["feature_pod_hair"]			, features["pod_hair"])
	WRITE_FILE(S["feature_pod_flower"]			, features["pod_flower"])
	WRITE_FILE(S["persistent_scars"]			, persistent_scars)
	WRITE_FILE(S["feature_ipc_screen"]			, features["ipc_screen"])
	WRITE_FILE(S["feature_ipc_antenna"]			, features["ipc_antenna"])
	WRITE_FILE(S["feature_ipc_chassis"]			, features["ipc_chassis"])

	//Custom names
	for(var/custom_name_id in GLOB.preferences_custom_names)
		var/savefile_slot_name = custom_name_id + "_name" //TODO remove this
		WRITE_FILE(S[savefile_slot_name],custom_names[custom_name_id])

	WRITE_FILE(S["preferred_ai_core_display"] ,  preferred_ai_core_display)
	WRITE_FILE(S["prefered_security_department"] , prefered_security_department)
	WRITE_FILE(S["prefered_engineering_department"] , prefered_engineering_department)

	//Jobs
	WRITE_FILE(S["joblessrole"]		, joblessrole)
	//Write prefs
	WRITE_FILE(S["job_preferences"] , job_preferences)

	//Quirks
	WRITE_FILE(S["all_quirks"]			, all_quirks)

	return TRUE


#undef SAVEFILE_VERSION_MAX
#undef SAVEFILE_VERSION_MIN

#ifdef TESTING
//DEBUG
//Some crude tools for testing savefiles
//path is the savefile path
/client/verb/savefile_export(path as text)
	var/savefile/S = new /savefile(path)
	S.ExportText("/",file("[path].txt"))
//path is the savefile path
/client/verb/savefile_import(path as text)
	var/savefile/S = new /savefile(path)
	S.ImportText("/",file("[path].txt"))

#endif
