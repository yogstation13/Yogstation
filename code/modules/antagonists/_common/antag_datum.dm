GLOBAL_LIST_EMPTY(antagonists)

/datum/antagonist
	var/name = "Antagonist"
	var/roundend_category = "other antagonists"				//Section of roundend report, datums with same category will be displayed together, also default header for the section
	var/show_in_roundend = TRUE								//Set to false to hide the antagonists from roundend report
	var/prevent_roundtype_conversion = TRUE		//If false, the roundtype will still convert with this antag active
	var/datum/mind/owner						//Mind that owns this datum
	var/silent = FALSE							//Silent will prevent the gain/lose texts to show
	var/can_coexist_with_others = TRUE			//Whether or not the person will be able to have more than one datum
	var/list/typecache_datum_blacklist = list()	//List of datums this type can't coexist with
	var/job_rank
	var/replace_banned = TRUE //Should replace jobbanned player with ghosts if granted.
	var/list/objectives = list()
	var/antag_memory = ""//These will be removed with antag datum
	var/task_memory = ""//Optional little objectives that are to be removed on a certain milestone
	var/antag_moodlet //typepath of moodlet that the mob will gain with their status
	var/can_hijack = HIJACK_NEUTRAL //If these antags are alone on shuttle hijack happens.
	///The antag hud's icon file
	var/hud_icon = 'yogstation/icons/mob/antag_hud.dmi'
	///Name of the antag hud we provide to this mob.
	var/antag_hud_name
	var/awake_stage = ANTAG_AWAKE //What stage we are of "waking up"

	//Antag panel properties
	var/show_in_antagpanel = TRUE	//This will hide adding this antag type in antag panel, use only for internal subtypes that shouldn't be added directly but still show if possessed by mind
	var/antagpanel_category = "Uncategorized"	//Antagpanel will display these together, REQUIRED
	var/show_name_in_check_antagonists = FALSE //Will append antagonist name in admin listings - use for categories that share more than one antag type
	var/datum/achievement/greentext/greentext_achieve // The achievement received for greentexting as this antag type. Not all antag types use this to distribute their achievements.
	var/show_to_ghosts = FALSE // Should this antagonist be shown as antag to ghosts? Shouldn't be used for stealthy antagonists like traitors
	/// The corporation employing us
	var/datum/corporation/company
	/// The typepath for the outfit to show in the preview for the preferences menu.
	var/preview_outfit

	//ANTAG UI

	///name of the UI that will try to open, right now using a generic ui
	var/ui_name = "AntagInfoGeneric"
	///weakref to button to access antag interface
	var/datum/weakref/info_button_ref
	/// A weakref to the HUD shown to teammates, created by `add_team_hud`
	var/datum/weakref/team_hud_ref


/datum/antagonist/New()
	GLOB.antagonists += src
	typecache_datum_blacklist = typecacheof(typecache_datum_blacklist)

/datum/antagonist/Destroy()
	GLOB.antagonists -= src
	if(owner)
		LAZYREMOVE(owner.antag_datums, src)
	QDEL_NULL(team_hud_ref)
	owner = null
	return ..()

/datum/antagonist/proc/can_be_owned(datum/mind/new_owner)
	. = TRUE
	var/datum/mind/tested = new_owner || owner
	if(tested.has_antag_datum(type))
		return FALSE
	for(var/i in tested.antag_datums)
		var/datum/antagonist/A = i
		if(is_type_in_typecache(src, A.typecache_datum_blacklist))
			return FALSE

//This will be called in add_antag_datum before owner assignment.
//Should return antag datum without owner.
/datum/antagonist/proc/specialization(datum/mind/new_owner)
	return src

 //Called by the transfer_to() mind proc after the mind (mind.current and new_character.mind) has moved but before the player (key and client) is transfered.
/datum/antagonist/proc/on_body_transfer(mob/living/old_body, mob/living/new_body)
	SHOULD_CALL_PARENT(TRUE)
	remove_innate_effects(old_body)
	if(old_body && old_body.stat != DEAD && !LAZYLEN(old_body.mind?.antag_datums))
		old_body.remove_from_current_living_antags()
	var/datum/action/antag_info/info_button = info_button_ref?.resolve()
	if(info_button)
		info_button.Remove(old_body)
		info_button.Grant(new_body)
	apply_innate_effects(new_body)
	if(new_body.stat != DEAD)
		new_body.add_to_current_living_antags()

