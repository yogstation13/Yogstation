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
	var/hotkeys = TRUE // yogs - Rebindable Keybindings
	var/tgui_fancy = TRUE
	var/tgui_lock = FALSE
	var/windowflashing = TRUE
	var/toggles = TOGGLES_DEFAULT
	var/db_flags
	var/chat_toggles = TOGGLES_DEFAULT_CHAT
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
	var/list/features = list("mcolor" = "FFF", "gradientstyle" = "None", "gradientcolor" = "000", "ethcolor" = "9c3030", "tail_lizard" = "Smooth", "tail_human" = "None", "snout" = "Round", "horns" = "None", "ears" = "None", "wings" = "None", "frills" = "None", "spines" = "None", "body_markings" = "None", "legs" = "Normal Legs", "moth_wings" = "Plain", "tail_polysmorph" = "Polys", "teeth" = "None", "dome" = "None", "dorsal_tubes" = "No", "ethereal_mark" = "None", "pod_hair" = "Cabbage", "pod_flower" = "Cabbage", "ipc_screen" = "Blue", "ipc_antenna" = "None", "ipc_chassis" = "Morpheus Cyberkinetics(Greyscale)")
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

/datum/preferences/New(client/C)
	parent = C

	for(var/custom_name_id in GLOB.preferences_custom_names)
		custom_names[custom_name_id] = get_default_name(custom_name_id)

	UI_style = GLOB.available_ui_styles[1]
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
	var/loaded_preferences_successfully = load_preferences()
	if(loaded_preferences_successfully)
		if(load_character())
			return
	//we couldn't load character data so just randomize the character appearance + name
	random_character()		//let's create a random character then - rather than a fat, bald and naked man.
	real_name = pref_species.random_name(gender,1)
	if(!loaded_preferences_successfully)
		save_preferences()
	save_character()		//let's save this new random character so it doesn't keep generating new ones.
	menuoptions = list()
	return

#define APPEARANCE_CATEGORY_COLUMN "<td valign='top' width='14%'>"
#define MAX_MUTANT_ROWS 4

