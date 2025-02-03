/datum/player_panel_veth/ //required for tgui component
	var/title = "Veth's Ultimate Player Panel"

/datum/admins/proc/player_panel_veth() //proc for verb in game tab

	set name = "Player Panel Veth"
	set category = "Admin.Game"
	set desc = "Updated Player Panel with TGUI. Currently in testing."

	if (!check_rights(NONE))
		message_admins("[key_name(src)] attempted to use VUAP without sufficient rights.")
		return
	var/datum/player_panel_veth/tgui = new(usr)
	tgui.ui_interact(usr)
	to_chat(src, span_interface("VUAP has been opened!"), confidential = TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "VUAP")

/datum/player_panel_veth/ui_data(mob/user)
	var/list/players = list()
	var/mobs = sort_mobs()
	for (var/mob/mob_data in mobs)
		if (mob_data.ckey)
			var/player_previous_names = get_player_details(mob_data)?.played_names?.Join(", ")
			players += list(list(
				"name" = mob_data.name || "No Character",
				"old_name" = player_previous_names || "No Previous Characters",
				"job" = mob_data.job || "No Job",
				"ckey" = mob_data.ckey || "No Ckey",
				"is_antagonist" = is_special_character(mob_data, allow_fake_antags = TRUE),
				"last_ip" = mob_data.lastKnownIP ||	 "No Last Known IP",
				"ref" = REF(mob_data)
			))
	return list(
		"Data" = players
	)

