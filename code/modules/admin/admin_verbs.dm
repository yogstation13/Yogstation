//admin verb groups - They can overlap if you so wish. Only one of each verb will exist in the verbs list regardless
//the procs are cause you can't put the comments in the GLOB var define
GLOBAL_LIST_INIT(admin_verbs_default, world.AVerbsDefault())
GLOBAL_PROTECT(admin_verbs_default)
/world/proc/AVerbsDefault()
	return list(
	/client/proc/deadmin,				/*destroys our own admin datum so we can play as a regular player*/
	/client/verb/cmd_admin_say,			/*admin-only ooc chat*/
	/client/proc/hide_verbs,			/*hides all our adminverbs*/
	/client/proc/hide_most_verbs,		/*hides all our hideable adminverbs*/
	/client/proc/debug_variables,		/*allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify*/
	/client/verb/dsay,					/*talk in deadchat using our ckey/fakekey*/
	/client/proc/investigate_show,		/*various admintools for investigation. Such as a singulo grief-log*/
	/client/proc/secrets,
	/client/proc/reload_admins,
	/client/proc/reload_mentors,
	/client/proc/reestablish_db_connection, /*reattempt a connection to the database*/
	/client/proc/cmd_admin_pm_context,	/*right-click adminPM interface*/
	/client/proc/cmd_admin_pm_panel,		/*admin-pm list*/
	/client/proc/stop_sounds,
	/client/proc/fix_air, // yogs - fix air verb
	/client/proc/fix_air_z,
	/client/proc/clear_all_pipenets,
	/client/proc/debugstatpanel,
	/client/proc/clear_mfa,
	/client/proc/show_rights,
	/client/proc/remove_liquid,
	/client/proc/spawn_liquid,
	/client/proc/forceEvent, //Move to fun verbs before full merge
	/client/proc/forceGamemode //Move to fun verbs before full merge
	)
GLOBAL_LIST_INIT(admin_verbs_admin, world.AVerbsAdmin())
GLOBAL_PROTECT(admin_verbs_admin)
/world/proc/AVerbsAdmin()
	return list(
	/client/proc/list_pretty_filters,			//yogs - shows all the pretty filters
	/client/proc/invisimin,				/*allows our mob to go invisible/visible*/
//	/datum/admins/proc/show_traitor_panel,	/*interface which shows a mob's mind*/ -Removed due to rare practical use. Moved to debug verbs ~Errorage
	/datum/admins/proc/show_player_panel,	/*shows an interface for individual players, with various links (links require additional flags*/
	/datum/verbs/menu/Admin/verb/playerpanel,
	/client/proc/game_panel,			/*game panel, allows to change game-mode etc*/
	/client/proc/check_ai_laws,			/*shows AI and borg laws*/
	/client/proc/ghost_pool_protection,	/*opens a menu for toggling ghost roles*/
	/datum/admins/proc/toggleooc,		/*toggles ooc on/off for everyone*/
	/datum/admins/proc/toggleoocdead,	/*toggles ooc on/off for everyone who is dead*/
	/datum/admins/proc/togglelooc,		/*toggles looc on/off for everyone*/ // yogs - LOOC
	/datum/admins/proc/toggleloocdead,	/*toggles looc on/off for everyone who is dead */ // yogs - LOOC
	/datum/admins/proc/toggleenter,		/*toggles whether people can join the current game*/
	/datum/admins/proc/toggleguests,	/*toggles whether guests can join the current game*/
	/datum/admins/proc/announce,		/*priority announce something to all clients.*/
	/datum/admins/proc/set_admin_notice, /*announcement all clients see when joining the server.*/
	/client/proc/admin_ghost,			/*allows us to ghost/reenter body at will*/
	/client/proc/toggle_view_range,		/*changes how far we can see*/
	/client/proc/getserverlogs,		/*for accessing server logs*/
	/client/proc/getcurrentlogs,		/*for accessing server logs for the current round*/
	/client/proc/cmd_admin_subtle_message,	/*send an message to somebody as a 'voice in their head'*/
	/client/proc/cmd_admin_headset_message,	/*send an message to somebody through their headset as CentCom*/
	/client/proc/cmd_admin_rejuvenate,	/*Rejuvivates Mobs*/
	/client/proc/cmd_admin_offer_rename, /*offers a mob the ability to change its name variables for itself*/
	/client/proc/cmd_admin_delete,		/*delete an instance/object/mob/etc*/
	/client/proc/cmd_admin_check_contents,	/*displays the contents of an instance*/
	/client/proc/check_antagonists,		/*shows all antags*/
	/datum/admins/proc/access_news_network,	/*allows access of newscasters*/
	/client/proc/jumptocoord,			/*we ghost and jump to a coordinate*/
	/client/proc/Getmob,				/*teleports a mob to our location*/
	/client/proc/Getkey,				/*teleports a mob with a certain ckey to our location*/
//	/client/proc/sendmob,				/*sends a mob somewhere*/ -Removed due to it needing two sorting procs to work, which were executed every time an admin right-clicked. ~Errorage
	/client/proc/jumptoarea,
	/client/proc/jumptokey,				/*allows us to jump to the location of a mob with a certain ckey*/
	/client/proc/jump_to_mob,				/*allows us to jump to a specific mob*/
	/client/proc/jumptoturf,			/*allows us to jump to a specific turf*/
	/client/proc/admin_call_shuttle,	/*allows us to call the emergency shuttle*/
	/client/proc/admin_cancel_shuttle,	/*allows us to cancel the emergency shuttle, sending it back to centcom*/
	/client/proc/cmd_admin_direct_narrate,	/*send text directly to a player with no padding. Useful for narratives and fluff-text*/
	/client/proc/cmd_admin_world_narrate,	/*sends text to all players with no padding*/
	/client/proc/cmd_admin_local_narrate,	/*sends text to all mobs within view of atom*/
	/client/proc/cmd_admin_create_centcom_report,
	/client/proc/send_global_fax,
	/client/proc/cmd_change_command_name,
	/client/proc/cmd_admin_check_player_exp, /* shows players by playtime */
	/client/proc/toggle_combo_hud, // toggle display of the combination pizza antag and taco sci/med/eng hud
	/client/proc/toggle_AI_interact, /*toggle admin ability to interact with machines as an AI*/
	/datum/admins/proc/open_shuttlepanel, /* Opens shuttle manipulator UI */
	/client/proc/respawn_character,
	/client/proc/discord_id_manipulation,
	/datum/admins/proc/manage_silicon_laws,
	/datum/admins/proc/open_borgopanel,
	/datum/admins/proc/restart, //yogs - moved from +server
	/client/proc/admin_pick_random_player, //yogs
	/client/proc/get_law_history, //yogs - silicon law history
	/client/proc/show_mentors, // yogs - mentors
	/client/proc/reset_all_tcs, // yogs - NTSL, resets all NTSL scripts in world
	/client/proc/subtlemessage_faction, // yogs -- SM to entire factions/antag types
	/client/proc/nerf_or_nothing, // yogs -- Groudon's meme nerf verb
	/client/proc/delay_shuttle, // yogs -- Allows admins to delay the shuttle from launching
	/client/proc/queue_check, // Yogs -- Some queue manipulation/debuggin kinda verbs
	/client/proc/cmd_view_polls,
	/client/proc/antag_token_panel, //Yogs -- Access Antag Token Panel
	/client/proc/give_antag_token,
	/client/proc/show_redeemable_antag_tokens,
	/datum/admins/proc/cmd_create_centcom,
	/datum/admins/proc/cmd_admin_fuckrads,
	/datum/admins/proc/cmd_create_wiki,
  	/client/proc/admincryo,
	/client/proc/cmd_admin_dress,
	/client/proc/disconnect_panel
	)