//This handles the application of antag huds/special abilities
/datum/antagonist/proc/apply_innate_effects(mob/living/mob_override)
	return

//This handles the removal of antag huds/special abilities
/datum/antagonist/proc/remove_innate_effects(mob/living/mob_override)
	handle_clown_mutation(mob_override || owner.current, removing = FALSE)
	return

/// Handles adding and removing the clumsy mutation from clown antags. Gets called in apply/remove_innate_effects
/datum/antagonist/proc/handle_clown_mutation(mob/living/mob_override, message, removing = TRUE)
	if(!ishuman(mob_override) || owner.assigned_role != "Clown")
		return
	var/mob/living/carbon/human/human_override = mob_override
	if(removing) // They're a clown becoming an antag, remove clumsy
		human_override.dna.remove_mutation(CLOWNMUT)
		if(!silent && message)
			to_chat(human_override, span_boldnotice("[message]"))
	else
		human_override.dna.add_mutation(CLOWNMUT) // We're removing their antag status, add back clumsy

//Assign default team and creates one for one of a kind team antagonists
/datum/antagonist/proc/create_team(datum/team/team)
	return

//Called by the add_antag_datum() mind proc after the instanced datum is added to the mind's antag_datums list.
/datum/antagonist/proc/on_gain()
	SHOULD_CALL_PARENT(TRUE)
	var/datum/action/antag_info/info_button
	if(!owner)
		CRASH("[src] ran on_gain() without a mind")
	if(!owner.current)
		CRASH("[src] ran on_gain() on a mind without a mob")
	if(ui_name)//in the future, this should entirely replace greet.
		info_button = new(src)
		info_button.Grant(owner.current)
		info_button_ref = WEAKREF(info_button)
	if(GLOB.admin_event)
		GLOB.admin_event.greet_role(owner, type)
	if(!silent)
		greet()
		if(ui_name)
			to_chat(owner.current, span_boldnotice("For more info, read the panel. you can always come back to it using the button in the top left."))
			info_button.Trigger()
	apply_innate_effects()
	give_antag_moodies()
	if(is_banned(owner.current) && replace_banned)
		replace_banned_player()
	else if(owner.current.client?.holder && (CONFIG_GET(flag/auto_deadmin_antagonists) || owner.current.client.prefs?.toggles & DEADMIN_ANTAGONIST))
		owner.current.client.holder.auto_deadmin()
	if(owner.current.stat != DEAD)
		owner.current.add_to_current_living_antags()
	
	SEND_SIGNAL(owner, COMSIG_ANTAGONIST_GAINED, src)

/datum/antagonist/proc/is_banned(mob/M)
	if(!M)
		return FALSE
	. = (is_banned_from(M.ckey, list(ROLE_SYNDICATE, job_rank)) || QDELETED(M))

/datum/antagonist/proc/replace_banned_player()
	set waitfor = FALSE

	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as a [name]?", "[name]", null, job_rank, 50, owner.current)
	var/mob/dead/observer/C
	
	to_chat(owner, "Your mob has been taken over by a ghost! Appeal your job ban if you want to avoid this in the future!")
	if(LAZYLEN(candidates))
		C = pick(candidates)
		
	message_admins(" [key_name_admin(owner)] [C ? "has been replaced by [key_name_admin(C)]" : "is banned from [job_rank] and was unable to be replaced!"]")
	owner.current.ghostize(0)
	owner.current.key = C ? C.key : null
	

//Called by the remove_antag_datum() and remove_all_antag_datums() mind procs for the antag datum to handle its own removal and deletion.
/datum/antagonist/proc/on_removal()
	SHOULD_CALL_PARENT(TRUE)
	if(!owner)
		CRASH("Antag datum with no owner.")

	remove_innate_effects()
	clear_antag_moodies()
	LAZYREMOVE(owner.antag_datums, src)
	if(!LAZYLEN(owner.antag_datums))
		owner.current.remove_from_current_living_antags()
	if(info_button_ref)
		QDEL_NULL(info_button_ref)
	if(!silent && owner.current)
		farewell()
	var/datum/team/team = get_team()
	if(team)
		team.remove_member(owner)
	SEND_SIGNAL(owner, COMSIG_ANTAGONIST_REMOVED, src)

	// Remove HUDs that they should no longer see
	var/mob/living/current = owner.current
	for (var/datum/atom_hud/alternate_appearance/basic/has_antagonist/antag_hud as anything in GLOB.has_antagonist_huds)
		if (!antag_hud.mobShouldSee(current))
			antag_hud.hide_from(current)

	qdel(src)

