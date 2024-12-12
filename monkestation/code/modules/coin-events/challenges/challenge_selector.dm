/datum/challenge_selector
	/// The client of the person using the UI
	var/datum/player_details/owner

/datum/challenge_selector/New(user)
	owner = get_player_details(user)
	owner.challenge_menu = src

/datum/challenge_selector/Destroy(force)
	if(owner?.challenge_menu == src)
		owner.challenge_menu = null
	owner = null
	return ..()

/datum/challenge_selector/ui_state(mob/user)
	return GLOB.always_state

/datum/challenge_selector/ui_status(mob/user, datum/ui_state/state)
	if(isliving(user) || isobserver(user))
		return UI_CLOSE
	return ..()

/datum/challenge_selector/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChallengeSelector", "Select Challenges")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/challenge_selector/ui_static_data(mob/user)
	var/list/buyables = list()
	for(var/datum/challenge/challenge as anything in subtypesof(/datum/challenge))
		buyables += list(
			list(
				"name" = challenge::challenge_name,
				"payout" = challenge::challenge_payout,
				"difficulty" = challenge::difficulty,
				"path" = challenge::type
			)
		)
	return list("challenges" = buyables)

/datum/challenge_selector/ui_data(mob/user)
	var/list/selected = list()
	for(var/datum/challenge/challenge_path as anything in owner.active_challenges)
		selected += "[challenge_path]"
	return list("selected_challenges" = selected)

/datum/challenge_selector/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	switch(action)
		if("select_challenge")
			add_selection(user, params)
			return TRUE

/datum/challenge_selector/proc/add_selection(mob/user, list/params)
	if(user.ckey != owner.ckey)
		CRASH("User [user.ckey] tried to use challenge selector of [owner.ckey]")
	if(isliving(user) || isobserver(user))
		return

	var/challenge_path = text2path(params["path"])
	if(!ispath(challenge_path, /datum/challenge))
		return

	if(challenge_path in owner.active_challenges)
		LAZYREMOVE(owner.active_challenges, challenge_path)
	else
		LAZYADD(owner.active_challenges, challenge_path)