/datum/player_panel_veth/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!check_rights(NONE))
		return
	var/mob/selected_mob = get_mob_by_ckey(params["selectedPlayerCkey"]) //gets the mob datum from the ckey in client datum which we've saved. if there's a better way to do this please let me know
	switch(action) //switch for all the actions from the frontend - all of the Topic() calls check rights & log inside themselves.
		if("sendPrivateMessage")
			usr.client.cmd_admin_pm(selected_mob.ckey)
			SSblackbox.record_feedback("tally", "VUAP", 1, "PM")
			return
		if("follow")
			usr.client.holder.Topic(null, list(
				"adminplayerobservefollow" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			to_chat(usr, "Now following [selected_mob.ckey].", confidential = TRUE)
			return
		if("smite")
			usr.client.holder.Topic(null, list(
				"adminsmite" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			to_chat(usr, "Smiting [selected_mob.ckey].", confidential = TRUE)
		if("refresh")
			ui.send_update()
			return
		if("oldPP")
			usr.client.holder.player_panel_new()
			SSblackbox.record_feedback("tally", "VUAP", 1, "OldPP")
			return
		if("checkPlayers")
			usr.client.check_players() //logs/rightscheck inside the proc
			return
		if("checkAntags")
			usr.client.check_antagonists() //logs/rightscheck inside the proc
			return
		if("faxPanel")
			usr.client.fax_panel() //logs/rightscheck inside the proc
			return
		if("gamePanel")
			usr.client.game_panel() //logs/rightscheck inside the proc
			return
		if("comboHUD")
			usr.client.toggle_combo_hud() //logs/rightscheck inside the proc
			return
		if("adminVOX")
			usr.client.AdminVOX() //logs/rightscheck inside the proc
			return
		if("generateCode")
			usr.client.generate_code() //logs/rightscheck inside the proc
			return
		if("viewOpfors")
			usr.client.view_opfors() //logs/rightscheck inside the proc
			return
		if("openAdditionalPanel") //logs/rightscheck inside the proc
			usr.client.selectedPlayerCkey = params["selectedPlayerCkey"]
			usr.client.holder.vuap_open()
			return
		if("createCommandReport")
			usr.client.cmd_admin_create_centcom_report() //logs/rightscheck inside the proc
			return
		if("logs")
			usr.client.holder.Topic(null, list(
				"individuallog" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("notes") //i'm pretty sure this checks rights inside the proc but to be safe
			if(!check_rights(NONE))
				return
			browse_messages(target_ckey = selected_mob.ckey)
			return
		if("vv") //logs/rightscheck inside the proc
			usr.client.debug_variables(selected_mob)
			return
		if("tp")
			usr.client.holder.Topic(null, list(
				"traitor" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("adminaiinteract") //loggin inside the proc
			usr.client.toggle_AI_interact()

/datum/player_panel_veth/ui_interact(mob/user, datum/tgui/ui)

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "VethPlayerPanel")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/player_panel_veth/ui_state(mob/user)
	return GLOB.admin_state


/client //this is needed to hold the selected player ckey for moving to and from pp/vuap
	///This is used to hold the ckey of the selected player for moving to and from the player panel and vuap
	var/selectedPlayerCkey = ""
	///this is used to hold the mob of the selected player in case the ckey can't be found (this enables pp'ing soulless mobs)
	var/VUAP_selected_mob = null

/datum/admins/proc/vuap_open_context(mob/r_clicked_mob in GLOB.mob_list) //this is the proc for the right click menu
	set category = null
	set name = "Open New Player Panel"
	if(!check_rights(NONE))
		return
	if(!length(r_clicked_mob.ckey) || r_clicked_mob.ckey[1] == "@")
		var/mob/player = r_clicked_mob
		var/datum/mind/player_mind = get_mind(player, include_last = TRUE)
		var/player_mind_ckey = ckey(player_mind.key)
		usr.client.VUAP_selected_mob = r_clicked_mob
		usr.client.holder.vuap_open()
		tgui_alert(usr, "WARNING! This mob has no associated Mind! Most actions will not work. Last ckey to control this mob is [player_mind_ckey].", "No Mind!")

	else
		usr.client.selectedPlayerCkey = r_clicked_mob.ckey
		usr.client.holder.vuap_open()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "VUAP")

/datum/vuap_personal

/*possible bugs that might occur:
- Atm, if you receive an admin ticket off of something that has changed mob before you hit the PP button, you'll get the old soulless mob. There is a
warning dialogue box with the ckey of the previous holder of this mob, however.
if you know how to fix the above and are smarter than me please let me know and I'll give you a kiss
I've tried to make it as a simple as possible to add new buttons, most of it should be a copy and paste job.area



Some (poor) explanation of what's going on -
player_panel_veth is the new tgui version of the player panel, it also includes some most pressed verbs
I've tried to comment in as much stuff as possible so it can be changed in the future is necessary
Vuap_personal is the new tgui version of the options panel. It basically does everything the same way the player panel does
minus some features that the player panel didn't have I guess.
the client/var/selectedPlayerCkey is used to hold the selected player ckey for moving to and from pp/vuap
If you want to add info the player panel:
- add the appropriate info into the backend in ui_data. This gotta be formatted correctly or tgui will scream
- add the data to the frontend in VethPlayerPanel.tsx, adding a row onto the following table:
<Table.Row header>
	<Table.Cell>Ckey</Table.Cell>
	<Table.Cell>Char Name</Table.Cell>
	<Table.Cell>Also Known As</Table.Cell>
	<Table.Cell>Job</Table.Cell>
	<Table.Cell>Antagonist</Table.Cell>
	<Table.Cell>Last IP</Table.Cell>
	<Table.Cell>Actions</Table.Cell>
	</Table.Row>
	{filteredData.map((player) => (
	<Table.Row key={player.ckey} className="candystripe">
		<Table.Cell>{player.ckey}</Table.Cell>
		<Table.Cell>{player.name}</Table.Cell>
		<Table.Cell>{player.old_name}</Table.Cell>
		<Table.Cell>{player.job}</Table.Cell>
		<Table.Cell>
		{player.is_antagonist ? (
			<Box color="red">Yes</Box>
		) : (
			<Box color="green">No</Box>
		)}
		</Table.Cell>
		<Table.Cell>{player.last_ip}</Table.Cell>
Same goes for VUAP_personal.tsx, but you gotta add it to the table in there instead :)
If you want to add a button to the player panel:
- add the backend instructions for it in /datum/veth_player_panel/ui_act into the action switch (the frontend and backend action names must match, case sensitive)
- add the button to the frontend. You can basically copy and paste one of the buttons that's in VethPlayerPanel.tsx and add it to a column.

If you want to add a button to the vuap panel:
- add the backend instructions for it in /datum/vuap_personal/ui_act into the action switch (the frontend and backend action names must match, case sensitive)
- add the button to the frontend. You can basically copy and paste one of the buttons that's in VUAP_personal.tsx and add it to a section.

Some explanation of the frontend because it's not known by many people:
<Button
	fluid  - this allows the interface to place the button where it makes sense and allows it to move
	icon="refresh" - this is the icon that is shown next to the text on the button
	content="Refresh" - this is the text on the button
	onClick={() => handleAction('refresh')} - this is the action handler for tgui. it sends an associated list to the backend of action = "whatevertheactionis"
	the ui_act handler on the backend then reads the action for the switch, and chooses the appropriate action.
/>

love, veth

*/
/datum/vuap_personal/ui_data(mob/user)
	var/ckey = user.client?.selectedPlayerCkey
	var/list/player_data = list(
		"characterName" = "No Character",
		"ckey" = ckey || "Unknown",
		"ipAddress" = "0.0.0.0",
		"CID" = "NO_CID",
		"gameState" = "Unknown",
		"byondVersion" = "0.0.0",
		"mobType" = "null",
		"firstSeen" = "Never",
		"accountRegistered" = "Unknown",
		"muteStates" = list(
			"ic" = FALSE,
			"ooc" = FALSE,
			"pray" = FALSE,
			"adminhelp" = FALSE,
			"deadchat" = FALSE,
			"webreq" = FALSE
		)
	)
	if(!length(ckey) || ckey[1] == "@")
		var/mob/player = usr.client.VUAP_selected_mob
		player_data["characterName"] = player.name || "No Character"
		player_data["gameState"] = istype(player) ? "Active" : "Unknown"
		player_data["mobType"] = "[initial(player.type)]" || "null"
		return list("Data" = player_data)
	else
		var/mob/player = get_mob_by_ckey(ckey)
		var/client/client_info = player?.client
		if(player && client_info)
			player_data["characterName"] = player.real_name || "No Character"
			player_data["ipAddress"] = client_info.address || "0.0.0.0"
			player_data["CID"] = client_info.computer_id || "NO_CID"
			player_data["gameState"] = istype(player) ? "Active" : "Unknown"
			player_data["byondVersion"] = "[client_info.byond_version || 0].[client_info.byond_build || 0]"
			player_data["mobType"] = "[initial(player.type)]" || "null"
			player_data["firstSeen"] = client_info.player_join_date || "Never"
			player_data["accountRegistered"] = client_info.account_join_date || "Unknown"
			// Safely check mute states
			if(client_info.prefs)
				player_data["muteStates"] = list(
					"ic" = !isnull(client_info.prefs.muted) && (client_info.prefs.muted & MUTE_IC),
					"ooc" = !isnull(client_info.prefs.muted) && (client_info.prefs.muted & MUTE_OOC),
					"pray" = !isnull(client_info.prefs.muted) && (client_info.prefs.muted & MUTE_PRAY),
					"adminhelp" = !isnull(client_info.prefs.muted) && (client_info.prefs.muted & MUTE_ADMINHELP),
					"deadchat" = !isnull(client_info.prefs.muted) && (client_info.prefs.muted & MUTE_DEADCHAT),
					"webreq" = !isnull(client_info.prefs.muted) && (client_info.prefs.muted & MUTE_INTERNET_REQUEST),
				)
		return list("Data" = player_data)

/datum/vuap_personal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VUAP_personal")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/vuap_personal/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!check_rights(NONE))
		return
	var/mob/selected_mob = get_mob_by_ckey(ui.user.client.selectedPlayerCkey)
	if(!selected_mob)
		tgui_alert(usr, "Selected player not found!")
		return
	//pretty much all of these actions use the Topic() admin call. This admin call is secure, checks rights, and does stuff the way the old player panel did.
	//see code/modules/admin/topic.dm for more info on how it works.
	//essentially you have to pass a list of parameters to Topic(). It needs to be provided with an admin token to do any of its functions.
	switch(action)
		if("refresh")
			ui.send_update()
			return
		if("relatedbycid")
			usr.client.holder.Topic(null, list(
			"showrelatedacc" = "cid",
			"admin_token" = usr.client.holder.href_token,
			"client" = REF(selected_mob.client),
			))
			return
		if("relatedbyip")
			usr.client.holder.Topic(null, list(
			"showrelatedacc" = "ip",
			"admin_token" = usr.client.holder.href_token,
			"client" = REF(selected_mob.client),
			))
			return
		// Punish Section
		if("kick")
			usr.client.holder.Topic(null, list(
				"boot2" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("ban")
			if(!check_rights(R_BAN))
				return
			usr.client.ban_panel()
			SSblackbox.record_feedback("tally", "VUAP", 1, "Ban")
			return
		if("prison")
			usr.client.holder.Topic(null, list(
				"sendtoprison" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("unprison")
			if (is_centcom_level(selected_mob.z))
				SSjob.SendToLateJoin(selected_mob)
				to_chat(usr, "Unprisoned [selected_mob.ckey].", confidential = TRUE)
				message_admins("[key_name_admin(usr)] has unprisoned [key_name_admin(selected_mob)]")
				log_admin("[key_name(usr)] has unprisoned [key_name(selected_mob)]")
			else
				tgui_alert(usr,"[selected_mob.name] is not prisoned.")
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Unprison")
			return
		if("smite")
			usr.client.holder.Topic(null, list(
				"adminsmite" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		// Message Section
		if("pm")
			if (!check_rights(NONE))
				return
			usr.client.cmd_admin_pm(selected_mob.ckey)
			SSblackbox.record_feedback("tally", "VUAP", 1, "PM")
			return
		if("sm")
			usr.client.holder.Topic(null, list(
				"subtlemessage" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("narrate")
			usr.client.holder.Topic(null, list(
				"narrateto" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("playsoundto")
			usr.client.holder.Topic(null, list(
				"playsoundto" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return

		// Movement Section
		if("jumpto")
			usr.client.holder.Topic(null, list(
				"jumpto" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("get")
			usr.client.holder.Topic(null, list(
				"getmob" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("send")
			usr.client.holder.Topic(null, list(
				"sendmob" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("lobby")
			usr.client.holder.Topic(null, list(
				"sendbacktolobby" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("flw")
			usr.client.holder.Topic(null, list(
				"adminplayerobservefollow" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("cryo")
			selected_mob.vv_send_cryo()
			return
		// Info Section
		if("vv") //checks rights inside the proc
			usr.client.debug_variables(selected_mob)
			SSblackbox.record_feedback("tally", "VUAP", 1, "VV")
			return
		if("tp")
			usr.client.holder.Topic(null, list(
				"traitor" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("skills")
			usr.client.holder.Topic(null, list(
				"skill" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("logs")
			usr.client.holder.Topic(null, list(
				"individuallog" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("notes")
			if(!check_rights(NONE))
				return
			browse_messages(target_ckey = selected_mob.ckey)
			return
		// Transformation Section
		if("makeghost")
			usr.client.holder.Topic(null, list(
				"simplemake" = "observer",
				"mob" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			ui.send_update()
			return
		if("makehuman")
			usr.client.holder.Topic(null, list(
				"simplemake" = "human",
				"mob" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			ui.send_update()
			return
		if("makemonkey")
			usr.client.holder.Topic(null, list(
				"simplemake" = "monkey",
				"mob" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			ui.send_update()
			return
		if("makeborg")
			usr.client.holder.Topic(null, list(
				"simplemake" = "robot",
				"mob" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			ui.send_update()
			return
		if("makeai")
			usr.client.holder.Topic(null, list(
				"makeai" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			ui.send_update()
			return
		//health section
		if("healthscan")
			if(!check_rights(NONE))
				return
			healthscan(usr, selected_mob, advanced = TRUE, tochat = TRUE)
			SSblackbox.record_feedback("tally", "VUAP", 1, "HealthScan")
		if("chemscan")
			if(!check_rights(NONE))
				return
			chemscan(usr, selected_mob)
			SSblackbox.record_feedback("tally", "VUAP", 1, "ChemScan")
		if("aheal")
			usr.client.holder.Topic(null, list(
				"revive" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			to_chat(usr, "Adminhealed  [selected_mob.ckey].", confidential = TRUE)
			return
		if("giveDisease")
			if(!check_rights(NONE))
				return
			usr.client.give_disease(selected_mob)
			SSblackbox.record_feedback("tally", "VUAP", 1, "GiveDisease")
			return
		if("cureAllDiseases")
			if (istype(selected_mob, /mob/living))
				var/mob/living/L = selected_mob
				L.fully_heal(HEAL_NEGATIVE_DISEASES)
			to_chat(usr, "Cured all negative diseases on [selected_mob.ckey].", confidential = TRUE)
			SSblackbox.record_feedback("tally", "VUAP", 1, "CureAllDiseases")
			return
		if("diseasePanel") //rights check inside the proc
			usr.client.diseases_panel(selected_mob)
			SSblackbox.record_feedback("tally", "VUAP", 1, "DiseasePanel")
			return
		if("modifytraits")
			usr.client.holder.modify_traits(selected_mob)
			SSblackbox.record_feedback("tally", "VUAP", 1, "ModifyTraits")
			return
		// Misc Section
		if("language")
			usr.client.holder.Topic(null, list(
				"languagemenu" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("forcesay")
			usr.client.holder.Topic(null, list(
				"forcespeech" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
		if("applyquirks")
			usr.client.holder.Topic(null, list(
				"applyquirks" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
		if("thunderdome1")
			usr.client.holder.Topic(null, list(
				"tdome1" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("thunderdome2")
			usr.client.holder.Topic(null, list(
				"tdome2" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("commend")
			usr.client.holder.Topic(null, list(
				"admincommend" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("playtime")
			usr.client.holder.Topic(null, list(
				"getplaytimewindow" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("thunderdomeadmin")
			usr.client.holder.Topic(null, list(
				"tdomeadmin" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("thunderdomeobserve")
			usr.client.holder.Topic(null, list(
				"tdomeobserver" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("dblink")
			usr.client.holder.Topic(null, list(
				"centcomlookup" = selected_mob.ckey,
				"admin_token" = usr.client.holder.href_token
			))
		if("spawncookie")
			usr.client.holder.Topic(null, list(
				"adminspawncookie" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		// Mute Controls
		if("toggleMute")
			var/muteType = params["type"]
			switch(muteType)
				if("ic")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_IC)
					ui.send_update()
					return
				if("ooc")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_OOC)
					ui.send_update()
					return
				if("pray")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_PRAY)
					ui.send_update()
					return
				if("adminhelp")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_ADMINHELP)
					ui.send_update()
					return
				if("deadchat")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_DEADCHAT)
					ui.send_update()
					return
				if("webreq")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_INTERNET_REQUEST)
					ui.send_update()
					return
			return

		if("toggleAllMutes")
			cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_ALL)
			ui.send_update()
			return

/datum/vuap_personal/ui_state(mob/user)
	return GLOB.admin_state

/datum/admins/proc/vuap_open()
	if (!check_rights(NONE))
		message_admins("[key_name(src)] attempted to use VUAP without sufficient rights.")
		return
	var/datum/vuap_personal/tgui = new(usr)
	tgui.ui_interact(usr)
	SSblackbox.record_feedback("tally", "VUAP", 1, "VUAP_open")