/datum/antagonist/proc/greet()
	return

/datum/antagonist/proc/farewell()
	return

/datum/antagonist/proc/give_antag_moodies()
	if(!antag_moodlet)
		return
	SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, "antag_moodlet", antag_moodlet)

/datum/antagonist/proc/clear_antag_moodies()
	if(!antag_moodlet)
		return
	SEND_SIGNAL(owner.current, COMSIG_CLEAR_MOOD_EVENT, "antag_moodlet")

//Returns the team antagonist belongs to if any.
/datum/antagonist/proc/get_team()
	return null

//Individual roundend report
/datum/antagonist/proc/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("antagonist datum without owner")

	report += printplayer(owner)

	var/objectives_complete = TRUE
	if(objectives.len)
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break

	if(objectives.len == 0 || objectives_complete)
		report += "<span class='greentext big'>The [name] was successful!</span>"
		if(istype(greentext_achieve))
			SSachievements.unlock_achievement(greentext_achieve,owner.current)
		else // The above still does award the generic greentext achievement, just implicitly.
			SSachievements.unlock_achievement(/datum/achievement/greentext,owner.current.client)
	else
		report += "<span class='redtext big'>The [name] has failed!</span>"

	return report.Join("<br>")

//Displayed at the start of roundend_category section, default to roundend_category header
/datum/antagonist/proc/roundend_report_header()
	var/list/report = list()
	report +="[span_header("The [roundend_category] were:")]<br>"
	report +="<br>"

	return report

//Displayed at the end of roundend_category section
/datum/antagonist/proc/roundend_report_footer()
	return


//ADMIN TOOLS

//Called when using admin tools to give antag status
/datum/antagonist/proc/admin_add(datum/mind/new_owner,mob/admin)
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into [name].")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [name].")
	new_owner.add_antag_datum(src)

//Called when removing antagonist using admin tools
/datum/antagonist/proc/admin_remove(mob/user)
	if(!user)
		return
	message_admins("[key_name_admin(user)] has removed [name] antagonist status from [key_name_admin(owner)].")
	log_admin("[key_name(user)] has removed [name] antagonist status from [key_name(owner)].")
	on_removal()

//gamemode/proc/is_mode_antag(antagonist/A) => TRUE/FALSE

//Additional data to display in antagonist panel section
//nuke disk code, genome count, etc
/datum/antagonist/proc/antag_panel_data()
	return ""

/datum/antagonist/proc/enabled_in_preferences(datum/mind/M)
	if(job_rank)
		if(M.current && M.current.client && (job_rank in M.current.client.prefs.be_special))
			return TRUE
		else
			return FALSE
	return TRUE

/// Creates an icon from the preview outfit.
/// Custom implementors of `get_preview_icon` should use this, as the
/// result of `get_preview_icon` is expected to be the completed version.
/datum/antagonist/proc/render_preview_outfit(datum/outfit/outfit, mob/living/carbon/human/dummy)
	dummy = dummy || new /mob/living/carbon/human/dummy/consistent
	dummy.equipOutfit(outfit, visualsOnly = TRUE)
	var/icon = getFlatIcon(dummy)

	// We don't want to qdel the dummy right away, since its items haven't initialized yet.
	SSatoms.prepare_deletion(dummy)

	return icon

/// Given an icon, will crop it to be consistent of those in the preferences menu.
/// Not necessary, and in fact will look bad if it's anything other than a human.
/datum/antagonist/proc/finish_preview_icon(icon/icon)
	// Zoom in on the top of the head and the chest
	// I have no idea how to do this dynamically.
	icon.Scale(115, 115)

	// This is probably better as a Crop, but I cannot figure it out.
	icon.Shift(WEST, 8)
	icon.Shift(SOUTH, 30)

	icon.Crop(1, 1, ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)

	return icon

/// Returns the icon to show on the preferences menu.
/datum/antagonist/proc/get_preview_icon()
	if (isnull(preview_outfit))
		return null

	return finish_preview_icon(render_preview_outfit(preview_outfit))

// List if ["Command"] = CALLBACK(), user will be appeneded to callback arguments on execution
/datum/antagonist/proc/get_admin_commands()
	. = list()