/datum/preferences/proc/ShowChoices(mob/user)
	if(!user || !user.client)
		return

	if(!SSjob || (SSjob.occupations.len <= 0))
		to_chat(user, span_notice("The job SSticker is not yet finished creating jobs, please try again later"))
		return

	update_preview_icon()
	var/list/dat = list("<center>")

	dat += "<a href='?_src_=prefs;preference=tab;tab=0' [current_tab == 0 ? "class='linkOn'" : ""]>Character Settings</a>"
	dat += "<a href='?_src_=prefs;preference=tab;tab=1' [current_tab == 1 ? "class='linkOn'" : ""]>Game Preferences</a>"
	dat += "<a href='?_src_=prefs;preference=tab;tab=2' [current_tab == 2 ? "class='linkOn'" : ""]>OOC Preferences</a>"
	dat += "<a href='?_src_=prefs;preference=tab;tab=3' [current_tab == 3 ? "class='linkOn'" : ""]>Donator Preferences</a>" // yogs - Donor features
	dat += "<a href='?_src_=prefs;preference=tab;tab=4' [current_tab == 4 ? "class='linkOn'" : ""]>Keybindings</a>" // yogs - Custom keybindings

	if(!path)
		dat += "<div class='notice'>Please create an account to save your preferences</div>"

	dat += "</center>"

	dat += "<HR>"

	switch(current_tab)
		if (0) // Character Settings#
			if(path)
				var/savefile/S = new /savefile(path)
				if(S)
					dat += "<center>"
					var/name
					var/unspaced_slots = 0
					for(var/i=1, i<=max_save_slots, i++)
						unspaced_slots++
						if(unspaced_slots > 4)
							dat += "<br>"
							unspaced_slots = 0
						S.cd = "/character[i]"
						S["real_name"] >> name
						if(!name)
							name = "Character[i]"
						dat += "<a style='white-space:nowrap;' href='?_src_=prefs;preference=changeslot;num=[i];' [i == default_slot ? "class='linkOn'" : ""]>[name]</a> "
					dat += "</center>"

			dat += "<center><h2>Occupation Choices</h2>"
			dat += "<a href='?_src_=prefs;preference=job;task=menu'>Set Occupation Preferences</a><br></center>"
			if(CONFIG_GET(flag/roundstart_traits))
				dat += "<center><h2>Quirk Setup</h2>"
				dat += "<a href='?_src_=prefs;preference=trait;task=menu'>Configure Quirks</a><br></center>"
				dat += "<center><b>Current Quirks:</b> [all_quirks.len ? all_quirks.Join(", ") : "None"]</center>"
			dat += "<h2>Identity</h2>"
			dat += "<table width='100%'><tr><td width='75%' valign='top'>"
			if(is_banned_from(user.ckey, "Appearance"))
				dat += "<b>You are banned from using custom names and appearances. You can continue to adjust your characters, but you will be randomised once you join the game.</b><br>"
			dat += "<a href='?_src_=prefs;preference=name;task=random'>Random Name</A> "
			dat += "<a href='?_src_=prefs;preference=name'>Always Random Name: [be_random_name ? "Yes" : "No"]</a><BR>"

			dat += "<b>Name:</b> "
			dat += "<a href='?_src_=prefs;preference=name;task=input'>[real_name]</a><BR>"

			if(FGENDER in pref_species.species_traits) //check for forced genders first like a smart person
				gender = FEMALE
			else if(AGENDER in pref_species.species_traits)
				gender = PLURAL
			else if(MGENDER in pref_species.species_traits)
				gender = MALE
			else
				var/dispGender
				if(gender == MALE)
					dispGender = "Male"
				else if(gender == FEMALE)
					dispGender = "Female"
				else
					dispGender = "Other"
				dat += "<b>Gender:</b> <a href='?_src_=prefs;preference=gender'>[dispGender]</a>"
				dat += "<a href ='?_src_=prefs;preference=gender;task=lock'>[random_locks["gender"] ? "Unlock" : "Lock"]</a><BR>"

			dat += "<b>Age:</b> <a href='?_src_=prefs;preference=age;task=input'>[age]</a><BR>"

			dat += "<b>Special Names:</b><BR>"
			var/old_group
			for(var/custom_name_id in GLOB.preferences_custom_names)
				var/namedata = GLOB.preferences_custom_names[custom_name_id]
				if(!old_group)
					old_group = namedata["group"]
				else if(old_group != namedata["group"])
					old_group = namedata["group"]
					dat += "<br>"
				dat += "<a href ='?_src_=prefs;preference=[custom_name_id];task=input'><b>[namedata["pref_name"]]:</b> [custom_names[custom_name_id]]</a> "
			dat += "<br><br>"

			dat += "<b>Custom Job Preferences:</b><BR>"
			dat += "<a href='?_src_=prefs;preference=ai_core_icon;task=input'><b>Preferred AI Core Display:</b> [preferred_ai_core_display]</a><br>"
			dat += "<a href='?_src_=prefs;preference=sec_dept;task=input'><b>Preferred Security Department:</b> [prefered_security_department]</a><BR>"
			dat += "<a href='?_src_=prefs;preference=eng_dept;task=input'><b>Preferred Engineering Department:</b> [prefered_engineering_department]</a><BR>"


			dat += "<b>Language:</b><BR>"
			dat += "<a href='?_src_=prefs;preference=accent;task=input'><b>Accent:</b> [accent ? accent : "None"]</a><BR></td>"

			dat += "</tr></table>"

			dat += "<h2>Body</h2>"
			dat += "<a href='?_src_=prefs;preference=all;task=random'>Random Body</a> "
			dat += "<a href='?_src_=prefs;preference=all'>Always Random Body: [be_random_body ? "Yes" : "No"]</a>"
			dat += "<a href='?_src_=prefs;preference=u_all;task=lock'>Unlock all</a>"
			dat += "<a href='?_src_=prefs;preference=l_all;task=lock'>Lock all</a><br>"
			dat += "<a href='?_src_=prefs;preference=cycle_background;task=input'>Background: [background_options[background]]</a><br><br>"

			dat += "<table width='100%'><tr><td width='24%' valign='top'>"

			dat += "<b>Species:</b><BR><a href='?_src_=prefs;preference=species;task=input'>[pref_species.name]</a>"
			dat += "<a href ='?_src_=prefs;preference=species;task=lock'>[random_locks["species"] ? "Unlock" : "Lock"]</a><BR>"

			dat += "<b>Underwear:</b><BR><a href ='?_src_=prefs;preference=underwear;task=input'>[underwear]</a>"
			dat += "<a href ='?_src_=prefs;preference=underwear;task=lock'>[random_locks["underwear"] ? "Unlock" : "Lock"]</a><BR>"

			dat += "<b>Undershirt:</b><BR><a href ='?_src_=prefs;preference=undershirt;task=input'>[undershirt]</a>"
			dat += "<a href ='?_src_=prefs;preference=undershirt;task=lock'>[random_locks["undershirt"] ? "Unlock" : "Lock"]</a><BR>"

			dat += "<b>Socks:</b><BR><a href ='?_src_=prefs;preference=socks;task=input'>[socks]</a>"
			dat += "<a href ='?_src_=prefs;preference=socks;task=lock'>[random_locks["socks"] ? "Unlock" : "Lock"]</a><BR>"

			dat += "<b>Backpack:</b><BR><a href ='?_src_=prefs;preference=bag;task=input'>[backbag]</a>"
			dat += "<b>Jumpsuit:</b><BR><a href ='?_src_=prefs;preference=suit;task=input'>[jumpsuit_style]</a><BR>"
			dat += "<a href ='?_src_=prefs;preference=bag;task=lock'>[random_locks["bag"] ? "Unlock" : "Lock"]</a><BR>"
			if((HAS_FLESH in pref_species.species_traits) || (HAS_BONE in pref_species.species_traits))
				dat += "<BR><b>Temporal Scarring:</b><BR><a href='?_src_=prefs;preference=persistent_scars'>[(persistent_scars) ? "Enabled" : "Disabled"]</A>"
				dat += "<a href='?_src_=prefs;preference=clear_scars'>Clear scar slots</A><BR>"
			dat += "<b>Uplink Spawn Location:</b><BR><a href ='?_src_=prefs;preference=uplink_loc;task=input'>[uplink_spawn_loc]</a><BR></td>"

			var/use_skintones = pref_species.use_skintones
			if(use_skintones)

				dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Skin Tone</h3>"

				dat += "<a href='?_src_=prefs;preference=s_tone;task=input'>[skin_tone]</a>"
				dat += "<a href ='?_src_=prefs;preference=underwear;task=lock'>[random_locks["underwear"] ? "Unlock" : "Lock"]</a><BR>"

			var/mutant_colors
			if((((MUTCOLORS in pref_species.species_traits) && !(NOCOLORCHANGE in pref_species.species_traits))) || (MUTCOLORS_PARTSONLY in pref_species.species_traits))

				if(!use_skintones)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Mutant Color</h3>"

				dat += "<span style='border: 1px solid #161616; background-color: #[features["mcolor"]];'>&nbsp;&nbsp;&nbsp;</span>"
				dat += "<a href='?_src_=prefs;preference=mcolor;task=input'>Change</a> <a href ='?_src_=prefs;preference=mcolor;task=lock'>[random_locks["mcolor"] ? "Unlock" : "Lock"]</a><BR>"

				mutant_colors = TRUE

			if(istype(pref_species, /datum/species/ethereal)) //not the best thing to do tbf but I dont know whats better.

				if(!use_skintones)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Ethereal Color</h3>"

				dat += "<span style='border: 1px solid #161616; background-color: #[features["ethcolor"]];'>&nbsp;&nbsp;&nbsp;</span>"
				dat += "<a href='?_src_=prefs;preference=ethcolor;task=input'>Change</a> <a href ='?_src_=prefs;preference=ethcolor;task=lock'>[random_locks["ethcolor"] ? "Unlock" : "Lock"]</a><BR>"


			if((EYECOLOR in pref_species.species_traits) || !(NOEYESPRITES in pref_species.species_traits))

				if(!use_skintones && !mutant_colors)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Eye Color</h3>"

				dat += "<span style='border: 1px solid #161616; background-color: #[eye_color];'>&nbsp;&nbsp;&nbsp;</span>"
				dat += "<a href='?_src_=prefs;preference=eyes;task=input'>Change</a> <a href ='?_src_=prefs;preference=eyes;task=lock'>[random_locks["eyes"] ? "Unlock" : "Lock"]</a><BR>"

				dat += "</td>"
			else if(use_skintones || mutant_colors)
				dat += "</td>"

			if(HAIR in pref_species.species_traits)

				dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Hair Style</h3>"

				dat += "<a href='?_src_=prefs;preference=hair_style;task=input'>[hair_style]</a>"
				dat += "<a href ='?_src_=prefs;preference=hair_style;task=lock'>[random_locks["hair_style"] ? "Unlock" : "Lock"]</a><BR>"

				dat += "<a href='?_src_=prefs;preference=previous_hair_style;task=input'>&lt;</a> <a href='?_src_=prefs;preference=next_hair_style;task=input'>&gt;</a><BR>"

				dat += "<span style='border:1px solid #161616; background-color: #[hair_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=hair;task=input'>Change</a>"
				dat += "<a href ='?_src_=prefs;preference=hair_color;task=lock'>[random_locks["hair"] ? "Unlock" : "Lock"]</a><BR>"

				dat += "<h3>Facial Hair Style</h3>"

				dat += "<a href='?_src_=prefs;preference=facial_hair_style;task=input'>[facial_hair_style]</a>"
				dat += "<a href ='?_src_=prefs;preference=facial_hair_style;task=lock'>[random_locks["facial_hair_style"] ? "Unlock" : "Lock"]</a><BR>"

				dat += "<a href='?_src_=prefs;preference=previous_facehair_style;task=input'>&lt;</a> <a href='?_src_=prefs;preference=next_facehair_style;task=input'>&gt;</a><BR>"

				dat += "<span style='border: 1px solid #161616; background-color: #[facial_hair_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=facial;task=input'>Change</a>"
				dat += "<a href ='?_src_=prefs;preference=facial_hair_style_color;task=lock'>[random_locks["facial"] ? "Unlock" : "Lock"]</a><BR>"

				dat += "<h3>Hair Gradient</h3>"

				dat += "<a href='?_src_=prefs;preference=hair_gradient_style;task=input'>[features["gradientstyle"]]</a>"
				dat += "<a href ='?_src_=prefs;preference=hair_gradient_style;task=lock'>[random_locks["gradientstyle"] ? "Unlock" : "Lock"]</a><BR>"

				dat += "<a href='?_src_=prefs;preference=previous_hair_gradient_style;task=input'>&lt;</a> <a href='?_src_=prefs;preference=next_hair_gradient_style;task=input'>&gt;</a><BR>"

				dat += "<span style='border:1px solid #161616; background-color: #[features["gradientcolor"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=hair_gradient;task=input'>Change</a>"
				dat += "<a href ='?_src_=prefs;preference=hair_gradient_color;task=lock'>[random_locks["gradientcolor"] ? "Unlock" : "Lock"]</a><BR>"

				dat += "</td>"

			//Mutant stuff
			var/mutant_category = 0

			if("tail_lizard" in pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Tail</h3>"

				dat += "<a href='?_src_=prefs;preference=tail_lizard;task=input'>[features["tail_lizard"]]</a>"
				dat += "<a href ='?_src_=prefs;preference=tail_lizard;task=lock'>[random_locks["tail_lizard"] ? "Unlock" : "Lock"]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("tail_polysmorph" in pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Tail</h3>"

				dat += "<a href='?_src_=prefs;preference=tail_polysmorph;task=input'>[features["tail_polysmorph"]]</a>"
				dat += "<a href ='?_src_=prefs;preference=tail_polysmorph;task=lock'>[random_locks["tail_polysmorph"] ? "Unlock" : "Lock"]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("snout" in pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Snout</h3>"

				dat += "<a href='?_src_=prefs;preference=snout;task=input'>[features["snout"]]</a>"
				dat += "<a href ='?_src_=prefs;preference=snout;task=lock'>[random_locks["snout"] ? "Unlock" : "Lock"]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("horns" in pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Horns</h3>"

				dat += "<a href='?_src_=prefs;preference=horns;task=input'>[features["horns"]]</a>"
				dat += "<a href ='?_src_=prefs;preference=horns;task=lock'>[random_locks["horns"] ? "Unlock" : "Lock"]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("frills" in pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Frills</h3>"

				dat += "<a href='?_src_=prefs;preference=frills;task=input'>[features["frills"]]</a>"
				dat += "<a href ='?_src_=prefs;preference=frills;task=lock'>[random_locks["frills"] ? "Unlock" : "Lock"]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("spines" in pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Spines</h3>"

				dat += "<a href='?_src_=prefs;preference=spines;task=input'>[features["spines"]]</a>"
				dat += "<a href ='?_src_=prefs;preference=spines;task=lock'>[random_locks["spines"] ? "Unlock" : "Lock"]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("body_markings" in pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Body Markings</h3>"

				dat += "<a href='?_src_=prefs;preference=body_markings;task=input'>[features["body_markings"]]</a>"
				dat += "<a href ='?_src_=prefs;preference=body_markings;task=lock'>[random_locks["body_markings"] ? "Unlock" : "Lock"]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(("legs" in pref_species.default_features) && !(DIGITIGRADE in pref_species.species_traits))
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Legs</h3>"

				dat += "<a href='?_src_=prefs;preference=legs;task=input'>[features["legs"]]</a>"
				dat += "<a href ='?_src_=prefs;preference=legs;task=lock'>[random_locks["legs"] ? "Unlock" : "Lock"]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("moth_wings" in pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Moth wings</h3>"

				dat += "<a href='?_src_=prefs;preference=moth_wings;task=input'>[features["moth_wings"]]</a>"
				dat += "<a href ='?_src_=prefs;preference=moth_wings;task=lock'>[random_locks["moth_wings"] ? "Unlock" : "Lock"]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("teeth" in pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Teeth</h3>"

				dat += "<a href='?_src_=prefs;preference=teeth;task=input'>[features["teeth"]]</a>"
				dat += "<a href ='?_src_=prefs;preference=teeth;task=lock'>[random_locks["teeth"] ? "Unlock" : "Lock"]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("dome" in pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Dome</h3>"

				dat += "<a href='?_src_=prefs;preference=dome;task=input'>[features["dome"]]</a>"
				dat += "<a href ='?_src_=prefs;preference=dome;task=lock'>[random_locks["dome"] ? "Unlock" : "Lock"]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("dorsal_tubes" in pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Dorsal Tubes</h3>"

				dat += "<a href='?_src_=prefs;preference=dorsal_tubes;task=input'>[features["dorsal_tubes"]]</a>"
				dat += "<a href ='?_src_=prefs;preference=dorsal_tubes;task=lock'>[random_locks["dorsal_tubes"] ? "Unlock" : "Lock"]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("ethereal_mark" in pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Ethereal Mark</h3>"

				dat += "<a href='?_src_=prefs;preference=ethereal_mark;task=input'>[features["ethereal_mark"]]</a>"
				dat += "<a href ='?_src_=prefs;preference=ethereal_mark;task=lock'>[random_locks["ethereal_mark"] ? "Unlock" : "Lock"]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("pod_hair" in pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Head Vegitation Style</h3>"
				dat += "<a href='?_src_=prefs;preference=pod_hair;task=input'>[features["pod_hair"]]</a>"
				dat += "<a href ='?_src_=prefs;preference=pod_hair;task=lock'>[random_locks["pod_hair"] ? "Unlock" : "Lock"]</a><BR>"
				dat += "<span style='border:1px solid #161616; background-color: #[hair_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=pod_hair_color;task=input'>Change</a>"
				dat += "<a href ='?_src_=prefs;preference=hair_color;task=lock'>[random_locks["hair"] ? "Unlock" : "Lock"]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("pod_flower" in pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN
				dat += "<h3>Head Flowers Color</h3>"
				dat += "<span style='border: 1px solid #161616; background-color: #[facial_hair_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=pod_flower_color;task=input'>Change</a>"
				dat += "<a href ='?_src_=prefs;preference=facial_hair_style_color;task=lock'>[random_locks["facial"] ? "Unlock" : "Lock"]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("tail_human" in pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Tail</h3>"

				dat += "<a href='?_src_=prefs;preference=tail_human;task=input'>[features["tail_human"]]</a>"
				dat += "<a href ='?_src_=prefs;preference=tail_human;task=lock'>[random_locks["tail_human"] ? "Unlock" : "Lock"]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("ipc_screen" in pref_species.mutant_bodyparts)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Screen Style</h3>"

				dat += "<a href='?_src_=prefs;preference=ipc_screen;task=input'>[features["ipc_screen"]]</a><BR>"

				dat += "<span style='border: 1px solid #161616; background-color: #[eye_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=eyes;task=input'>Change</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("ipc_antenna" in pref_species.mutant_bodyparts)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Antenna Style</h3>"

				dat += "<a href='?_src_=prefs;preference=ipc_antenna;task=input'>[features["ipc_antenna"]]</a><BR>"

				dat += "<span style='border:1px solid #161616; background-color: #[hair_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=hair;task=input'>Change</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("ipc_chassis" in pref_species.mutant_bodyparts)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Chassis Style</h3>"

				dat += "<a href='?_src_=prefs;preference=ipc_chassis;task=input'>[features["ipc_chassis"]]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("ears" in pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Ears</h3>"

				dat += "<a href='?_src_=prefs;preference=ears;task=input'>[features["ears"]]</a>"
				dat += "<a href ='?_src_=prefs;preference=ears;task=lock'>[random_locks["ears"] ? "Unlock" : "Lock"]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(CONFIG_GET(flag/join_with_mutant_humans))

				if("wings" in pref_species.default_features && GLOB.r_wings_list.len >1)
					if(!mutant_category)
						dat += APPEARANCE_CATEGORY_COLUMN

					dat += "<h3>Wings</h3>"

					dat += "<a href='?_src_=prefs;preference=wings;task=input'>[features["wings"]]</a>"
					dat += "<a href ='?_src_=prefs;preference=wings;task=lock'>[random_locks["wings"] ? "Unlock" : "Lock"]</a><BR>"

					mutant_category++
					if(mutant_category >= MAX_MUTANT_ROWS)
						dat += "</td>"
						mutant_category = 0

			if(mutant_category)
				dat += "</td>"
				mutant_category = 0
			dat += "</tr></table>"


		if (1) // Game Preferences
			dat += "<table><tr><td width='340px' height='300px' valign='top'>"
			dat += "<h2>General Settings</h2>"
			dat += "<b>UI Style:</b> <a href='?_src_=prefs;task=input;preference=ui'>[UI_style]</a><br>"
			dat += "<b>tgui Window Mode:</b> <a href='?_src_=prefs;preference=tgui_fancy'>[(tgui_fancy) ? "Fancy (default)" : "Compatible (slower)"]</a><br>"
			dat += "<b>tgui Window Placement:</b> <a href='?_src_=prefs;preference=tgui_lock'>[(tgui_lock) ? "Primary monitor" : "Free (default)"]</a><br>"
			dat += "<b>Show Runechat Chat Bubbles:</b> <a href='?_src_=prefs;preference=chat_on_map'>[chat_on_map ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>Runechat message char limit:</b> <a href='?_src_=prefs;preference=max_chat_length;task=input'>[max_chat_length]</a><br>"
			dat += "<b>See Runechat for non-mobs:</b> <a href='?_src_=prefs;preference=see_chat_non_mob'>[see_chat_non_mob ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>See Runechat emotes:</b> <a href='?_src_=prefs;preference=see_rc_emotes'>[see_rc_emotes ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>Hear alternative station announcers:</b> <a href='?_src_=prefs;task=input;preference=alternative_announcers'>[disable_alternative_announcers ? "Disabled" : "Enabled"]</a><br>"
			dat += "<b>Ballon Alerts:</b> <a href='?_src_=prefs;task=input;preference=balloon_alerts'>[disable_balloon_alerts ? "Disabled" : "Enabled"]</a><br>"
			dat += "<br>"
			dat += "<b>Action Buttons:</b> <a href='?_src_=prefs;preference=action_buttons'>[(buttons_locked) ? "Locked In Place" : "Unlocked"]</a><br>"
			//dat += "<b>Keybindings:</b> <a href='?_src_=prefs;preference=hotkeys'>[(hotkeys) ? "Hotkeys" : "Default"]</a><br>" // yogs - Custom keybindings
			dat += "<br>"
			dat += "<b>PDA Color:</b> <span style='border:1px solid #161616; background-color: [pda_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=pda_color;task=input'>Change</a><BR>"
			dat += "<b>PDA Style:</b> <a href='?_src_=prefs;task=input;preference=pda_style'>[pda_style]</a><br>"
			dat += "<b>PDA Starts in ID Slot:</b> <a href='?_src_=prefs;task=input;preference=id_in_pda'>[id_in_pda ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>Skillcape:</b> <a href='?_src_=prefs;task=input;preference=skillcape'>[(skillcape_id != "None") ? "[GLOB.skillcapes[skillcape_id]]" : "None"] </a><br>"
			dat += "<b>Flare:</b> <a href='?_src_=prefs;task=input;preference=flare'>[flare ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>Map:</b> <a href='?_src_=prefs;task=input;preference=map'>[map ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>Preferred Box Bar:</b> <a href='?_src_=prefs;task=input;preference=bar_choice'>[bar_choice]</a><br>"
			dat += "<br>"
			dat += "<b>Ghost Ears:</b> <a href='?_src_=prefs;preference=ghost_ears'>[(chat_toggles & CHAT_GHOSTEARS) ? "All Speech" : "Nearest Creatures"]</a><br>"
			dat += "<b>Ghost Radio:</b> <a href='?_src_=prefs;preference=ghost_radio'>[(chat_toggles & CHAT_GHOSTRADIO) ? "All Messages":"No Messages"]</a><br>"
			dat += "<b>Ghost Sight:</b> <a href='?_src_=prefs;preference=ghost_sight'>[(chat_toggles & CHAT_GHOSTSIGHT) ? "All Emotes" : "Nearest Creatures"]</a><br>"
			dat += "<b>Ghost Whispers:</b> <a href='?_src_=prefs;preference=ghost_whispers'>[(chat_toggles & CHAT_GHOSTWHISPER) ? "All Speech" : "Nearest Creatures"]</a><br>"
			dat += "<b>Ghost PDA:</b> <a href='?_src_=prefs;preference=ghost_pda'>[(chat_toggles & CHAT_GHOSTPDA) ? "All Messages" : "Nearest Creatures"]</a><br>"

			if(unlock_content)
				dat += "<b>Ghost Form:</b> <a href='?_src_=prefs;task=input;preference=ghostform'>[ghost_form]</a><br>"
				dat += "<B>Ghost Orbit: </B> <a href='?_src_=prefs;task=input;preference=ghostorbit'>[ghost_orbit]</a><br>"

			var/button_name = "If you see this something went wrong."
			switch(ghost_accs)
				if(GHOST_ACCS_FULL)
					button_name = GHOST_ACCS_FULL_NAME
				if(GHOST_ACCS_DIR)
					button_name = GHOST_ACCS_DIR_NAME
				if(GHOST_ACCS_NONE)
					button_name = GHOST_ACCS_NONE_NAME

			dat += "<b>Ghost Accessories:</b> <a href='?_src_=prefs;task=input;preference=ghostaccs'>[button_name]</a><br>"

			switch(ghost_others)
				if(GHOST_OTHERS_THEIR_SETTING)
					button_name = GHOST_OTHERS_THEIR_SETTING_NAME
				if(GHOST_OTHERS_DEFAULT_SPRITE)
					button_name = GHOST_OTHERS_DEFAULT_SPRITE_NAME
				if(GHOST_OTHERS_SIMPLE)
					button_name = GHOST_OTHERS_SIMPLE_NAME

			dat += "<b>Ghosts of Others:</b> <a href='?_src_=prefs;task=input;preference=ghostothers'>[button_name]</a><br>"
			dat += "<br>"

			dat += "<b>Income Updates:</b> <a href='?_src_=prefs;preference=income_pings'>[(chat_toggles & CHAT_BANKCARD) ? "Allowed" : "Muted"]</a><br>"
			dat += "<br>"

			dat += "<b>FPS:</b> <a href='?_src_=prefs;preference=clientfps;task=input'>[clientfps]</a><br>"

			dat += "<b>Parallax (Fancy Space):</b> <a href='?_src_=prefs;preference=parallaxdown' oncontextmenu='window.location.href=\"?_src_=prefs;preference=parallaxup\";return false;'>"
			switch (parallax)
				if (PARALLAX_LOW)
					dat += "Low"
				if (PARALLAX_MED)
					dat += "Medium"
				if (PARALLAX_INSANE)
					dat += "Insane"
				if (PARALLAX_DISABLE)
					dat += "Disabled"
				else
					dat += "High"
			dat += "</a><br>"

			dat += "<b>Ambient Occlusion:</b> <a href='?_src_=prefs;preference=ambientocclusion'>[ambientocclusion ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>Fit Viewport:</b> <a href='?_src_=prefs;preference=auto_fit_viewport'>[auto_fit_viewport ? "Auto" : "Manual"]</a><br>"
			if (CONFIG_GET(string/default_view) != CONFIG_GET(string/default_view_square))
				dat += "<b>Widescreen:</b> <a href='?_src_=prefs;preference=widescreenpref'>[widescreenpref ? "Enabled ([CONFIG_GET(string/default_view)])" : "Disabled ([CONFIG_GET(string/default_view_square)])"]</a><br>"

			button_name = pixel_size
			dat += "<b>Pixel Scaling:</b> <a href='?_src_=prefs;preference=pixel_size'>[(button_name) ? "Pixel Perfect [button_name]x" : "Stretch to fit"]</a><br>"

			switch(scaling_method)
				if(SCALING_METHOD_NORMAL)
					button_name = "Nearest Neighbor"
				if(SCALING_METHOD_DISTORT)
					button_name = "Point Sampling"
				if(SCALING_METHOD_BLUR)
					button_name = "Bilinear"
			dat += "<b>Scaling Method:</b> <a href='?_src_=prefs;preference=scaling_method'>[button_name]</a><br>"

			if (CONFIG_GET(flag/maprotation))
				var/p_map = preferred_map
				if (!p_map)
					p_map = "Default"
					if (config.defaultmap)
						p_map += " ([config.defaultmap.map_name])"
				else
					if (p_map in config.maplist)
						var/datum/map_config/VM = config.maplist[p_map]
						if (!VM)
							p_map += " (No longer exists)"
						else
							p_map = VM.map_name
					else
						p_map += " (No longer exists)"
				if(CONFIG_GET(flag/preference_map_voting))
					dat += "<b>Preferred Map:</b> <a href='?_src_=prefs;preference=preferred_map;task=input'>[p_map]</a><br>"
			//yogs start -- Mood preference toggling
			if(CONFIG_GET(flag/disable_human_mood))
				dat += "<b>Mood:</b> <a href='?_src_=prefs;preference=mood'>[yogtoggles & PREF_MOOD ? "Enabled" : "Disabled"]</a><br>"
				dat += "<b>Mood Tail Wagging:</b> <a href='?_src_=prefs;preference=moodtailwagging'>[mood_tail_wagging  ? "Enabled" : "Disabled"] </a><br>"
			//yogs end

			dat += "</td><td width='300px' height='300px' valign='top'>"

			dat += "<h2>Special Role Settings</h2>"

			if(is_banned_from(user.ckey, ROLE_SYNDICATE))
				dat += "<font color=red><b>You are banned from antagonist roles.</b></font><br>"
				src.be_special = list()


			for (var/i in GLOB.special_roles)
				if(is_banned_from(user.ckey, i))
					dat += "<b>Be [capitalize(i)]:</b> <a href='?_src_=prefs;bancheck=[i]'>BANNED</a><br>"
				else
					var/days_remaining = null
					if(ispath(GLOB.special_roles[i]) && CONFIG_GET(flag/use_age_restriction_for_jobs)) //If it's a game mode antag, check if the player meets the minimum age
						var/mode_path = GLOB.special_roles[i]
						var/datum/game_mode/temp_mode = new mode_path
						days_remaining = temp_mode.get_remaining_days(user.client)

					if(days_remaining)
						dat += "<b>Be [capitalize(i)]:</b> <font color=red> \[IN [days_remaining] DAYS]</font><br>"
					// yogs start - Donor features
					else if(src.yogtoggles & QUIET_ROUND)
						dat += "<b>Be [capitalize(i)]:</b> <font color=blue><b>\[QUIET ROUND\]</b></font><br>"
					// yogs end
					else
						dat += "<b>Be [capitalize(i)]:</b> <a href='?_src_=prefs;preference=be_special;be_special_type=[i]'>[(i in be_special) ? "Enabled" : "Disabled"]</a><br>"
			dat += "<br>"
			dat += "<b>Midround Antagonist:</b> <a href='?_src_=prefs;preference=allow_midround_antag'>[(toggles & MIDROUND_ANTAG) ? "Enabled" : "Disabled"]</a><br>"

			// yogs start - Donor features
			if(is_donator(user.client))
				dat += "<b>Quiet round:</b> <a href='?_src_=prefs;preference=donor;task=quiet_round'>[(src.yogtoggles & QUIET_ROUND) ? "Yes" : "No"]</a><br>"
			// yogs end
			dat += "</td></tr></table>"
		if(2) //OOC Preferences
			dat += "<table><tr><td width='340px' height='300px' valign='top'>"
			dat += "<h2>OOC Settings</h2>"
			dat += "<b>Window Flashing:</b> <a href='?_src_=prefs;preference=winflash'>[(windowflashing) ? "Enabled":"Disabled"]</a><br>"
			dat += "<br>"
			dat += "<b>Play Admin MIDIs:</b> <a href='?_src_=prefs;preference=hear_midis'>[(toggles & SOUND_MIDI) ? "Enabled":"Disabled"]</a><br>"
			dat += "<b>Play Lobby Music:</b> <a href='?_src_=prefs;preference=lobby_music'>[(toggles & SOUND_LOBBY) ? "Enabled":"Disabled"]</a><br>"
			dat += "<b>See Pull Requests:</b> <a href='?_src_=prefs;preference=pull_requests'>[(chat_toggles & CHAT_PULLR) ? "Enabled":"Disabled"]</a><br>"
			dat += "<br>"


			if(user.client)
				if(unlock_content)
					dat += "<b>BYOND Membership Publicity:</b> <a href='?_src_=prefs;preference=publicity'>[(toggles & MEMBER_PUBLIC) ? "Public" : "Hidden"]</a><br>"

				if(unlock_content || check_rights_for(user.client, R_ADMIN))
					dat += "<b>OOC Color:</b> <span style='border: 1px solid #161616; background-color: [ooccolor ? ooccolor : GLOB.normal_ooc_colour];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=ooccolor;task=input'>Change</a><br>"

			dat += "</td>"

			if(user.client.holder)
				dat +="<td width='300px' height='300px' valign='top'>"

				dat += "<h2>Admin Settings</h2>"

				dat += "<b>Adminhelp Sounds:</b> <a href='?_src_=prefs;preference=hear_adminhelps'>[(toggles & SOUND_ADMINHELP)?"Enabled":"Disabled"]</a><br>"
				dat += "<b>Prayer Sounds:</b> <a href = '?_src_=prefs;preference=hear_prayers'>[(toggles & SOUND_PRAYERS)?"Enabled":"Disabled"]</a><br>"
				dat += "<b>Announce Login:</b> <a href='?_src_=prefs;preference=announce_login'>[(toggles & ANNOUNCE_LOGIN)?"Enabled":"Disabled"]</a><br>"
				dat += "<br>"
				dat += "<b>Combo HUD Lighting:</b> <a href = '?_src_=prefs;preference=combohud_lighting'>[(toggles & COMBOHUD_LIGHTING)?"Full-bright":"No Change"]</a><br>"
				dat += "<br>"
				dat += "<b>Hide Dead Chat:</b> <a href = '?_src_=prefs;preference=toggle_dead_chat'>[(chat_toggles & CHAT_DEAD)?"Shown":"Hidden"]</a><br>"
				dat += "<b>Hide Radio Messages:</b> <a href = '?_src_=prefs;preference=toggle_radio_chatter'>[(chat_toggles & CHAT_RADIO)?"Shown":"Hidden"]</a><br>"
				dat += "<b>Hide Prayers:</b> <a href = '?_src_=prefs;preference=toggle_prayers'>[(chat_toggles & CHAT_PRAYER)?"Shown":"Hidden"]</a><br>"
				if(CONFIG_GET(flag/allow_admin_asaycolor))
					dat += "<br>"
					dat += "<b>ASAY Color:</b> <span style='border: 1px solid #161616; background-color: [asaycolor ? asaycolor : "#FF4500"];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=asaycolor;task=input'>Change</a><br>"

				//deadmin
				dat += "<h2>Deadmin While Playing</h2>"
				if(CONFIG_GET(flag/auto_deadmin_players))
					dat += "<b>Always Deadmin:</b> FORCED</a><br>"
				else
					dat += "<b>Always Deadmin:</b> <a href = '?_src_=prefs;preference=toggle_deadmin_always'>[(toggles & DEADMIN_ALWAYS)?"Enabled":"Disabled"]</a><br>"
					if(!(toggles & DEADMIN_ALWAYS))
						dat += "<br>"
						if(!CONFIG_GET(flag/auto_deadmin_antagonists))
							dat += "<b>As Antag:</b> <a href = '?_src_=prefs;preference=toggle_deadmin_antag'>[(toggles & DEADMIN_ANTAGONIST)?"Deadmin":"Keep Admin"]</a><br>"
						else
							dat += "<b>As Antag:</b> FORCED<br>"

						if(!CONFIG_GET(flag/auto_deadmin_heads))
							dat += "<b>As Command:</b> <a href = '?_src_=prefs;preference=toggle_deadmin_head'>[(toggles & DEADMIN_POSITION_HEAD)?"Deadmin":"Keep Admin"]</a><br>"
						else
							dat += "<b>As Command:</b> FORCED<br>"

						if(!CONFIG_GET(flag/auto_deadmin_security))
							dat += "<b>As Security:</b> <a href = '?_src_=prefs;preference=toggle_deadmin_security'>[(toggles & DEADMIN_POSITION_SECURITY)?"Deadmin":"Keep Admin"]</a><br>"
						else
							dat += "<b>As Security:</b> FORCED<br>"

						if(!CONFIG_GET(flag/auto_deadmin_silicons))
							dat += "<b>As Silicon:</b> <a href = '?_src_=prefs;preference=toggle_deadmin_silicon'>[(toggles & DEADMIN_POSITION_SILICON)?"Deadmin":"Keep Admin"]</a><br>"
						else
							dat += "<b>As Silicon:</b> FORCED<br>"

						if(!CONFIG_GET(flag/auto_deadmin_critical))
							dat += "<b>As Critical Roles:</b> <a href = '?_src_=prefs;preference=toggle_deadmin_critical'>[(toggles & DEADMIN_POSITION_CRITICAL)?"Deadmin":"Keep Admin"]</a><br>"
						else
							dat += "<b>As Critical Roles:</b> FORCED<br>"

				dat += "</td>"
			dat += "</tr></table>"
		// yogs start - Donor features
		if (3) //Donator preferences
			dat += "<table><tr><td width='500px' height='300px' valign='top'>"
			dat += "<h2>Donator Preferences</h2>"
			if(is_donator(user.client))
				dat += "<b>Quiet round:</b> <a href='?_src_=prefs;preference=donor;task=quiet_round'>[(src.yogtoggles & QUIET_ROUND) ? "Yes" : "No"]</a><br>"
				dat += "Wear fancy hat as borg: "
				dat += "<a href='?_src_=prefs;preference=donor;task=borghat'>[borg_hat ? "Yes" : "No"]</a><br>"
				dat += "<b>Fancy Hat:</b> "
				///This is the typepath of the donor's hat that they may choose to spawn with.
				var/typehat = donor_hat
				var/temp_hat = donor_hat ? (new typehat()) : "None selected"
				dat += "<a href='?_src_=prefs;preference=donor;task=hat'>Pick</a> [temp_hat]<BR>"
				if(donor_hat)
					qdel(temp_hat)
				dat += "<b>Fancy Item:</b> "
				///Whatever item the donator has chosen to apply.
				var/typeitem = donor_item
				var/temp_item = donor_item ? (new typeitem()) : "None selected"
				dat += "<a href='?_src_=prefs;preference=donor;task=item'>Pick</a> [temp_item]<BR>"
				if(donor_item)
					qdel(temp_item)
				dat += "<b>Fancy PDA:</b> "
				dat += "<a href='?_src_=prefs;preference=donor;task=pda'>[GLOB.donor_pdas[donor_pda]]</a><BR>"
				dat += "<b>Purrbation (Humans only)</b> "
				dat += "<a href='?_src_=prefs;preference=donor;task=purrbation'>[purrbation ? "Yes" : "No"]</a><BR>"
			else
				dat += "<b><a href='http://www.yogstation.net/donate'>Donate here</b>"
			dat += "</tr></table>"
		// yogs end

		// yogs start - Custom keybindings
		if (4) // Keybindings
			dat += "<center><a href='?_src_=prefs;preference=hotkeys'>[(hotkeys) ? "Hotkeys" : "Default"]</a>"
			dat += "<a href='?_src_=prefs;preference=reset_bindings'>Reset to default</a></center>"
			if(hotkeys)
				var/button
				var/button_bound

				dat += "<table><tr><td width='340px' height='300px' valign='top'>"
				dat += "<h2>Client</h2>"
				BUTTON_KEY_MOVEMENT("Move North (up)", ACTION_MOVENORTH, NORTH)
				BUTTON_KEY_MOVEMENT("Move West (left)", ACTION_MOVEWEST, WEST)
				BUTTON_KEY_MOVEMENT("Move South (down)", ACTION_MOVESOUTH, SOUTH)
				BUTTON_KEY_MOVEMENT("Move East (right)", ACTION_MOVEEAST, EAST)

				BUTTON_KEY("OOC", ACTION_OOC)
				BUTTON_KEY("LOOC", ACTION_LOOC)
				BUTTON_KEY("Adminhelp", ACTION_AHELP)
				BUTTON_KEY("Screenshot", ACTION_SCREENSHOT)
				BUTTON_KEY("Minimal HUD", ACTION_MINHUD)


				dat += "<h2>Mob</h2>"
				BUTTON_KEY("Say", ACTION_SAY)
				BUTTON_KEY("Emote", ACTION_ME)
				BUTTON_KEY("Stop pulling", ACTION_STOPPULLING)
				BUTTON_KEY("Cycle intent clockwise", ACTION_INTENTRIGHT)
				BUTTON_KEY("Cycle intent counter-clockwise", ACTION_INTENTLEFT)
				BUTTON_KEY("Swap hands", ACTION_SWAPHAND)
				BUTTON_KEY("Use item on self", ACTION_USESELF)
				BUTTON_KEY("Drop", ACTION_DROP)
				BUTTON_KEY("Equip", ACTION_EQUIP)
				BUTTON_KEY("Rest", ACTION_REST)
				BUTTON_KEY("Toggle Walk Run", ACTION_TOGGLEWALKRUN)

				dat += "</td><td width='300px' height='300px' valign='top'>"

				dat += "<h2>Mob</h2>"
				BUTTON_KEY("Target head", ACTION_TARGETHEAD)
				BUTTON_KEY("Target right arm", ACTION_TARGETRARM)
				BUTTON_KEY("Target chest", ACTION_TARGETCHEST)
				BUTTON_KEY("Target left arm", ACTION_TARGETLARM)
				BUTTON_KEY("Target right leg", ACTION_TARGETRLEG)
				BUTTON_KEY("Target groin", ACTION_TARGETGROIN)
				BUTTON_KEY("Target left leg", ACTION_TARGETLLEG)
				BUTTON_KEY("Offer item", ACTION_GIVE)
				BUTTON_KEY("Resist", ACTION_RESIST)
				BUTTON_KEY("Toggle throw", ACTION_TOGGLETHROW)
				BUTTON_KEY("Help intent", ACTION_INTENTHELP)
				BUTTON_KEY("Disarm intent", ACTION_INTENTDISARM)
				BUTTON_KEY("Grab intent", ACTION_INTENTGRAB)
				BUTTON_KEY("Harm intent", ACTION_INTENTHARM)

				if(parent)
					if(parent.mentor_datum)
						dat += "<h2>Mentor</h2>"
						BUTTON_KEY("Mentorsay", ACTION_MENTORCHAT)

					if(parent.holder)
						dat += "<h2>Admin</h2>"
						BUTTON_KEY("Adminchat", ACTION_ASAY)
						BUTTON_KEY("Admin ghost", ACTION_AGHOST)
						BUTTON_KEY("Player panel", ACTION_PLAYERPANEL)
						BUTTON_KEY("Toggle build mode", ACTION_BUILDMODE)
						BUTTON_KEY("Stealth mode", ACTION_STEALTHMIN)
						BUTTON_KEY("Deadchat", ACTION_DSAY)

				dat += "</td></tr></table>"
			else
				dat += "<b>Default keybindings selected</b>"
		// yogs end
	dat += "<hr><center>"

	if(!IsGuestKey(user.key))
		dat += "<a href='?_src_=prefs;preference=load'>Undo</a> "
		dat += "<a href='?_src_=prefs;preference=save'>Save Setup</a> "

	dat += "<a href='?_src_=prefs;preference=reset_all'>Reset Setup</a>"
	dat += "</center>"

	winshow(user, "preferences_window", TRUE)
	var/datum/browser/popup = new(user, "preferences_browser", "<div align='center'>Character Setup</div>", 640, 770)
	popup.set_content(dat.Join())
	popup.open(FALSE)
	onclose(user, "preferences_window", src)

#undef APPEARANCE_CATEGORY_COLUMN
#undef MAX_MUTANT_ROWS

/datum/preferences/proc/SetChoices(mob/user, limit = 17, list/splitJobs = list("Research Director", "Head of Personnel"), widthPerColumn = 295, height = 620)
	if(!SSjob)
		return

	//limit - The amount of jobs allowed per column. Defaults to 17 to make it look nice.
	//splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads. Defaults to CE to make it look nice.
	//widthPerColumn - Screen's width for every column.
	//height - Screen's height.

	var/width = widthPerColumn

	var/HTML = "<center>"
	if(SSjob.occupations.len <= 0)
		HTML += "The job SSticker is not yet finished creating jobs, please try again later"
		HTML += "<center><a href='?_src_=prefs;preference=job;task=close'>Done</a></center><br>" // Easier to press up here.

	else
		HTML += "<b>Choose occupation chances</b><br>"
		HTML += "<div align='center'>Left-click to raise an occupation preference, right-click to lower it.<br></div>"
		HTML += "<center><a href='?_src_=prefs;preference=job;task=close'>Done</a></center><br>" // Easier to press up here.
		HTML += "<script type='text/javascript'>function setJobPrefRedirect(level, rank) { window.location.href='?_src_=prefs;preference=job;task=setJobLevel;level=' + level + ';text=' + encodeURIComponent(rank); return false; }</script>"
		HTML += "<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more colomns.
		HTML += "<table width='100%' cellpadding='1' cellspacing='0'>"
		var/index = -1

		//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
		var/datum/job/lastJob

		var/datum/job/overflow = SSjob.GetJob(SSjob.overflow_role)

		for(var/datum/job/job in sortList(SSjob.occupations, /proc/cmp_job_display_asc))

			index += 1
			if((index >= limit) || (job.title in splitJobs))
				width += widthPerColumn
				if((index < limit) && (lastJob != null))
					//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
					//the last job's selection color. Creating a rather nice effect.
					for(var/i = 0, i < (limit - index), i += 1)
						HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"
				HTML += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
				index = 0

			HTML += "<tr bgcolor='[job.selection_color]'><td width='60%' align='right'>"
			var/rank = job.title
			lastJob = job
			if(is_banned_from(user.ckey, rank))
				HTML += "<font color=red>[rank]</font></td><td><a href='?_src_=prefs;bancheck=[rank]'> BANNED</a></td></tr>"
				continue
			var/required_playtime_remaining = job.required_playtime_remaining(user.client)
			if(required_playtime_remaining)
				HTML += "<font color=red>[rank]</font></td><td><font color=red> \[ [get_exp_format(required_playtime_remaining)] as [job.get_exp_req_type()] \] </font></td></tr>"
				continue
			if(!job.player_old_enough(user.client))
				var/available_in_days = job.available_in_days(user.client)
				HTML += "<font color=red>[rank]</font></td><td><font color=red> \[IN [(available_in_days)] DAYS\]</font></td></tr>"
				continue
			if((job_preferences[overflow] == JP_LOW) && (rank != SSjob.overflow_role) && !is_banned_from(user.ckey, SSjob.overflow_role))
				HTML += "<font color=orange>[rank]</font></td><td></td></tr>"
				continue
			// yogs start - Donor features, quiet round
			if(((rank in GLOB.command_positions) || (rank in GLOB.nonhuman_positions)) && (src.yogtoggles & QUIET_ROUND))
				HTML += "<font color=blue>[rank]</font></td><td><font color=blue><b> \[QUIET\]</b></font></td></tr>"
				continue
			// yogs end

			var/rank_display
			if(job.alt_titles)
				rank_display = "<a class='white' href='?_src_=prefs;preference=job;task=alt_title;job=[rank]'>[GetPlayerAltTitle(job)]</a>"
			else
				rank_display = span_dark("[rank]")

			if((rank in GLOB.command_positions) || (rank == "AI"))//Bold head jobs
				HTML += "<b>[rank_display]</b>"
			else
				HTML += rank_display

			HTML += "</td><td width='40%'>"

			var/prefLevelLabel = "ERROR"
			var/prefLevelColor = "pink"
			var/prefUpperLevel = -1 // level to assign on left click
			var/prefLowerLevel = -1 // level to assign on right click

			switch(job_preferences[job.title])
				if(JP_HIGH)
					prefLevelLabel = "High"
					prefLevelColor = "slateblue"
					prefUpperLevel = 4
					prefLowerLevel = 2
				if(JP_MEDIUM)
					prefLevelLabel = "Medium"
					prefLevelColor = "green"
					prefUpperLevel = 1
					prefLowerLevel = 3
				if(JP_LOW)
					prefLevelLabel = "Low"
					prefLevelColor = "orange"
					prefUpperLevel = 2
					prefLowerLevel = 4
				else
					prefLevelLabel = "NEVER"
					prefLevelColor = "red"
					prefUpperLevel = 3
					prefLowerLevel = 1

			HTML += "<a class='white' href='?_src_=prefs;preference=job;task=setJobLevel;level=[prefUpperLevel];text=[rank]' oncontextmenu='javascript:return setJobPrefRedirect([prefLowerLevel], \"[rank]\");'>"

			if(rank == SSjob.overflow_role)//Overflow is special
				if(job_preferences[overflow.title] == JP_LOW)
					HTML += "<font color=green>Yes</font>"
				else
					HTML += "<font color=red>No</font>"
				HTML += "</a></td></tr>"
				continue

			HTML += "<font color=[prefLevelColor]>[prefLevelLabel]</font>"
			HTML += "</a></td></tr>"

		for(var/i = 1, i < (limit - index), i += 1) // Finish the column so it is even
			HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"

		HTML += "</td'></tr></table>"
		HTML += "</center></table>"

		var/message = "Be an [SSjob.overflow_role] if preferences unavailable"
		if(joblessrole == BERANDOMJOB)
			message = "Get random job if preferences unavailable"
		else if(joblessrole == RETURNTOLOBBY)
			message = "Return to lobby if preferences unavailable"
		HTML += "<center><br><a href='?_src_=prefs;preference=job;task=random'>[message]</a></center>"
		HTML += "<center><a href='?_src_=prefs;preference=job;task=reset'>Reset Preferences</a></center>"

	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Occupation Preferences</div>", width, height)
	popup.set_window_options("can_close=0")
	popup.set_content(HTML)
	popup.open(FALSE)

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

/datum/preferences/proc/SetJobPreferenceLevel(datum/job/job, level)
	if (!job)
		return FALSE

	if (level == JP_HIGH) // to high
		//Set all other high to medium
		for(var/j in job_preferences)
			if(job_preferences[j] == JP_HIGH)
				job_preferences[j] = JP_MEDIUM
				//technically break here

	job_preferences[job.title] = level
	return TRUE

/datum/preferences/proc/UpdateJobPreference(mob/user, role, desiredLvl)
	if(!SSjob || SSjob.occupations.len <= 0)
		return
	var/datum/job/job = SSjob.GetJob(role)

	if(!job)
		user << browse(null, "window=mob_occupation")
		ShowChoices(user)
		return

	if (!isnum(desiredLvl))
		to_chat(user, span_danger("UpdateJobPreference - desired level was not a number. Please notify coders!"))
		ShowChoices(user)
		return

	var/jpval = null
	switch(desiredLvl)
		if(3)
			jpval = JP_LOW
		if(2)
			jpval = JP_MEDIUM
		if(1)
			jpval = JP_HIGH

	if(role == SSjob.overflow_role)
		if(job_preferences[job.title] == JP_LOW)
			jpval = null
		else
			jpval = JP_LOW

	SetJobPreferenceLevel(job, jpval)
	SetChoices(user)

	return 1


/datum/preferences/proc/ResetJobs()
	job_preferences = list()

/datum/preferences/proc/SetQuirks(mob/user)
	if(!SSquirks)
		to_chat(user, span_danger("The quirk subsystem is still initializing! Try again in a minute."))
		return

	var/list/dat = list()
	if(!SSquirks.quirks.len)
		dat += "The quirk subsystem hasn't finished initializing, please hold..."
		dat += "<center><a href='?_src_=prefs;preference=trait;task=close'>Done</a></center><br>"
	else
		dat += "<center><b>Choose quirk setup</b></center><br>"
		dat += "<div align='center'>Left-click to add or remove quirks. You need negative quirks to have positive ones.<br>\
		Quirks are applied at roundstart and cannot normally be removed.</div>"
		dat += "<center><a href='?_src_=prefs;preference=trait;task=close'>Done</a></center>"
		dat += "<hr>"
		dat += "<center><b>Current quirks:</b> [all_quirks.len ? all_quirks.Join(", ") : "None"]</center>"
		dat += "<center>[GetPositiveQuirkCount()] / [MAX_QUIRKS] max positive quirks<br>\
		<b>Quirk balance remaining:</b> [GetQuirkBalance()]</center><br>"
		for(var/V in SSquirks.quirks)
			var/datum/quirk/T = SSquirks.quirks[V]
			var/quirk_name = initial(T.name)
			var/has_quirk
			var/quirk_cost = initial(T.value) * -1
			var/lock_reason = FALSE // Also marks whether this quirk ought to be locked at all; FALSE implies it's OK for this person to have this quirk
			for(var/_V in all_quirks)
				if(_V == quirk_name)
					has_quirk = TRUE
			if(initial(T.mood_quirk) && (CONFIG_GET(flag/disable_human_mood) && !(yogtoggles & PREF_MOOD)))//Yogs -- Adds mood to preferences
				lock_reason = "Mood is disabled."
			else
				var/datum/quirk/t = new T(no_init = TRUE)
				lock_reason = t.check_quirk(src) // Yogs -- allows for specific denial of quirks based on current preferences
				qdel(t)
			if(has_quirk)
				if(lock_reason)
					all_quirks -= quirk_name
					has_quirk = FALSE
				else
					quirk_cost *= -1 //invert it back, since we'd be regaining this amount
			if(quirk_cost > 0)
				quirk_cost = "+[quirk_cost]"
			var/font_color = "#AAAAFF"
			if(initial(T.value) != 0)
				font_color = initial(T.value) > 0 ? "#AAFFAA" : "#FFAAAA"
			if(lock_reason)
				dat += "<font color='[font_color]'>[quirk_name]</font> - [initial(T.desc)] \
				<font color='red'><b>LOCKED: [lock_reason]</b></font><br>"
			else
				if(has_quirk)
					dat += "<a href='?_src_=prefs;preference=trait;task=update;trait=[quirk_name]'>[has_quirk ? "Remove" : "Take"] ([quirk_cost] pts.)</a> \
					<b><font color='[font_color]'>[quirk_name]</font></b> - [initial(T.desc)]<br>"
				else
					dat += "<a href='?_src_=prefs;preference=trait;task=update;trait=[quirk_name]'>[has_quirk ? "Remove" : "Take"] ([quirk_cost] pts.)</a> \
					<font color='[font_color]'>[quirk_name]</font> - [initial(T.desc)]<br>"
		dat += "<br><center><a href='?_src_=prefs;preference=trait;task=reset'>Reset Quirks</a></center>"

	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Quirk Preferences</div>", 900, 600) //no reason not to reuse the occupation window, as it's cleaner that way
	popup.set_window_options("can_close=0")
	popup.set_content(dat.Join())
	popup.open(FALSE)

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

/datum/preferences/Topic(href, href_list, hsrc)			//yeah, gotta do this I guess..
	. = ..()
	if(href_list["close"])
		var/client/C = usr.client
		if(C)
			C.clear_character_previews()

/datum/preferences/proc/process_link(mob/user, list/href_list)
	// yogs start - Donor features
	if(href_list["preference"] == "donor")
		if(is_donator(user))
			var/client/C = (istype(user, /client)) ? user : user.client
			switch(href_list["task"])
				if("borghat")
					borg_hat = !borg_hat
				if("hat")
					C.custom_donator_item()
				if("item")
					C.custom_donator_item()
				if("quiet_round")
					yogtoggles ^= QUIET_ROUND
				if("pda")
					donor_pda = (donor_pda % GLOB.donor_pdas.len) + 1
				if("purrbation")
					purrbation = !purrbation
		else
			message_admins("EXPLOIT \[donor\]: [user] tried to access donor only functions (as a non-donor). Attempt made on \"[href_list["preference"]]\" -> \"[href_list["task"]]\".")
	// yogs end
	if(href_list["bancheck"])
		var/list/ban_details = is_banned_from_with_details(user.ckey, user.client.address, user.client.computer_id, href_list["bancheck"])
		var/admin = FALSE
		if(GLOB.permissions.admin_datums[user.ckey] || GLOB.permissions.deadmins[user.ckey])
			admin = TRUE
		for(var/i in ban_details)
			if(admin && !text2num(i["applies_to_admins"]))
				continue
			ban_details = i
			break //we only want to get the most recent ban's details
		if(ban_details && ban_details.len)
			var/expires = "This is a permanent ban."
			if(ban_details["expiration_time"])
				expires = " The ban is for [DisplayTimeText(text2num(ban_details["duration"]) MINUTES)] and expires on [ban_details["expiration_time"]] (server time)."
			to_chat(user, span_danger("You, or another user of this computer or connection ([ban_details["key"]]) is banned from playing [href_list["bancheck"]].<br>The ban reason is: [ban_details["reason"]]<br>This ban (BanID #[ban_details["id"]]) was applied by [ban_details["admin_key"]] on [ban_details["bantime"]] during round ID [ban_details["round_id"]].<br>[expires]"))
			return
	if(href_list["preference"] == "job")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				ShowChoices(user)
			if("reset")
				ResetJobs()
				SetChoices(user)
			if("random")
				switch(joblessrole)
					if(RETURNTOLOBBY)
						if(is_banned_from(user.ckey, SSjob.overflow_role))
							joblessrole = BERANDOMJOB
						else
							joblessrole = BEOVERFLOW
					if(BEOVERFLOW)
						joblessrole = BERANDOMJOB
					if(BERANDOMJOB)
						joblessrole = RETURNTOLOBBY
				SetChoices(user)
			if ("alt_title")
				var/datum/job/job = SSjob.GetJob(href_list["job"])
				if (job)
					var/choices = list(job.title) + job.alt_titles
					var/choice = input("Pick a title for [job.title].", "Character Generation", GetPlayerAltTitle(job)) as anything in choices | null
					if(choice)
						SetPlayerAltTitle(job, choice)
						SetChoices(user)
			if("setJobLevel")
				UpdateJobPreference(user, href_list["text"], text2num(href_list["level"]))
			else
				SetChoices(user)
		return 1

	else if(href_list["preference"] == "trait")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				ShowChoices(user)
			if("update")
				var/quirk = href_list["trait"]
				if(!SSquirks.quirks[quirk])
					return
				for(var/V in SSquirks.quirk_blacklist) //V is a list
					var/list/L = V
					for(var/Q in all_quirks)
						if((quirk in L) && (Q in L) && !(Q == quirk)) //two quirks have lined up in the list of the list of quirks that conflict with each other, so return (see quirks.dm for more details)
							to_chat(user, span_danger("[quirk] is incompatible with [Q]."))
							return
				var/value = SSquirks.quirk_points[quirk] // The value of the chosen quirk.
				var/balance = GetQuirkBalance()
				if(quirk in all_quirks)
					if(balance + value < 0)
						to_chat(user, span_warning("Refunding this would cause you to go below your balance!"))
						return
					all_quirks -= quirk
				else
					var/positive_count = GetPositiveQuirkCount() // Yogs -- fixes weird behaviour when at max positive quirks
					if(positive_count > MAX_QUIRKS || (positive_count == MAX_QUIRKS && value > 0)) // Yogs
						to_chat(user, span_warning("You can't have more than [MAX_QUIRKS] positive quirks!"))
						return
					if(balance - value < 0)
						to_chat(user, span_warning("You don't have enough balance to gain this quirk!"))
						return
					all_quirks += quirk
				SetQuirks(user)
			if("reset")
				all_quirks = list()
				SetQuirks(user)
			else
				SetQuirks(user)
		return TRUE

	switch(href_list["task"])
		if("random")
			switch(href_list["preference"])
				if("name")
					real_name = pref_species.random_name(gender,1)
				if("age")
					age = rand(AGE_MIN, AGE_MAX)
				if("hair")
					hair_color = random_short_color()
				if("hair_style")
					hair_style = random_hair_style(gender)
				if("facial")
					facial_hair_color = random_short_color()
				if("facial_hair_style")
					facial_hair_style = random_facial_hair_style(gender)
				if("underwear")
					underwear = random_underwear(gender)
				if("undershirt")
					undershirt = random_undershirt(gender)
				if("socks")
					socks = random_socks()
				if(BODY_ZONE_PRECISE_EYES)
					eye_color = random_eye_color()
				if("s_tone")
					skin_tone = random_skin_tone()
				if("bag")
					backbag = pick(GLOB.backbaglist)
				if("all")
					random_character(gender)
		if("lock")
			switch(href_list["preference"])
				if("u_all")
					for(var/i in random_locks)
						random_locks[i] = 0;
				if("l_all")
					random_locks = list(
						"gender" = gender,
						"mcolor" = 1,
						"ethcolor" = 1,
						"tail_lizard" = 1,
						"tail_human" = 1,
						"wings" = 1,
						"snout" = 1,
						"horns" = 1,
						"ears" = 1,
						"frills" = 1,
						"spines" = 1,
						"body_markings" = 1,
						"legs" = 1,
						"caps" = 1,
						"moth_wings" = 1,
						"tail_polysmorph" = 1,
						"teeth" = 1,
						"dome" = 1,
						"dorsal_tubes" = 1,
						"ethereal_mark" = 1,
					)
				if("gender")
					random_locks["random_locks"] = gender
				else
					random_locks[href_list["preference"]] = !random_locks[href_list["preference"]]

		if("input")

			if(href_list["preference"] in GLOB.preferences_custom_names)
				ask_for_custom_name(user,href_list["preference"])


			switch(href_list["preference"])
				if("ghostform")
					if(unlock_content)
						var/new_form = input(user, "Thanks for supporting BYOND - Choose your ghostly form:","Thanks for supporting BYOND",null) as null|anything in GLOB.ghost_forms
						if(new_form)
							ghost_form = new_form
				if("ghostorbit")
					if(unlock_content)
						var/new_orbit = input(user, "Thanks for supporting BYOND - Choose your ghostly orbit:","Thanks for supporting BYOND", null) as null|anything in GLOB.ghost_orbits
						if(new_orbit)
							ghost_orbit = new_orbit

				if("ghostaccs")
					var/new_ghost_accs = alert("Do you want your ghost to show full accessories where possible, hide accessories but still use the directional sprites where possible, or also ignore the directions and stick to the default sprites?",,GHOST_ACCS_FULL_NAME, GHOST_ACCS_DIR_NAME, GHOST_ACCS_NONE_NAME)
					switch(new_ghost_accs)
						if(GHOST_ACCS_FULL_NAME)
							ghost_accs = GHOST_ACCS_FULL
						if(GHOST_ACCS_DIR_NAME)
							ghost_accs = GHOST_ACCS_DIR
						if(GHOST_ACCS_NONE_NAME)
							ghost_accs = GHOST_ACCS_NONE

				if("ghostothers")
					var/new_ghost_others = alert("Do you want the ghosts of others to show up as their own setting, as their default sprites or always as the default white ghost?",,GHOST_OTHERS_THEIR_SETTING_NAME, GHOST_OTHERS_DEFAULT_SPRITE_NAME, GHOST_OTHERS_SIMPLE_NAME)
					switch(new_ghost_others)
						if(GHOST_OTHERS_THEIR_SETTING_NAME)
							ghost_others = GHOST_OTHERS_THEIR_SETTING
						if(GHOST_OTHERS_DEFAULT_SPRITE_NAME)
							ghost_others = GHOST_OTHERS_DEFAULT_SPRITE
						if(GHOST_OTHERS_SIMPLE_NAME)
							ghost_others = GHOST_OTHERS_SIMPLE

				if("name")
					var/new_name = input(user, "Choose your character's name:", "Character Preference")  as text|null
					if(new_name)
						new_name = reject_bad_name(new_name, pref_species.allow_numbers_in_name)
						if(new_name)
							real_name = new_name
						else
							to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")

				if("age")
					var/new_age = input(user, "Choose your character's age:\n([AGE_MIN]-[AGE_MAX])", "Character Preference") as num|null
					if(new_age)
						age = max(min( round(text2num(new_age)), AGE_MAX),AGE_MIN)

				if("cycle_background")
					background = next_list_item(background, background_options)

				if("hair")
					var/new_hair = input(user, "Choose your character's hair colour:", "Character Preference","#"+hair_color) as color|null
					if(new_hair)
						hair_color = sanitize_hexcolor(new_hair)

				if("hair_style")
					var/new_hair_style
					if(gender == MALE)
						new_hair_style = input(user, "Choose your character's hair style:", "Character Preference")  as null|anything in GLOB.hair_styles_male_list
					else if(gender == FEMALE)
						new_hair_style = input(user, "Choose your character's hair style:", "Character Preference")  as null|anything in GLOB.hair_styles_female_list
					else
						new_hair_style = input(user, "Choose your character's hair style:", "Character Preference")  as null|anything in GLOB.hair_styles_list
					if(new_hair_style)
						hair_style = new_hair_style

				if("next_hair_style")
					if (gender == MALE)
						hair_style = next_list_item(hair_style, GLOB.hair_styles_male_list)
					else if(gender == FEMALE)
						hair_style = next_list_item(hair_style, GLOB.hair_styles_female_list)
					else
						hair_style = next_list_item(hair_style, GLOB.hair_styles_list)

				if("previous_hair_style")
					if (gender == MALE)
						hair_style = previous_list_item(hair_style, GLOB.hair_styles_male_list)
					else if(gender == FEMALE)
						hair_style = previous_list_item(hair_style, GLOB.hair_styles_female_list)
					else
						hair_style = previous_list_item(hair_style, GLOB.hair_styles_list)

				if("facial")
					var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character Preference","#"+facial_hair_color) as color|null
					if(new_facial)
						facial_hair_color = sanitize_hexcolor(new_facial)

				if("facial_hair_style")
					var/new_facial_hair_style
					if(gender == MALE)
						new_facial_hair_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in GLOB.facial_hair_styles_male_list
					else if(gender == FEMALE)
						new_facial_hair_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in GLOB.facial_hair_styles_female_list
					else
						new_facial_hair_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in GLOB.facial_hair_styles_list
					if(new_facial_hair_style)
						facial_hair_style = new_facial_hair_style

				if("next_facehair_style")
					if (gender == MALE)
						facial_hair_style = next_list_item(facial_hair_style, GLOB.facial_hair_styles_male_list)
					else if(gender == FEMALE)
						facial_hair_style = next_list_item(facial_hair_style, GLOB.facial_hair_styles_female_list)
					else
						facial_hair_style = next_list_item(facial_hair_style, GLOB.facial_hair_styles_list)

				if("previous_facehair_style")
					if (gender == MALE)
						facial_hair_style = previous_list_item(facial_hair_style, GLOB.facial_hair_styles_male_list)
					else if (gender == FEMALE)
						facial_hair_style = previous_list_item(facial_hair_style, GLOB.facial_hair_styles_female_list)
					else
						facial_hair_style = previous_list_item(facial_hair_style, GLOB.facial_hair_styles_list)

				if("hair_gradient")
					var/new_hair_gradient_color = input(user, "Choose your character's hair gradient colour:", "Character Preference","#"+features["gradientcolor"]) as color|null
					if(new_hair_gradient_color)
						features["gradientcolor"] = sanitize_hexcolor(new_hair_gradient_color)

				if("hair_gradient_style")
					var/new_gradient_style
					new_gradient_style = input(user, "Choose your character's hair gradient style:", "Character Preference")  as null|anything in GLOB.hair_gradients_list
					if(new_gradient_style)
						features["gradientstyle"] = new_gradient_style

				if("next_hair_gradient_style")
					features["gradientstyle"] = next_list_item(features["gradientstyle"], GLOB.hair_gradients_list)

				if("previous_hair_gradient_style")
					features["gradientstyle"] = previous_list_item(features["gradientstyle"], GLOB.hair_gradients_list)

				if("underwear")
					var/new_underwear
					if(gender == MALE)
						new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in GLOB.underwear_m
					else if(gender == FEMALE)
						new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in GLOB.underwear_f
					else
						new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in GLOB.underwear_list
					if(new_underwear)
						underwear = new_underwear

				if("undershirt")
					var/new_undershirt
					if(gender == MALE)
						new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in GLOB.undershirt_m
					else if(gender == FEMALE)
						new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in GLOB.undershirt_f
					else
						new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in GLOB.undershirt_list
					if(new_undershirt)
						undershirt = new_undershirt

				if("socks")
					var/new_socks
					new_socks = input(user, "Choose your character's socks:", "Character Preference") as null|anything in GLOB.socks_list
					if(new_socks)
						socks = new_socks

				if(BODY_ZONE_PRECISE_EYES)
					var/new_eyes = input(user, "Choose your character's eye colour:", "Character Preference","#"+eye_color) as color|null
					if(new_eyes)
						eye_color = sanitize_hexcolor(new_eyes)

				if("species")

					var/result = input(user, "Select a species", "Species Selection") as null|anything in (is_mentor(user) ? (GLOB.roundstart_races + GLOB.mentor_races) : GLOB.roundstart_races)

					if(result)
						var/newtype = GLOB.species_list[result]
						pref_species = new newtype()
						//Now that we changed our species, we must verify that the mutant colour is still allowed.
						var/temp_hsv = RGBtoHSV(features["mcolor"])
						if(features["mcolor"] == "#000" || (!(MUTCOLORS_PARTSONLY in pref_species.species_traits) && ReadHSV(temp_hsv)[3] < ReadHSV("#7F7F7F")[3]))
							features["mcolor"] = pref_species.default_color
						var/CQ
						for(var/Q in all_quirks)
							var/quirk_type = SSquirks.quirks[Q]
							var/datum/quirk/quirk = new quirk_type(no_init = TRUE)
							CQ = quirk.check_quirk(src)
							if(CQ)
								all_quirks -= Q
								to_chat(user, span_danger(CQ))
								if(GetQuirkBalance() < 0)
									to_chat(user, span_danger("Your quirk balance is now negative, and you will need to re-balance it or all quirks will be disabled."))

				if("mcolor")
					var/new_mutantcolor = input(user, "Choose your character's alien/mutant color:", "Character Preference","#"+features["mcolor"]) as color|null
					if(new_mutantcolor)
						var/temp_hsv = RGBtoHSV(new_mutantcolor)
						if(new_mutantcolor == "#000000")
							features["mcolor"] = pref_species.default_color
						else if((MUTCOLORS_PARTSONLY in pref_species.species_traits) || ReadHSV(temp_hsv)[3] >= ReadHSV("#7F7F7F")[3]) // mutantcolors must be bright, but only if they affect the skin
							features["mcolor"] = sanitize_hexcolor(new_mutantcolor)
						else
							to_chat(user, span_danger("Invalid color. Your color is not bright enough."))

				if("ethcolor")
					var/new_etherealcolor = input(user, "Choose your ethereal color", "Character Preference") as null|anything in GLOB.color_list_ethereal
					if(new_etherealcolor)
						features["ethcolor"] = GLOB.color_list_ethereal[new_etherealcolor]

				if("tail_lizard")
					var/new_tail
					new_tail = input(user, "Choose your character's tail:", "Character Preference") as null|anything in GLOB.tails_list_lizard
					if(new_tail)
						features["tail_lizard"] = new_tail

				if("tail_polysmorph")
					var/new_tail
					new_tail = input(user, "Choose your character's tail:", "Character Preference") as null|anything in GLOB.tails_list_polysmorph
					if(new_tail)
						features["tail_polysmorph"] = new_tail

				if("tail_human")
					var/new_tail
					new_tail = input(user, "Choose your character's tail:", "Character Preference") as null|anything in GLOB.tails_list_human
					if(new_tail)
						features["tail_human"] = new_tail

				if("snout")
					var/new_snout
					new_snout = input(user, "Choose your character's snout:", "Character Preference") as null|anything in GLOB.snouts_list
					if(new_snout)
						features["snout"] = new_snout

				if("horns")
					var/new_horns
					new_horns = input(user, "Choose your character's horns:", "Character Preference") as null|anything in GLOB.horns_list
					if(new_horns)
						features["horns"] = new_horns

				if("ears")
					var/new_ears
					new_ears = input(user, "Choose your character's ears:", "Character Preference") as null|anything in GLOB.ears_list
					if(new_ears)
						features["ears"] = new_ears

				if("wings")
					var/new_wings
					new_wings = input(user, "Choose your character's wings:", "Character Preference") as null|anything in GLOB.r_wings_list
					if(new_wings)
						features["wings"] = new_wings

				if("frills")
					var/new_frills
					new_frills = input(user, "Choose your character's frills:", "Character Preference") as null|anything in GLOB.frills_list
					if(new_frills)
						features["frills"] = new_frills

				if("spines")
					var/new_spines
					new_spines = input(user, "Choose your character's spines:", "Character Preference") as null|anything in GLOB.spines_list
					if(new_spines)
						features["spines"] = new_spines

				if("body_markings")
					var/new_body_markings
					new_body_markings = input(user, "Choose your character's body markings:", "Character Preference") as null|anything in GLOB.body_markings_list
					if(new_body_markings)
						features["body_markings"] = new_body_markings

				if("legs")
					var/new_legs
					new_legs = input(user, "Choose your character's legs:", "Character Preference") as null|anything in GLOB.legs_list
					if(new_legs)
						features["legs"] = new_legs

				if("moth_wings")
					var/new_moth_wings
					new_moth_wings = input(user, "Choose your character's wings:", "Character Preference") as null|anything in GLOB.moth_wings_list
					if(new_moth_wings)
						features["moth_wings"] = new_moth_wings

				if("teeth")
					var/new_teeth
					new_teeth = input(user, "Choose your character's teeth:", "Character Preference") as null|anything in GLOB.teeth_list
					if(new_teeth)
						features["teeth"] = new_teeth

				if("dome")
					var/new_dome
					new_dome = input(user, "Choose your character's dome:", "Character Preference") as null|anything in GLOB.dome_list
					if(new_dome)
						features["dome"] = new_dome

				if("dorsal_tubes")
					var/new_dorsal_tubes
					new_dorsal_tubes = input(user, "Choose if your character has dorsal tubes:", "Character Preference") as null|anything in GLOB.dorsal_tubes_list
					if(new_dorsal_tubes)
						features["dorsal_tubes"] = new_dorsal_tubes

				if("ethereal_mark")
					var/new_ethereal_mark
					new_ethereal_mark = input(user, "Choose if your character has a facial mark", "Character Preference") as null|anything in GLOB.ethereal_mark_list
					if(new_ethereal_mark)
						features["ethereal_mark"] = new_ethereal_mark

				if("pod_hair")
					var/new_pod_hair
					new_pod_hair = input(user, "Choose the style of your head vegitation", "Character Preference") as null|anything in GLOB.pod_hair_list
					if(new_pod_hair)
						features["pod_hair"] = new_pod_hair
						features["pod_flower"] = new_pod_hair
				if("pod_hair_color")
					var/new_hair = input(user, "Choose your character's \"hair\" colour:", "Character Preference","#"+hair_color) as color|null
					if(new_hair)
						var/temp_hsv = RGBtoHSV(new_hair)
						if(new_hair == "#000000")
							hair_color = pref_species.default_color
							to_chat(user, span_danger("Invalid \"hair\" color. Your color is not bright enough."))
						else if(ReadHSV(temp_hsv)[3] >= ReadHSV("#7F7F7F")[3]) // mutantcolors must be bright, but only if they affect the skin
							hair_color = sanitize_hexcolor(new_hair)
						else
							to_chat(user, span_danger("Invalid \"hair\" color. Your color is not bright enough."))
				if("pod_flower_color")
					var/new_facial = input(user, "Choose your character's head flower colour:", "Character Preference","#"+facial_hair_color) as color|null
					if(new_facial)
						var/temp_hsv = RGBtoHSV(new_facial)
						if(new_facial == "#000000")
							facial_hair_color = pref_species.default_color
							to_chat(user, span_danger("Invalid \"hair\" color. Your color is not bright enough."))
						else if(ReadHSV(temp_hsv)[3] >= ReadHSV("#7F7F7F")[3]) // mutantcolors must be bright, but only if they affect the skin
							facial_hair_color = sanitize_hexcolor(new_facial)
						else
							to_chat(user, span_danger("Invalid head flower color. Your color is not bright enough."))
				if("ipc_screen")
					var/new_ipc_screen

					new_ipc_screen = input(user, "Choose your character's screen:", "Character Preference") as null|anything in GLOB.ipc_screens_list

					if(new_ipc_screen)
						features["ipc_screen"] = new_ipc_screen

				if("ipc_antenna")
					var/new_ipc_antenna

					new_ipc_antenna = input(user, "Choose your character's antenna:", "Character Preference") as null|anything in GLOB.ipc_antennas_list

					if(new_ipc_antenna)
						features["ipc_antenna"] = new_ipc_antenna

				if("ipc_chassis")
					var/new_ipc_chassis

					new_ipc_chassis = input(user, "Choose your character's chassis:", "Character Preference") as null|anything in GLOB.ipc_chassis_list

					if(new_ipc_chassis)
						features["ipc_chassis"] = new_ipc_chassis
				if("s_tone")
					var/new_s_tone = input(user, "Choose your character's skin-tone:", "Character Preference")  as null|anything in GLOB.skin_tones
					if(new_s_tone)
						skin_tone = new_s_tone

				if("ooccolor")
					var/new_ooccolor = input(user, "Choose your OOC colour:", "Game Preference",ooccolor) as color|null
					if(new_ooccolor)
						ooccolor = new_ooccolor

				if("asaycolor")
					var/new_asaycolor = input(user, "Choose your ASAY color:", "Game Preference",asaycolor) as color|null
					if(new_asaycolor)
						asaycolor = new_asaycolor

				if("bag")
					var/new_backbag = input(user, "Choose your character's style of bag:", "Character Preference")  as null|anything in GLOB.backbaglist
					if(new_backbag)
						backbag = new_backbag

				if("suit")
					jumpsuit_style = jumpsuit_style == PREF_SUIT ? PREF_SKIRT : PREF_SUIT

				if("uplink_loc")
					var/new_loc = input(user, "Choose your character's traitor uplink spawn location:", "Character Preference") as null|anything in GLOB.uplink_spawn_loc_list
					if(new_loc)
						uplink_spawn_loc = new_loc

				if("ai_core_icon")
					var/ai_core_icon = input(user, "Choose your preferred AI core display screen:", "AI Core Display Screen Selection") as null|anything in GLOB.ai_core_display_screens - "Portrait"
					if(ai_core_icon)
						preferred_ai_core_display = ai_core_icon

				if("sec_dept")
					var/department = input(user, "Choose your preferred security department:", "Security Departments") as null|anything in GLOB.security_depts_prefs
					if(department)
						prefered_security_department = department

				if("eng_dept")
					var/department = input(user, "Choose your preferred engineering department:", "Engineering Departments") as null|anything in GLOB.engineering_depts_prefs
					if(department)
						prefered_engineering_department = department

				if("accent")
					var/aksent = input(user,"Choose your accent:","Available Accents") as null|anything in (assoc_list_strip_value(strings("accents.json", "accent_file_names", directory = "strings/accents")) + "None")
					if(aksent)
						if(aksent == "None")
							accent = initial(accent)
						else
							accent = aksent
				if ("preferred_map")
					var/maplist = list()
					var/default = "Default"
					if (config.defaultmap)
						default += " ([config.defaultmap.map_name])"
					for (var/M in config.maplist)
						var/datum/map_config/VM = config.maplist[M]
						if(!VM.votable)
							continue
						var/friendlyname = "[VM.map_name] "
						if (VM.voteweight <= 0)
							friendlyname += " (disabled)"
						maplist[friendlyname] = VM.map_name
					maplist[default] = null
					var/pickedmap = input(user, "Choose your preferred map. This will be used to help weight random map selection.", "Character Preference")  as null|anything in maplist
					if (pickedmap)
						preferred_map = maplist[pickedmap]

				if ("clientfps")
					var/desiredfps = input(user, "Choose your desired fps. (0 = synced with server tick rate (currently:[world.fps]))", "Character Preference", clientfps)  as null|num
					if (!isnull(desiredfps))
						clientfps = desiredfps
						parent.fps = desiredfps
				if("ui")
					var/pickedui = input(user, "Choose your UI style.", "Character Preference", UI_style)  as null|anything in GLOB.available_ui_styles
					if(pickedui)
						UI_style = pickedui
						if (parent && parent.mob && parent.mob.hud_used)
							parent.mob.hud_used.update_ui_style(ui_style2icon(UI_style))
				if("pda_style")
					var/pickedPDAStyle = input(user, "Choose your PDA style.", "Character Preference", pda_style)  as null|anything in GLOB.pda_styles
					if(pickedPDAStyle)
						pda_style = pickedPDAStyle
				if("pda_color")
					var/pickedPDAColor = input(user, "Choose your PDA Interface color.", "Character Preference",pda_color) as color|null
					if(pickedPDAColor)
						pda_color = pickedPDAColor
				if("id_in_pda")
					id_in_pda = !id_in_pda
				if("skillcape")
					var/list/selectablecapes = list()
					var/max_eligable = TRUE
					for(var/id in GLOB.skillcapes)
						var/datum/skillcape/A = GLOB.skillcapes[id]
						if(!A.job)
							continue
						if(user.client.prefs.exp[A.job] >= A.minutes)
							selectablecapes += A
						else
							max_eligable = FALSE
					if(max_eligable)
						selectablecapes += GLOB.skillcapes["max"]

					if(!selectablecapes.len)
						to_chat(user, "You have no availiable skillcapes!")
						return
					var/pickedskillcape = input(user, "Choose your Skillcape.", "Character Preference") as null|anything in (list("None") + selectablecapes)
					if(!pickedskillcape)
						return
					if(pickedskillcape == "None")
						skillcape_id = "None"
					else
						var/datum/skillcape/cape = pickedskillcape
						skillcape_id = cape.id
				if("flare")
					flare = !flare
				if("map")
					map = !map
				if("bar_choice")
					var/pickedbar = input(user, "Choose your bar.", "Character Preference", bar_choice) as null|anything in (GLOB.potential_box_bars|"Random")
					if(!pickedbar)
						return
					bar_choice = pickedbar
				if ("max_chat_length")
					var/desiredlength = input(user, "Choose the max character length of shown Runechat messages. Valid range is 1 to [CHAT_MESSAGE_MAX_LENGTH] (default: [initial(max_chat_length)]))", "Character Preference", max_chat_length)  as null|num
					if (!isnull(desiredlength))
						max_chat_length = clamp(desiredlength, 1, CHAT_MESSAGE_MAX_LENGTH)
				if("alternative_announcers")
					disable_alternative_announcers = !disable_alternative_announcers
				if("balloon_alerts")
					disable_balloon_alerts = !disable_balloon_alerts
			// yogs start - Custom keybindings
			if(href_list["keybinding"])
				update_keybindings(user, href_list["keybinding"], href_list["dir"])
			// yogs end
		else
			switch(href_list["preference"])
				if("publicity")
					if(unlock_content)
						toggles ^= MEMBER_PUBLIC
				if("gender")
					var/pickedGender = input(user, "Choose your gender.", "Character Preference", gender) as null|anything in friendlyGenders
					if(pickedGender && friendlyGenders[pickedGender] != gender)
						gender = friendlyGenders[pickedGender]
						underwear = random_underwear(gender)
						undershirt = random_undershirt(gender)
						socks = random_socks()
						facial_hair_style = random_facial_hair_style(gender)
						hair_style = random_hair_style(gender)

				if("hotkeys")
					hotkeys = !hotkeys
					if(hotkeys)
						bindings.bind_movement() // yogs - Rebindable keys
						winset(user, null, "input.focus=true input.background-color=[COLOR_INPUT_DISABLED] mainwindow.macro=default") // yogs - Rebindable keys
					else
						bindings.unbind_movement() // yogs - Rebindable keys
						winset(user, null, "input.focus=true input.background-color=[COLOR_INPUT_ENABLED] mainwindow.macro=old_default")
				if("chat_on_map")
					chat_on_map = !chat_on_map
				if("see_chat_non_mob")
					see_chat_non_mob = !see_chat_non_mob
				if("see_rc_emotes")
					see_rc_emotes = !see_rc_emotes
				if("action_buttons")
					buttons_locked = !buttons_locked
				if("tgui_fancy")
					tgui_fancy = !tgui_fancy
				if("tgui_lock")
					tgui_lock = !tgui_lock
				if("winflash")
					windowflashing = !windowflashing

				//here lies the badmins
				if("hear_adminhelps")
					user.client.toggleadminhelpsound()
				if("hear_prayers")
					user.client.toggle_prayer_sound()
				if("announce_login")
					user.client.toggleannouncelogin()
				if("combohud_lighting")
					toggles ^= COMBOHUD_LIGHTING
				if("toggle_dead_chat")
					user.client.deadchat()
				if("toggle_radio_chatter")
					user.client.toggle_hear_radio()
				if("toggle_prayers")
					user.client.toggleprayers()
				if("toggle_deadmin_always")
					toggles ^= DEADMIN_ALWAYS
				if("toggle_deadmin_antag")
					toggles ^= DEADMIN_ANTAGONIST
				if("toggle_deadmin_head")
					toggles ^= DEADMIN_POSITION_HEAD
				if("toggle_deadmin_security")
					toggles ^= DEADMIN_POSITION_SECURITY
				if("toggle_deadmin_silicon")
					toggles ^= DEADMIN_POSITION_SILICON
				if("toggle_deadmin_critical")
					toggles ^= DEADMIN_POSITION_CRITICAL


				if("be_special")
					var/be_special_type = href_list["be_special_type"]
					if(be_special_type in be_special)
						be_special -= be_special_type
					else
						be_special += be_special_type

				if("name")
					be_random_name = !be_random_name

				if("all")
					be_random_body = !be_random_body

				if("persistent_scars")
					persistent_scars = !persistent_scars

				if("clear_scars")
					var/path = "data/player_saves/[user.ckey[1]]/[user.ckey]/scars.sav"
					fdel(path)
					to_chat(user, span_notice("All scar slots cleared."))

				if("hear_midis")
					toggles ^= SOUND_MIDI

				if("lobby_music")
					toggles ^= SOUND_LOBBY
					if((toggles & SOUND_LOBBY) && user.client && isnewplayer(user))
						user.client.playtitlemusic()
					else
						user.stop_sound_channel(CHANNEL_LOBBYMUSIC)

				if("ghost_ears")
					chat_toggles ^= CHAT_GHOSTEARS

				if("ghost_sight")
					chat_toggles ^= CHAT_GHOSTSIGHT

				if("ghost_whispers")
					chat_toggles ^= CHAT_GHOSTWHISPER

				if("ghost_radio")
					chat_toggles ^= CHAT_GHOSTRADIO

				if("ghost_pda")
					chat_toggles ^= CHAT_GHOSTPDA

				if("income_pings")
					chat_toggles ^= CHAT_BANKCARD

				if("pull_requests")
					chat_toggles ^= CHAT_PULLR

				if("allow_midround_antag")
					toggles ^= MIDROUND_ANTAG

				if("parallaxup")
					parallax = WRAP(parallax + 1, PARALLAX_INSANE, PARALLAX_DISABLE + 1)
					if (parent && parent.mob && parent.mob.hud_used)
						parent.mob.hud_used.update_parallax_pref(parent.mob)

				if("parallaxdown")
					parallax = WRAP(parallax - 1, PARALLAX_INSANE, PARALLAX_DISABLE + 1)
					if (parent && parent.mob && parent.mob.hud_used)
						parent.mob.hud_used.update_parallax_pref(parent.mob)

				if("ambientocclusion")
					ambientocclusion = !ambientocclusion
					if(parent && parent.screen && parent.screen.len)
						var/obj/screen/plane_master/game_world/PM = locate(/obj/screen/plane_master/game_world) in parent.screen
						PM.backdrop(parent.mob)

				if("auto_fit_viewport")
					auto_fit_viewport = !auto_fit_viewport
					if(auto_fit_viewport && parent)
						parent.fit_viewport()

				if("widescreenpref")
					widescreenpref = !widescreenpref
					user.client.view_size.setDefault(getScreenSize(widescreenpref))

				if("pixel_size")
					switch(pixel_size)
						if(PIXEL_SCALING_AUTO)
							pixel_size = PIXEL_SCALING_1X
						if(PIXEL_SCALING_1X)
							pixel_size = PIXEL_SCALING_1_2X
						if(PIXEL_SCALING_1_2X)
							pixel_size = PIXEL_SCALING_2X
						if(PIXEL_SCALING_2X)
							pixel_size = PIXEL_SCALING_3X
						if(PIXEL_SCALING_3X)
							pixel_size = PIXEL_SCALING_AUTO
					user.client.view_size.apply() //Let's winset() it so it actually works

				if("scaling_method")
					switch(scaling_method)
						if(SCALING_METHOD_NORMAL)
							scaling_method = SCALING_METHOD_DISTORT
						if(SCALING_METHOD_DISTORT)
							scaling_method = SCALING_METHOD_BLUR
						if(SCALING_METHOD_BLUR)
							scaling_method = SCALING_METHOD_NORMAL
					user.client.view_size.setZoomMode()


				if("save")
					save_preferences()
					save_character()

				if("load")
					load_preferences()
					load_character()

				if("changeslot")
					if(!load_character(text2num(href_list["num"])))
						random_character()
						real_name = random_unique_name(gender)
						save_character()

				if("tab")
					if (href_list["tab"])
						current_tab = text2num(href_list["tab"])

				// yogs start - Custom keybindings
				if("reset_bindings")
					reset_keybindings()

				if("mood")
					yogtoggles ^= PREF_MOOD

				if("moodtailwagging")
					mood_tail_wagging = !mood_tail_wagging
				// yogs end

	ShowChoices(user)
	return 1

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
	character.id_in_pda = id_in_pda

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
		character.update_body()
		character.update_hair()
		character.update_body_parts()

/datum/preferences/proc/get_default_name(name_id)
	switch(name_id)
		if("human")
			return random_unique_name()
		if("ai")
			return pick(GLOB.ai_names)
		if("cyborg")
			return DEFAULT_CYBORG_NAME
		if("clown")
			return pick(GLOB.clown_names)
		if("mime")
			return pick(GLOB.mime_names)
		if("religion")
			return DEFAULT_RELIGION
		if("deity")
			return DEFAULT_DEITY
	return random_unique_name()

/datum/preferences/proc/ask_for_custom_name(mob/user,name_id)
	var/namedata = GLOB.preferences_custom_names[name_id]
	if(!namedata)
		return

	var/raw_name = input(user, "Choose your character's [namedata["qdesc"]]:","Character Preference") as text|null
	if(!raw_name)
		if(namedata["allow_null"])
			custom_names[name_id] = get_default_name(name_id)
		else
			return
	else
		var/sanitized_name = reject_bad_name(raw_name,namedata["allow_numbers"])
		if(!sanitized_name)
			to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z,[namedata["allow_numbers"] ? ",0-9," : ""] -, ' and .</font>")
			return
		else
			custom_names[name_id] = sanitized_name
