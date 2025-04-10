//This is the lowest supported version, anything below this is completely obsolete and the entire savefile will be wiped.
#define SAVEFILE_VERSION_MIN 30

//This is the current version, anything below this will attempt to update (if it's not obsolete)
//	You do not need to raise this if you are adding new values that have sane defaults.
//	Only raise this value when changing the meaning/format/name/layout of an existing value
//	where you would want the updater procs below to run
#define SAVEFILE_VERSION_MAX 45

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
	if (current_version < 35)
		toggles |= SOUND_ALT

	if (current_version < 37)
		chat_toggles |= CHAT_TYPING_INDICATOR
	
	if (current_version < 39)
		write_preference(GLOB.preference_entries[/datum/preference/toggle/hotkeys], TRUE)
		key_bindings = deepCopyList(GLOB.default_hotkeys)
		key_bindings_by_key = get_key_bindings_by_key(key_bindings)
		parent.set_macros()
		to_chat(parent, span_userdanger("Empty keybindings, setting default to Hotkey mode"))

	if (current_version < 40)
		migrate_preferences_to_tgui_prefs_menu()

	if (current_version < 41)
		key_bindings["action_1"] = GLOB.default_hotkeys["action_1"]
		key_bindings["action_2"] = GLOB.default_hotkeys["action_2"]
		key_bindings["action_3"] = GLOB.default_hotkeys["action_3"]
		key_bindings["action_4"] = GLOB.default_hotkeys["action_4"]

	if(current_version > 42)
		migrate_yog_legacy_toggles(S)

	if(current_version < 44)
		key_bindings["enable_combat_mode"] = GLOB.default_hotkeys["enable_combat_mode"]
		key_bindings["disable_combat_mode"] = GLOB.default_hotkeys["disable_combat_mode"]

	if(current_version < 45)
		key_bindings["grab_mode_hold"] = GLOB.default_hotkeys["grab_mode_hold"]
		key_bindings["grab_mode_toggle"] = GLOB.default_hotkeys["grab_mode_toggle"]

/datum/preferences/proc/update_character(current_version, savefile/S)
	if(current_version < 31) //Someone doesn't know how to code and make jukebox and autodeadmin the same thing
		toggles &= ~DEADMIN_ALWAYS
		toggles &= ~DEADMIN_ANTAGONIST
		toggles &= ~DEADMIN_POSITION_HEAD
		toggles &= ~DEADMIN_POSITION_SECURITY
		toggles &= ~DEADMIN_POSITION_SILICON //This last one is technically a no-op but it looks cleaner and less like someone forgot
	if(current_version < 34) // default to on
		toggles |= SOUND_VOX
	
	if (current_version < 40)
		migrate_character_to_tgui_prefs_menu()

	if (current_version < 41)
		write_preference(GLOB.preference_entries[/datum/preference/color/pod_hair_color], read_preference(/datum/preference/color/hair_color))
		write_preference(GLOB.preference_entries[/datum/preference/color/ipc_antenna_color], read_preference(/datum/preference/color/hair_color))
		write_preference(GLOB.preference_entries[/datum/preference/color/pod_flower_color], read_preference(/datum/preference/color/facial_hair_color))
		write_preference(GLOB.preference_entries[/datum/preference/color/ipc_screen_color], read_preference(/datum/preference/color/eye_color))
	if(current_version < 42)
		save_character()
		to_chat(parent, span_userdanger(span_big("Color code has been reworked. Check all your character preferences, especially colors, before playing.")))