/datum/antagonist/Topic(href,href_list)
	if(!check_rights(R_ADMIN))
		return
	//Antag memory edit
	if (href_list["memory_edit"])
		edit_memory(usr)
		owner.traitor_panel()
		return

	//Some commands might delete/modify this datum clearing or changing owner
	var/datum/mind/persistent_owner = owner

	var/commands = get_admin_commands()
	for(var/admin_command in commands)
		if(href_list["command"] == admin_command)
			var/datum/callback/C = commands[admin_command]
			C.Invoke(usr)
			persistent_owner.traitor_panel()
			return

/datum/antagonist/proc/edit_memory(mob/user)
	var/new_memo = stripped_multiline_input(user, "Write new memory", "Memory", antag_memory, MAX_MESSAGE_LEN)
	if (isnull(new_memo))
		return
	antag_memory = new_memo
	task_memory = new_memo

/// Adds a HUD that will show you other members with the same antagonist.
/// If an antag typepath is passed to `antag_to_check`, will check that, otherwise will use the source type.
/datum/antagonist/proc/add_team_hud(mob/target, antag_to_check)
	QDEL_NULL(team_hud_ref)

	team_hud_ref = WEAKREF(target.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/has_antagonist,
		"antag_team_hud_[REF(src)]",
		hud_image_on(target),
		antag_to_check || type,
	))

	// Add HUDs that they couldn't see before
	for (var/datum/atom_hud/alternate_appearance/basic/has_antagonist/antag_hud as anything in GLOB.has_antagonist_huds)
		if (antag_hud.mobShouldSee(owner.current))
			antag_hud.show_to(owner.current)

/// Takes a location, returns an image drawing "on" it that matches this antag datum's hud icon
/datum/antagonist/proc/hud_image_on(mob/hud_loc)
	var/image/hud = image(hud_icon, hud_loc, antag_hud_name)
	hud.plane = ABOVE_HUD_PLANE //not quite but needed
	return hud

//This one is created by admin tools for custom objectives
/datum/antagonist/custom
	antagpanel_category = "Custom"
	show_name_in_check_antagonists = TRUE //They're all different
	var/datum/team/custom_team

/datum/antagonist/custom/create_team(datum/team/team)
	custom_team = team

/datum/antagonist/custom/get_team()
	return custom_team

/datum/antagonist/custom/admin_add(datum/mind/new_owner,mob/admin)
	var/custom_name = stripped_input(admin, "Custom antagonist name:", "Custom antag", "Antagonist")
	if(custom_name)
		name = custom_name
	else
		return
	..()

///ANTAGONIST UI STUFF

/datum/antagonist/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, ui_name, name)
		ui.open()

/datum/antagonist/ui_state(mob/user)
	return GLOB.always_state

///generic helper to send objectives as data through tgui.
/datum/antagonist/proc/get_objectives()
	var/objective_count = 1
	var/list/objective_data = list()
	var/datum/team/antag_team = get_team()
	//all obj
	for(var/datum/objective/objective in objectives + antag_team?.objectives)
		objective_data += list(list(
			"count" = objective_count,
			"name" = objective.objective_name,
			"explanation" = objective.explanation_text,
			"complete" = objective.completed,
		))
		objective_count++
	return objective_data

/datum/antagonist/ui_static_data(mob/user)
	var/list/data = list()
	data["antag_name"] = name
	data["objectives"] = get_objectives()
	return data

//button for antags to review their descriptions/info

/datum/action/antag_info
	name = "Open Antag Information:"
	button_icon_state = "info"
	show_to_observers = FALSE

/datum/action/antag_info/New(Target)
	. = ..()
	if(!button_icon_state)
		button_icon_state = initial(button_icon_state)
	name += " [target]"

/datum/action/antag_info/Trigger()
	. = ..()
	if(!.)
		return

	target.ui_interact(owner)

/datum/action/antag_info/IsAvailable(feedback = FALSE)
	if(!target)
		stack_trace("[type] was used without a target antag datum!")
		return FALSE
	. = ..()
	if(!.)
		return
	if(!owner.mind)
		return FALSE
	if(!(target in owner.mind.antag_datums))
		return FALSE
	return TRUE

//in the future, this should entirely replace greet.
/datum/antagonist/proc/make_info_button()
	if(!ui_name)
		return
	var/datum/action/antag_info/info_button = new(src)
	info_button.Grant(owner.current)
	info_button_ref = WEAKREF(info_button)
	return info_button