GLOBAL_LIST_INIT(admin_verbs_ban, list(/client/proc/unban_panel, /client/proc/ban_panel, /client/proc/stickybanpanel))
GLOBAL_PROTECT(admin_verbs_ban)
GLOBAL_LIST_INIT(admin_verbs_sounds, list(/client/proc/play_local_sound, /client/proc/play_sound, /client/proc/set_round_end_sound, /client/proc/play_web_sound))
GLOBAL_PROTECT(admin_verbs_sounds)
GLOBAL_LIST_INIT(admin_verbs_fun, list(
	/client/proc/cmd_admin_gib_self,
	/client/proc/drop_bomb,
	/client/proc/set_dynex_scale,
	/client/proc/drop_dynex_bomb,
	/client/proc/cinematic,
	/client/proc/one_click_antag,
	/client/proc/cmd_admin_add_freeform_ai_law,
	/client/proc/object_say,
	/client/proc/set_ooc,
	/client/proc/reset_ooc,
	/client/proc/admin_change_sec_level,
	/client/proc/toggle_nuke,
	/client/proc/run_weather,
	/client/proc/mass_zombie_infection,
	/client/proc/mass_zombie_cure,
	/client/proc/polymorph_all,
	/client/proc/show_tip,
	/client/proc/smite,
	/client/proc/spawn_floor_cluwne, // Yogs
	/client/proc/rejuv_all, // yogs - Revive All
	/client/proc/admin_vox, // yogs - Admin AI Vox
	/client/proc/admin_away,
	/client/proc/centcom_podlauncher,/*Open a window to launch a Supplypod and configure it or it's contents*/
	/client/proc/load_json_admin_event,
	/client/proc/event_role_manager
	))