/// checks through keybindings for outdated unbound keys and updates them
/datum/preferences/proc/check_keybindings()
	if(!parent)
		return
	var/list/binds_by_key = get_key_bindings_by_key(key_bindings)
	var/list/notadded = list()
	for (var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
		if(kb.name in key_bindings)
			continue // key is unbound and or bound to something

		var/addedbind = FALSE
		key_bindings[kb.name] = list()

		if(parent.hotkeys)
			for(var/hotkeytobind in kb.hotkey_keys)
				if(hotkeytobind == "Unbound")
					addedbind = TRUE
				else if(!length(binds_by_key[hotkeytobind])) //Only bind to the key if nothing else is bound
					key_bindings[kb.name] |= hotkeytobind
					addedbind = TRUE
		else
			for(var/classickeytobind in kb.classic_keys)
				if(classickeytobind == "Unbound")
					addedbind = TRUE
				else if(!length(binds_by_key[classickeytobind])) //Only bind to the key if nothing else is bound
					key_bindings[kb.name] |= classickeytobind
					addedbind = TRUE

		if(!addedbind)
			notadded += kb
	save_preferences() //Save the players pref so that new keys that were set to Unbound as default are permanently stored
	if(length(notadded))
		addtimer(CALLBACK(src, PROC_REF(announce_conflict), notadded), 5 SECONDS)

/datum/preferences/proc/announce_conflict(list/notadded)
	to_chat(parent, "<span class='warningplain'><b><u>Keybinding Conflict</u></b></span>\n\
					<span class='warningplain'><b>There are new <a href='byond://?src=[REF(src)];open_keybindings=1'>keybindings</a> that default to keys you've already bound. The new ones will be unbound.</b></span>")
	for(var/item in notadded)
		var/datum/keybinding/conflicted = item
		to_chat(parent, span_danger("[conflicted.category]: [conflicted.full_name] needs updating"))

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
		var/bacpath = "[path].updatebac" //todo: if the savefile version is higher then the server, check the backup, and give the player a prompt to load the backup
		if (fexists(bacpath))
			fdel(bacpath) //only keep 1 version of backup
		fcopy(S, bacpath) //byond helpfully lets you use a savefile for the first arg.
		return FALSE
	
	apply_all_client_preferences()

	//general preferences
	READ_FILE(S["lastchangelog"], lastchangelog)
	READ_FILE(S["be_special"] , be_special)
	READ_FILE(S["default_slot"], default_slot)
	READ_FILE(S["player_alt_titles"], player_alt_titles)

	READ_FILE(S["toggles"], toggles)
	READ_FILE(S["chat_toggles"], chat_toggles)
	READ_FILE(S["extra_toggles"], extra_toggles)
	
	READ_FILE(S["ignoring"], ignoring)

	READ_FILE(S["key_bindings"], key_bindings)

	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_preferences(needs_update, S)		//needs_update = savefile_version if we need an update (positive integer)

	// this apparently fails every time and overwrites any unloaded prefs with the default values, so don't load anything after this line or it won't actually save
	check_keybindings() 
	key_bindings_by_key = get_key_bindings_by_key(key_bindings)

	//Sanitize
	lastchangelog = sanitize_text(lastchangelog, initial(lastchangelog))
	be_special = sanitize_be_special(SANITIZE_LIST(be_special))
	default_slot = sanitize_integer(default_slot, 1, max_save_slots, initial(default_slot))
	player_alt_titles = SANITIZE_LIST(player_alt_titles)

	toggles = sanitize_integer(toggles, 0, SHORT_REAL_LIMIT-1, initial(toggles))
	
	key_bindings = sanitize_keybindings(key_bindings)

	return TRUE

/datum/preferences/proc/save_preferences()
	if(!path)
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/"

	WRITE_FILE(S["version"] , SAVEFILE_VERSION_MAX)		//updates (or failing that the sanity checks) will ensure data is not invalid at load. Assume up-to-date

	for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]
		if (preference.savefile_identifier != PREFERENCE_PLAYER)
			continue

		if (!(preference.type in recently_updated_keys))
			continue

		recently_updated_keys -= preference.type

		if (preference_type in value_cache)
			write_preference(preference, preference.serialize(value_cache[preference_type]))

	//general preferences
	WRITE_FILE(S["lastchangelog"], lastchangelog)
	WRITE_FILE(S["be_special"], be_special)
	WRITE_FILE(S["default_slot"], default_slot)
	WRITE_FILE(S["player_alt_titles"], player_alt_titles)

	WRITE_FILE(S["toggles"], toggles)
	WRITE_FILE(S["chat_toggles"], chat_toggles)
	WRITE_FILE(S["extra_toggles"], extra_toggles)

	WRITE_FILE(S["ignoring"], ignoring)

	WRITE_FILE(S["key_bindings"], key_bindings)

	return TRUE

/datum/preferences/proc/load_character(slot)
	SHOULD_NOT_SLEEP(TRUE)

	if(!path)
		return FALSE
	if(!fexists(path))
		return FALSE
	
	character_savefile = null

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
	
	// Read everything into cache
	for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]
		if (preference.savefile_identifier != PREFERENCE_CHARACTER)
			continue

		value_cache -= preference_type
		read_preference(preference_type)

	//Character
	READ_FILE(S["randomise"],  randomise)

	//Load prefs
	READ_FILE(S["job_preferences"], job_preferences)

	//Quirks
	READ_FILE(S["all_quirks"], all_quirks)

	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_character(needs_update, S)		//needs_update == savefile_version if we need an update (positive integer)

	//Sanitize
	randomise = SANITIZE_LIST(randomise)
	job_preferences = SANITIZE_LIST(job_preferences)
	all_quirks = SANITIZE_LIST(all_quirks)

	//Validate job prefs
	for(var/j in job_preferences)
		if(job_preferences[j] != JP_LOW && job_preferences[j] != JP_MEDIUM && job_preferences[j] != JP_HIGH)
			job_preferences -= j

	all_quirks = SSquirks.filter_invalid_quirks(all_quirks, src)
	validate_quirks()

	return TRUE

/datum/preferences/proc/save_character()
	SHOULD_NOT_SLEEP(TRUE)

	if(!path)
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/character[default_slot]"

	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (preference.savefile_identifier != PREFERENCE_CHARACTER)
			continue

		if (!(preference.type in recently_updated_keys))
			continue

		recently_updated_keys -= preference.type

		if (preference.type in value_cache)
			write_preference(preference, preference.serialize(value_cache[preference.type]))

	WRITE_FILE(S["version"], SAVEFILE_VERSION_MAX)	//load_character will sanitize any bad data, so assume up-to-date.)

	//Character
	WRITE_FILE(S["randomise"] , randomise)

	//Write prefs
	WRITE_FILE(S["job_preferences"] , job_preferences)

	//Quirks
	WRITE_FILE(S["all_quirks"] , all_quirks)

	return TRUE


/datum/preferences/proc/sanitize_be_special(list/input_be_special)
	var/list/output = list()

	for (var/role in input_be_special)
		if (role in GLOB.special_roles)
			output += role

	return output.len == input_be_special.len ? input_be_special : output

/proc/sanitize_keybindings(value)
	var/list/base_bindings = sanitize_islist(value, list())
	for(var/keybind_name in base_bindings)
		if (!(keybind_name in GLOB.keybindings_by_name))
			base_bindings -= keybind_name
	return base_bindings

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