GLOBAL_PROTECT(admin_verbs_fun)
GLOBAL_LIST_INIT(admin_verbs_spawn, list(/datum/admins/proc/spawn_atom, /datum/admins/proc/podspawn_atom, /datum/admins/proc/spawn_cargo, /datum/admins/proc/spawn_objasmob, /client/proc/respawn_character, /datum/admins/proc/beaker_panel))
GLOBAL_PROTECT(admin_verbs_spawn)
GLOBAL_LIST_INIT(admin_verbs_server, world.AVerbsServer())
GLOBAL_PROTECT(admin_verbs_server)
/world/proc/AVerbsServer()
	return list(
	/datum/admins/proc/startnow,
	/*/datum/admins/proc/restart, YOGS - moved to +admin*/
	/datum/admins/proc/end_round,
	/datum/admins/proc/delay,
	/datum/admins/proc/toggleaban,
	/client/proc/everyone_random,
	/datum/admins/proc/toggleAI,
	/client/proc/cmd_admin_delete,		/*delete an instance/object/mob/etc*/
	/client/proc/cmd_debug_del_all,
	/client/proc/forcerandomrotate,
	/client/proc/adminchangemap,
	/client/proc/panicbunker,
	/client/proc/toggle_hub,
	/client/proc/mentor_memo, // YOGS - something stupid about "Mentor memos"
	/client/proc/release_queue, // Yogs -- Adds some queue-manipulation verbs
	/client/proc/toggle_cdn,
	/client/proc/set_next_minetype,
	/client/proc/lag_switch_panel
	)
GLOBAL_LIST_INIT(admin_verbs_debug, world.AVerbsDebug())
GLOBAL_PROTECT(admin_verbs_debug)
/world/proc/AVerbsDebug()
	return list(
	/client/proc/view_runtimes,
	/client/proc/cmd_admin_delete,
	/client/proc/cmd_debug_del_all,
	/client/proc/SDQL2_query,
	/client/proc/enable_debug_verbs,
	/client/proc/callproc,
	/client/proc/callproc_datum,
	/client/proc/cmd_admin_list_open_jobs,
	#ifdef TESTING //Xoxeyos 3/14/2021
	/client/proc/export_dynamic_json,
	/client/proc/run_dynamic_simulations,
	#endif
	/client/proc/debug_plane_masters,
	/client/proc/debug_spell_requirements,
	)
GLOBAL_LIST_INIT(admin_verbs_possess, list(/proc/possess, /proc/release))
GLOBAL_PROTECT(admin_verbs_possess)
GLOBAL_LIST_INIT(admin_verbs_permissions, list(/client/proc/edit_admin_permissions))
GLOBAL_PROTECT(admin_verbs_permissions)
GLOBAL_LIST_INIT(admin_verbs_poll, list(/client/proc/create_poll))
GLOBAL_PROTECT(admin_verbs_poll)

//verbs which can be hidden - needs work
GLOBAL_LIST_INIT(admin_verbs_hideable, list(
	/client/proc/set_ooc,
	/client/proc/reset_ooc,
	/client/proc/deadmin,
	/datum/admins/proc/show_traitor_panel,
	/datum/admins/proc/toggleenter,
	/datum/admins/proc/toggleguests,
	/datum/admins/proc/announce,
	/datum/admins/proc/set_admin_notice,
	/client/proc/admin_ghost,
	/client/proc/toggle_view_range,
	/client/proc/cmd_admin_subtle_message,
	/client/proc/cmd_admin_rejuvenate,
	/client/proc/cmd_admin_offer_rename,
	/client/proc/cmd_admin_headset_message,
	/client/proc/cmd_admin_check_contents,
	/datum/admins/proc/access_news_network,
	/client/proc/admin_call_shuttle,
	/client/proc/admin_cancel_shuttle,
	/client/proc/cmd_admin_direct_narrate,
	/client/proc/cmd_admin_world_narrate,
	/client/proc/cmd_admin_local_narrate,
	/client/proc/play_local_sound,
	/client/proc/play_sound,
	/client/proc/play_web_sound,
	/client/proc/set_round_end_sound,
	/client/proc/cmd_admin_dress,
	/client/proc/cmd_admin_gib_self,
	/client/proc/drop_bomb,
	/client/proc/drop_dynex_bomb,
	/client/proc/get_dynex_range,
	/client/proc/get_dynex_power,
	/client/proc/set_dynex_scale,
	/client/proc/cinematic,
	/client/proc/cmd_admin_add_freeform_ai_law,
	/client/proc/cmd_admin_create_centcom_report,
	/client/proc/cmd_change_command_name,
	/client/proc/object_say,
	/datum/admins/proc/startnow,
	/datum/admins/proc/restart,
	/datum/admins/proc/delay,
	/datum/admins/proc/toggleaban,
	/client/proc/everyone_random,
	/datum/admins/proc/toggleAI,
	/client/proc/restart_controller,
	/client/proc/cmd_admin_list_open_jobs,
	/client/proc/callproc,
	/client/proc/callproc_datum,
	/client/proc/Debug2,
	/client/proc/reload_admins,
	/client/proc/reload_mentors,
	/client/proc/cmd_debug_make_powernets,
	/client/proc/startSinglo,
	/client/proc/cmd_debug_mob_lists,
	/client/proc/cmd_debug_del_all,
	/client/proc/enable_debug_verbs,
	/proc/possess,
	/proc/release,
	/client/proc/reload_admins,
	/client/proc/reload_mentors,
	/client/proc/panicbunker,
	/client/proc/admin_change_sec_level,
	/client/proc/toggle_nuke,
	/client/proc/cmd_display_del_log,
	/client/proc/toggle_combo_hud,
	/client/proc/debug_huds,
	/client/proc/admincryo
	))
GLOBAL_PROTECT(admin_verbs_hideable)

/client/proc/add_admin_verbs()
	if(holder)
		control_freak = CONTROL_FREAK_SKIN | CONTROL_FREAK_MACROS

		var/rights = GLOB.permissions.get_rights_for(src)
		add_verb(src, GLOB.admin_verbs_default)
		add_verb(src, GLOB.mentor_verbs) // yogs - give admins mentor verbs
		if(rights & R_BUILDMODE)
			add_verb(src, /client/proc/togglebuildmodeself)
		if(rights & R_ADMIN)
			add_verb(src, GLOB.admin_verbs_admin)
		if(rights & R_BAN)
			add_verb(src, GLOB.admin_verbs_ban)
		if(rights & R_FUN)
			add_verb(src, GLOB.admin_verbs_fun)
		if(rights & R_SERVER)
			add_verb(src, GLOB.admin_verbs_server)
		if(rights & R_DEBUG)
			add_verb(src, GLOB.admin_verbs_debug)
		if(rights & R_POSSESS)
			add_verb(src, GLOB.admin_verbs_possess)
		if(rights & R_PERMISSIONS)
			add_verb(src, GLOB.admin_verbs_permissions)
		if(rights & R_STEALTH)
			add_verb(src, /client/proc/stealth)
		if(rights & R_ADMIN)
			add_verb(src, GLOB.admin_verbs_poll)
		if(rights & R_SOUNDS)
			add_verb(src, GLOB.admin_verbs_sounds)
			if(CONFIG_GET(string/invoke_youtubedl))
				add_verb(src, /client/proc/play_web_sound)
		if(rights & R_SPAWN)
			add_verb(src, GLOB.admin_verbs_spawn)

/client/proc/remove_admin_verbs()
	remove_verb(src, list(
		GLOB.admin_verbs_default,
		/client/proc/togglebuildmodeself,
		GLOB.admin_verbs_admin,
		GLOB.admin_verbs_ban,
		GLOB.admin_verbs_fun,
		GLOB.admin_verbs_server,
		GLOB.admin_verbs_debug,
		GLOB.admin_verbs_possess,
		GLOB.admin_verbs_permissions,
		/client/proc/stealth,
		GLOB.admin_verbs_poll,
		GLOB.admin_verbs_sounds,
		/client/proc/play_web_sound,
		GLOB.admin_verbs_spawn,
		/*Debug verbs added by "show debug verbs"*/
		GLOB.admin_verbs_debug_all,
		/client/proc/disable_debug_verbs,
		/client/proc/readmin
		))

/client/proc/hide_most_verbs()//Allows you to keep some functionality while hiding some verbs
	set name = "Adminverbs - Hide Most"
	set category = "Admin"

	verbs.Remove(/client/proc/hide_most_verbs, GLOB.admin_verbs_hideable)
	add_verb(src, /client/proc/show_verbs)

	to_chat(src, span_interface("Most of your adminverbs have been hidden."), confidential=TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Hide Most Adminverbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/hide_verbs()
	set name = "Adminverbs - Hide All"
	set category = "Admin"

	remove_admin_verbs()
	add_verb(src, /client/proc/show_verbs)

	to_chat(src, span_interface("Almost all of your adminverbs have been hidden."), confidential=TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Hide All Adminverbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/show_verbs()
	set name = "Adminverbs - Show"
	set category = "Admin"

	remove_verb(src, /client/proc/show_verbs)
	add_admin_verbs()

	to_chat(src, span_interface("All of your adminverbs are now visible."), confidential=TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Adminverbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/admin_ghost()
	set category = "Admin"
	set name = "Aghost"
	if(!holder)
		return
	. = TRUE
	if(isobserver(mob))
		//re-enter
		var/mob/dead/observer/ghost = mob
		if(!ghost.mind || !ghost.mind.current) //won't do anything if there is no body
			return FALSE
		if(!ghost.can_reenter_corpse)
			log_admin("[key_name(usr)] re-entered corpse")
			message_admins("[key_name_admin(usr)] re-entered corpse")
		ghost.can_reenter_corpse = 1 //force re-entering even when otherwise not possible
		ghost.reenter_corpse()
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Admin Reenter") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else if(isnewplayer(mob))
		to_chat(src, "<font color='red'>Error: Aghost: Can't admin-ghost whilst in the lobby. Join or Observe first.</font>", confidential=TRUE)
		return FALSE
	else
		//ghostize
		log_admin("[key_name(usr)] admin ghosted.")
		message_admins("[key_name_admin(usr)] admin ghosted.")
		var/mob/body = mob
		body.ghostize(1)
		init_verbs()
		if(body && !body.key)
			body.key = "@[key]"	//Haaaaaaaack. But the people have spoken. If it breaks; blame adminbus
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Admin Ghost") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/invisimin()
	set name = "Invisimin"
	set category = "Admin"
	set desc = "Toggles ghost-like invisibility (Don't abuse this)"
	if(holder && mob)
		if(mob.invisibility == INVISIBILITY_MAXIMUM)
			mob.invisibility = initial(mob.invisibility)
			to_chat(mob, span_boldannounce("Invisimin off. Invisibility reset."))
		else
			mob.invisibility = INVISIBILITY_MAXIMUM
			to_chat(mob, span_adminnotice("<b>Invisimin on. You are now invisible.</b>"))

/client/proc/check_antagonists()
	set name = "Check Antagonists"
	set category = "Admin"
	if(check_rights(R_ADMIN))
	// yogs start
		log_admin("[key_name(usr)] checked antagonists.")	//for tsar~
		if((!isobserver(usr) && SSticker.HasRoundStarted()) || !check_rights(R_VAREDIT, FALSE))
			message_admins("[key_name_admin(usr)] checked antagonists.")
		holder.check_antagonists()

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Antagonists") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	// yogs end

/client/proc/ban_panel()
	set name = "Banning Panel"
	set category = "Admin"
	if(!check_rights(R_BAN))
		return
	holder.ban_panel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Banning Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/unban_panel()
	set name = "Unbanning Panel"
	set category = "Admin"
	if(!check_rights(R_BAN))
		return
	holder.unban_panel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Unbanning Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/antag_token_panel()
	set name = "Antag Token Panel"
	set category = "Admin"
	if(!check_rights(R_ADMIN))
		return
	holder.antag_token_panel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Antag Token Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/show_redeemable_antag_tokens()
	set name = "Redeemable Antag Tokens"
	set category = "Admin"
	if(!check_rights(R_ADMIN))
		return
	holder.show_redeemable_antag_tokens()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Antag Token Redeemable Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/give_antag_token()
	set name = "Give Antag Token"
	set category = "Admin"
	if(!check_rights(R_ADMIN))
		return
	holder.give_antag_token()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Antag Token") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/game_panel()
	set name = "Game Panel"
	set category = "Admin.Round Interaction"
	if(holder)
		holder.Game()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Game Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/secrets()
	set name = "Secrets"
	set category = "Admin.Round Interaction"
	if (holder)
		holder.Secrets()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Secrets Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/findStealthKey(txt)
	if(txt)
		for(var/P in GLOB.stealthminID)
			if(GLOB.stealthminID[P] == txt)
				return P
	txt = GLOB.stealthminID[ckey]
	return txt

/client/proc/createStealthKey()
	var/num = (rand(0,1000))
	var/i = 0
	while(i == 0)
		i = 1
		for(var/P in GLOB.stealthminID)
			if(num == GLOB.stealthminID[P])
				num++
				i = 0
	GLOB.stealthminID["[ckey]"] = "@[num2text(num)]"

/client/proc/stealth()
	set category = "Admin"
	set name = "Stealth Mode"
	if(holder)
		if(holder.fakekey)
			holder.fakekey = null
		else
			var/new_key = ckeyEx(stripped_input(usr, "Enter your desired display name.", "Fake Key", key, 26))
			if(!new_key)
				return
			holder.fakekey = new_key
			holder.fakename = random_unique_name(prob(50) ? MALE : FEMALE)
			createStealthKey()
		log_admin("[key_name(usr)] has turned stealth mode [holder.fakekey ? "ON" : "OFF"]")
		message_admins("[key_name_admin(usr)] has turned stealth mode [holder.fakekey ? "ON" : "OFF"]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Stealth Mode") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/drop_bomb()
	set category = "Admin.Round Interaction"
	set name = "Drop Bomb"
	set desc = "Cause an explosion of varying strength at your location."

	var/list/choices = list("Small Bomb (1, 2, 3, 3)", "Medium Bomb (2, 3, 4, 4)", "Big Bomb (3, 5, 7, 5)", "Maxcap", "Custom Bomb")
	var/choice = tgui_input_list(usr, "What size explosion would you like to produce? NOTE: You can do all this rapidly and in an IC manner (using cruise missiles!) with the Config/Launch Supplypod verb. WARNING: These ignore the maxcap", "Drop Bomb", choices)
	var/turf/epicenter = mob.loc

	switch(choice)
		if(null)
			return 0
		if("Small Bomb (1, 2, 3, 3)")
			explosion(epicenter, 1, 2, 3, 3, TRUE, TRUE)
		if("Medium Bomb (2, 3, 4, 4)")
			explosion(epicenter, 2, 3, 4, 4, TRUE, TRUE)
		if("Big Bomb (3, 5, 7, 5)")
			explosion(epicenter, 3, 5, 7, 5, TRUE, TRUE)
		if("Maxcap")
			explosion(epicenter, GLOB.MAX_EX_DEVESTATION_RANGE, GLOB.MAX_EX_HEAVY_RANGE, GLOB.MAX_EX_LIGHT_RANGE, GLOB.MAX_EX_FLASH_RANGE)
		if("Custom Bomb")
			var/devastation_range = input("Devastation range (in tiles):") as null|num
			if(devastation_range == null)
				return
			var/heavy_impact_range = input("Heavy impact range (in tiles):") as null|num
			if(heavy_impact_range == null)
				return
			var/light_impact_range = input("Light impact range (in tiles):") as null|num
			if(light_impact_range == null)
				return
			var/flash_range = input("Flash range (in tiles):") as null|num
			if(flash_range == null)
				return
			if(devastation_range > GLOB.MAX_EX_DEVESTATION_RANGE || heavy_impact_range > GLOB.MAX_EX_HEAVY_RANGE || light_impact_range > GLOB.MAX_EX_LIGHT_RANGE || flash_range > GLOB.MAX_EX_FLASH_RANGE)
				if(tgui_alert(usr, "Bomb is bigger than the maxcap. Continue?",,list("Yes","No")) != "Yes")
					return
			epicenter = mob.loc //We need to reupdate as they may have moved again
			explosion(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, TRUE, TRUE)
	message_admins("[ADMIN_LOOKUPFLW(usr)] creating an admin explosion at [epicenter.loc].")
	log_admin("[key_name(usr)] created an admin explosion at [epicenter.loc].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Drop Bomb") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/drop_dynex_bomb()
	set category = "Misc.Unused"
	set name = "Drop DynEx Bomb"
	set desc = "Cause an explosion of varying strength at your location."

	var/ex_power = input("Explosive Power:") as null|num
	var/turf/epicenter = mob.loc
	if(ex_power && epicenter)
		dyn_explosion(epicenter, ex_power)
		message_admins("[ADMIN_LOOKUPFLW(usr)] creating an admin explosion at [epicenter.loc].")
		log_admin("[key_name(usr)] created an admin explosion at [epicenter.loc].")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Drop Dynamic Bomb") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/get_dynex_range()
	set category = "Misc.Server Debug"
	set name = "Get DynEx Range"
	set desc = "Get the estimated range of a bomb, using explosive power."

	var/ex_power = input("Explosive Power:") as null|num
	if (isnull(ex_power))
		return
	var/range = round((2 * ex_power)**GLOB.DYN_EX_SCALE)
	to_chat(usr, "Estimated Explosive Range: (Devastation: [round(range*0.25)], Heavy: [round(range*0.5)], Light: [round(range)])", confidential=TRUE)

/client/proc/get_dynex_power()
	set category = "Misc.Server Debug"
	set name = "Get DynEx Power"
	set desc = "Get the estimated required power of a bomb, to reach a specific range."

	var/ex_range = input("Light Explosion Range:") as null|num
	if (isnull(ex_range))
		return
	var/power = (0.5 * ex_range)**(1/GLOB.DYN_EX_SCALE)
	to_chat(usr, "Estimated Explosive Power: [power]", confidential=TRUE)

/client/proc/set_dynex_scale()
	set category = "Misc.Server Debug"
	set name = "Set DynEx Scale"
	set desc = "Set the scale multiplier of dynex explosions. The default is 0.5."

	var/ex_scale = input("New DynEx Scale:") as null|num
	if(!ex_scale)
		return
	GLOB.DYN_EX_SCALE = ex_scale
	log_admin("[key_name(usr)] has modified Dynamic Explosion Scale: [ex_scale]")
	message_admins("[key_name_admin(usr)] has  modified Dynamic Explosion Scale: [ex_scale]")

/client/proc/give_spell(mob/spell_recipient in GLOB.mob_list)
	set category = "Admin.Player Interaction"
	set name = "Give Spell"
	set desc = "Gives a spell to a mob."

	var/which = tgui_alert(usr, "Chose by name or by type path?", "Chose option", list("Name", "Typepath"))
	if(!which)
		return
	if(QDELETED(spell_recipient))
		to_chat(usr, span_warning("The intended spell recipient no longer exists."))
		return

	var/list/spell_list = list()
	for(var/datum/action/cooldown/spell/to_add as anything in subtypesof(/datum/action/cooldown/spell))
		var/spell_name = initial(to_add.name)
		if(spell_name == "Spell") // abstract or un-named spells should be skipped.
			continue

		if(which == "Name")
			spell_list[spell_name] = to_add
		else
			spell_list += to_add

	var/chosen_spell = tgui_input_list(usr, "Choose the spell to give to [spell_recipient]", "ABRAKADABRA", sortList(spell_list))
	if(isnull(chosen_spell))
		return
	var/datum/action/cooldown/spell/spell_path = which == "Typepath" ? chosen_spell : spell_list[chosen_spell]
	if(!ispath(spell_path))
		return

	var/robeless = (tgui_alert(usr, "Would you like to force this spell to be robeless?", "Robeless Casting?", list("Force Robeless", "Use Spell Setting")) == "Force Robeless")

	if(QDELETED(spell_recipient))
		to_chat(usr, span_warning("The intended spell recipient no longer exists."))
		return

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Spell") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(spell_recipient)] the spell [chosen_spell][robeless ? " (Forced robeless)" : ""].")
	message_admins("[key_name_admin(usr)] gave [key_name_admin(spell_recipient)] the spell [chosen_spell][robeless ? " (Forced robeless)" : ""].")

	var/datum/action/cooldown/spell/new_spell = new spell_path(spell_recipient.mind || spell_recipient)

	if(robeless)
		new_spell.spell_requirements &= ~SPELL_REQUIRES_WIZARD_GARB
		new_spell.bypass_cost = TRUE //breaks balance, but allows non antags to use antag specific abilities

	new_spell.Grant(spell_recipient)

	if(!spell_recipient.mind)
		to_chat(usr, span_userdanger("Spells given to mindless mobs will belong to the mob and not their mind, \
			and as such will not be transferred if their mind changes body (Such as from Mindswap)."))

/client/proc/remove_spell(mob/removal_target in GLOB.mob_list)
	set category = "Admin.Player Interaction"
	set name = "Remove Spell"
	set desc = "Remove a spell from the selected mob."

	var/list/target_spell_list = list()
	for(var/datum/action/cooldown/spell/spell in removal_target.actions)
		target_spell_list[spell.name] = spell

	if(!length(target_spell_list))
		return

	var/chosen_spell = tgui_input_list(usr, "Choose the spell to remove from [removal_target]", "ABRAKADABRA", sortList(target_spell_list))
	if(isnull(chosen_spell))
		return
	var/datum/action/cooldown/spell/to_remove = target_spell_list[chosen_spell]
	if(!istype(to_remove))
		return

	qdel(to_remove)
	log_admin("[key_name(usr)] removed the spell [chosen_spell] from [key_name(removal_target)].")
	message_admins("[key_name_admin(usr)] removed the spell [chosen_spell] from [key_name_admin(removal_target)].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Remove Spell") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/give_disease(mob/living/T in GLOB.mob_living_list)
	set category = "Admin.Player Interaction"
	set name = "Give Disease"
	set desc = "Gives a Disease to a mob."
	if(!istype(T))
		to_chat(src, span_notice("You can only give a disease to a mob of type /mob/living."), confidential=TRUE)
		return
	var/datum/disease/D = input("Choose the disease to give to that guy", "ACHOO") as null|anything in SSdisease.diseases
	if(!D)
		return
	T.ForceContractDisease(new D, FALSE, TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Disease") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(T)] the disease [D].")
	message_admins(span_adminnotice("[key_name_admin(usr)] gave [key_name_admin(T)] the disease [D]."))

/client/proc/object_say(obj/O in world)
	set category = "Misc.Unused"
	set name = "OSay"
	set desc = "Makes an object say something."
	var/message = input(usr, "What do you want the message to be?", "Make Sound") as text | null
	if(!message)
		return
	O.say(message)
	log_admin("[key_name(usr)] made [O] at [AREACOORD(O)] say \"[message]\"")
	message_admins(span_adminnotice("[key_name_admin(usr)] made [O] at [AREACOORD(O)]. say \"[message]\""))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Object Say") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/togglebuildmodeself()
	set name = "Toggle Build Mode Self"
	set category = "Admin.Round Interaction"
	if (!(check_rights(R_BUILDMODE)))
		return
	if(src.mob)
		togglebuildmode(src.mob)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Build Mode") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/check_ai_laws()
	set name = "Check AI Laws"
	set category = "Admin"

	if(holder)
		src.holder.output_ai_laws()

/client/proc/deadmin()
	set name = "Deadmin"
	set category = "Admin"
	set desc = "Shed your admin and mentor powers."

	if(!holder)
		return

	if(combo_hud_enabled)
		toggle_combo_hud()

	holder.deactivate()

	to_chat(src, span_interface("You are now a normal player."), confidential=TRUE)
	
	remove_mentor_verbs()
	QDEL_NULL(mentor_datum)
	GLOB.mentors -= src
	add_verb(src, /client/proc/rementor)
	
	log_admin("[src] deadmined themself.")
	message_admins("[src] deadmined themself.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Deadmin")

/client/proc/clear_mfa()
	set name = "Forget 2FA logins"
	set category = "Admin"
	set desc= "Forgets all saved 2FA logins"

	if(!holder)
		return
	
	if(tgui_alert(usr, "Are you sure? This will forget all the previously saved 2FA logins", "Confirmation", list("Yes", "No")) == "Yes")
		mfa_reset(ckey, TRUE)

/client/proc/readmin()
	set name = "Readmin"
	set category = "Admin"
	set desc = "Regain your admin powers."

	var/datum/admins/A = GLOB.permissions.deadmins[ckey]

	if(!A)
		A = GLOB.permissions.admin_datums[ckey]
		if (!A)
			var/msg = " is trying to readmin but they have no deadmin entry"
			message_admins("[key_name_admin(src)][msg]")
			log_admin_private("[key_name(src)][msg]")
			return

	A.associate(src)

	if (!holder)
		return //This can happen if an admin attempts to vv themself into somebody elses's deadmin datum by getting ref via brute force

	to_chat(src, span_interface("You are now an admin."), confidential=TRUE)
	message_admins("[src] re-adminned themselves.")
	log_admin("[src] re-adminned themselves.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Readmin")

/client/proc/show_rights()
	set name = "Show Rights"
	set category = "Admin"
	set desc = "Shows access rights"

	to_chat(src, span_interface("You have the following permissions:\n[rights2text(GLOB.permissions.get_rights_for_ckey(ckey), "\n")]"))

/client/proc/populate_world(amount = 50 as num)
	set name = "Populate World"
	set category = "Misc.Server Debug"
	set desc = "(\"Amount of mobs to create\") Populate the world with test mobs."

	if (amount > 0)
		var/area/area
		var/list/candidates
		var/turf/open/floor/tile
		var/j,k

		for (var/i = 1 to amount)
			j = 100

			do
				area = pick(GLOB.the_station_areas)

				if (area)

					candidates = get_area_turfs(area)

					if (candidates.len)
						k = 100

						do
							tile = pick(candidates)
						while ((!tile || !istype(tile)) && --k > 0)

						if (tile)
							var/mob/living/carbon/human/hooman = new(tile)
							hooman.equipOutfit(pick(subtypesof(/datum/outfit)))
							testing("Spawned test mob at [COORD(tile)]")
			while (!area && --j > 0)

/client/proc/toggle_AI_interact()
	set name = "Toggle Admin AI Interact"
	set category = "Admin"
	set desc = "Allows you to interact with most machines as an AI would as a ghost"

	AI_Interact = !AI_Interact
	if(mob && IsAdminGhost(mob))
		mob.has_unlimited_silicon_privilege = AI_Interact

	log_admin("[key_name(usr)] has [AI_Interact ? "activated" : "deactivated"] Admin AI Interact")
	message_admins("[key_name_admin(usr)] has [AI_Interact ? "activated" : "deactivated"] their AI interaction")
/*
/client/proc/dump_memory_usage()
	set name = "Dump Server Memory Usage"
	set category = "Server"

	if(!check_rights(R_DEV))
		return
	if(GLOB.enable_memdump == 0)
		to_chat(world, span_userdanger("You should not be touching this without contacting developers!"))
		return
	if(tgui_alert(usr, "This will dump memory usage and potentially lag the server. Proceed?", "Alert", list("Yes", "No")) != "Yes")
		return

	var/fname = "[GLOB.round_id ? GLOB.round_id : "NULL"]-[time2text(world.timeofday, "MM-DD-hhmm")].json"

	to_chat(world, span_userdanger("Performing a memory dump!"))
	log_admin("[key_name_admin(usr)] has initiated a memory dump into \"[fname]\".")
	message_admins("[key_name_admin(usr)] has initiated a memory dump into \"[fname]\".")

	sleep(2 SECONDS)

	if(!dump_memory_profile("data/logs/memory/[fname]"))
		to_chat(usr, span_warning("Dumping memory failed at dll call."))
		return

	if(!fexists("data/logs/memory/[fname]"))
		to_chat(usr, span_warning("File creation failed. Please check to see if the data/logs/memory folder actually exists."))
	else
		to_chat(usr, span_notice("Memory dump completed."))
*/


/client/proc/debugstatpanel()
	set name = "Debug Stat Panel"
	set category = "Misc.Server Debug"

	src.stat_panel.send_message("create_debug")

/// Debug verb for seeing at a glance what all spells have as set requirements
/client/proc/debug_spell_requirements()
	set name = "Show Spell Requirements"
	set category = "Misc.Server Debug"

	var/header = "<tr><th>Name</th> <th>Requirements</th>"
	var/all_requirements = list()
	for(var/datum/action/cooldown/spell/spell as anything in typesof(/datum/action/cooldown/spell))
		if(initial(spell.name) == "Spell")
			continue

		var/list/real_reqs = list()
		var/reqs = initial(spell.spell_requirements)
		if(reqs & SPELL_CASTABLE_AS_BRAIN)
			real_reqs += "Castable as brain"
		if(reqs & SPELL_CASTABLE_WHILE_PHASED)
			real_reqs += "Castable phased"
		if(reqs & SPELL_REQUIRES_HUMAN)
			real_reqs += "Must be human"
		if(reqs & SPELL_REQUIRES_MIME_VOW)
			real_reqs += "Must be miming"
		if(reqs & SPELL_REQUIRES_MIND)
			real_reqs += "Must have a mind"
		if(reqs & SPELL_REQUIRES_NO_ANTIMAGIC)
			real_reqs += "Must have no antimagic"
		if(reqs & SPELL_REQUIRES_STATION)
			real_reqs += "Must be off central command z-level"
		if(reqs & SPELL_REQUIRES_WIZARD_GARB)
			real_reqs += "Must have wizard clothes"

		all_requirements += "<tr><td>[initial(spell.name)]</td> <td>[english_list(real_reqs, "No requirements")]</td></tr>"

	var/page_style = "<style>table, th, td {border: 1px solid black;border-collapse: collapse;}</style>"
	var/page_contents = "[page_style]<table style=\"width:100%\">[header][jointext(all_requirements, "")]</table>"
	var/datum/browser/popup = new(mob, "spellreqs", "Spell Requirements", 600, 400)
	popup.set_content(page_contents)
	popup.open()
