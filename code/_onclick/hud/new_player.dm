/datum/hud/new_player

/datum/hud/new_player/New(mob/owner)
	..()
	var/list/buttons = subtypesof(/atom/movable/screen/lobby)
	for(var/button in buttons)
		var/atom/movable/screen/lobbyscreen = new button()
		lobbyscreen.hud = src
		static_inventory += lobbyscreen
		lobbyscreen.postInit()

/*
	Screen objects
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/
/atom/movable/screen
	name = ""
	plane = HUD_PLANE
	animate_movement = SLIDE_STEPS
	speech_span = SPAN_ROBOT
	vis_flags = VIS_INHERIT_PLANE
	appearance_flags = APPEARANCE_UI
	/// A reference to the object in the slot. Grabs or items, generally.
	var/obj/master = null
	/// A reference to the owner HUD, if any.
	var/datum/hud/hud = null
	/**
	 * Map name assigned to this object.
	 * Automatically set by /client/proc/add_obj_to_map.
	 */
	var/assigned_map
	/**
	 * Mark this object as garbage-collectible after you clean the map
	 * it was registered on.
	 *
	 * This could probably be changed to be a proc, for conditional removal.
	 * But for now, this works.
	 */
	var/del_on_map_removal = TRUE

/atom/movable/screen/proc/postInit()

/atom/movable/screen/Destroy()
	master = null
	hud = null
	return ..()

/atom/movable/screen/lobby
	plane = SPLASHSCREEN_PLANE
	layer = LOBBY_BUTTON_LAYER
	screen_loc = "TOP,CENTER"

/atom/movable/screen/lobby/background
	layer = LOBBY_BACKGROUND_LAYER
	icon = 'icons/hud/lobby/background.dmi'
	icon_state = "background"
	screen_loc = "TOP,CENTER:-61"

/atom/movable/screen/lobby/button
	///Is the button currently enabled?
	var/enabled = TRUE
	///Is the button currently being hovered over with the mouse?
	var/highlighted = FALSE

/atom/movable/screen/lobby/button/Click(location, control, params)
	. = ..()
	if(!enabled)
		return
	flick("[base_icon_state]_pressed", src)
	update_icon()
	return TRUE

/atom/movable/screen/lobby/button/MouseEntered(location,control,params)
	. = ..()
	highlighted = TRUE
	update_icon()

/atom/movable/screen/lobby/button/MouseExited()
	. = ..()
	highlighted = FALSE
	update_icon()

/atom/movable/screen/lobby/button/proc/update_icon(updates)
	if(!enabled)
		icon_state = "[base_icon_state]_disabled"
		return
	else if(highlighted)
		icon_state = "[base_icon_state]_highlighted"
		return
	icon_state = base_icon_state

/atom/movable/screen/lobby/button/proc/set_button_status(status)
	if(status == enabled)
		return FALSE
	enabled = status
	update_icon()
	return TRUE

///Prefs menu
/atom/movable/screen/lobby/button/character_setup
	screen_loc = "TOP:-70,CENTER:-54"
	icon = 'icons/hud/lobby/character_setup.dmi'
	icon_state = "character_setup"
	base_icon_state = "character_setup"

/atom/movable/screen/lobby/button/character_setup/Click(location, control, params)
	. = ..()
	if(!.)
		return
	hud.mymob.client.prefs.ShowChoices(hud.mymob)

///Button that appears before the game has started
/atom/movable/screen/lobby/button/ready
	screen_loc = "TOP:-8,CENTER:-65"
	icon = 'icons/hud/lobby/ready.dmi'
	icon_state = "not_ready"
	base_icon_state = "not_ready"
	var/ready = FALSE

/atom/movable/screen/lobby/button/ready/Initialize(mapload)
	. = ..()
	if(SSticker.current_state > GAME_STATE_PREGAME)
		set_button_status(FALSE)
	else
		RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, .proc/hide_ready_button)

/atom/movable/screen/lobby/button/ready/proc/hide_ready_button()
	set_button_status(FALSE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP)

/atom/movable/screen/lobby/button/ready/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/dead/new_player/new_player = hud.mymob
	ready = !ready
	if(ready)
		new_player.ready = PLAYER_READY_TO_PLAY
		base_icon_state = "ready"
	else
		new_player.ready = PLAYER_NOT_READY
		base_icon_state = "not_ready"
	update_icon()

///Shown when the game has started
/atom/movable/screen/lobby/button/join
	screen_loc = "TOP:-13,CENTER:-58"
	icon = 'icons/hud/lobby/join.dmi'
	icon_state = "" //Default to not visible
	base_icon_state = "join_game"
	enabled = FALSE

/atom/movable/screen/lobby/button/join/Initialize(mapload)
	. = ..()
	if(SSticker.current_state > GAME_STATE_PREGAME)
		set_button_status(TRUE)
	else
		RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, .proc/show_join_button)

/atom/movable/screen/lobby/button/join/Click(location, control, params)
	. = ..()
	if(!.)
		return
	if(!SSticker?.IsRoundInProgress())
		to_chat(hud.mymob, "<span class='boldwarning'>The round is either not ready, or has already finished...</span>")
		return

	//Determines Relevent Population Cap
	var/relevant_cap
	var/hpc = CONFIG_GET(number/hard_popcap)
	var/epc = CONFIG_GET(number/extreme_popcap)
	if(hpc && epc)
		relevant_cap = min(hpc, epc)
	else
		relevant_cap = max(hpc, epc)

	var/mob/dead/new_player/new_player = hud.mymob

	if(SSticker.queued_players.len || (relevant_cap && living_player_count() >= relevant_cap && !(ckey(new_player.key) in GLOB.admin_datums)))
		to_chat(new_player, "<span class='danger'>[CONFIG_GET(string/hard_popcap_message)]</span>")

		var/queue_position = SSticker.queued_players.Find(new_player)
		if(queue_position == 1)
			to_chat(new_player, "<span class='notice'>You are next in line to join the game. You will be notified when a slot opens up.")
		else if(queue_position)
			to_chat(new_player, "<span class='notice'>There are [queue_position-1] players in front of you in the queue to join the game.")
		else
			SSticker.queued_players += new_player
			to_chat(new_player, "<span class='notice'>You have been added to the queue to join the game. Your position in queue is [SSticker.queued_players.len].")
		return
	new_player.LateChoices()

/atom/movable/screen/lobby/button/join/proc/show_join_button(status)
	set_button_status(TRUE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP)

/atom/movable/screen/lobby/button/observe
	screen_loc = "TOP:-40,CENTER:-54"
	icon = 'icons/hud/lobby/observe.dmi'
	icon_state = "observe_disabled"
	base_icon_state = "observe"
	enabled = FALSE

/atom/movable/screen/lobby/button/observe/Initialize(mapload)
	. = ..()
	if(SSticker.current_state > GAME_STATE_STARTUP)
		set_button_status(TRUE)
	else
		RegisterSignal(SSticker, COMSIG_TICKER_ENTER_PREGAME, .proc/enable_observing)

/atom/movable/screen/lobby/button/observe/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/dead/new_player/new_player = hud.mymob
	new_player.make_me_an_observer()

/atom/movable/screen/lobby/button/observe/proc/enable_observing()
	flick("[base_icon_state]_enabled", src)
	set_button_status(TRUE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ENTER_PREGAME, .proc/enable_observing)


/atom/movable/screen/lobby/button/changelog_button
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "changelog"
	base_icon_state = "changelog"
	screen_loc ="TOP:-122,CENTER:+58"


/atom/movable/screen/lobby/button/crew_manifest
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "crew_manifest"
	base_icon_state = "crew_manifest"
	screen_loc = "TOP:-122,CENTER:+30"

/atom/movable/screen/lobby/button/crew_manifest/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/dead/new_player/new_player = hud.mymob
	new_player.ViewManifest()

/atom/movable/screen/lobby/button/changelog_button/Click(location, control, params)
	. = ..()
	usr.client?.changelog()

/atom/movable/screen/lobby/button/poll
	icon = 'icons/hud/lobby/bottom_buttons.dmi'
	icon_state = "poll"
	base_icon_state = "poll"
	screen_loc = "TOP:-122,CENTER:+2"

	var/new_poll = FALSE

///Need to use New due to init
/atom/movable/screen/lobby/button/poll/New(loc, ...)
	. = ..()
	if(!usr) //
		return
	var/mob/dead/new_player/new_player = usr
	if(IsGuestKey(new_player.key))
		set_button_status(FALSE)
		return
	if(!SSdbcore.Connect())
		set_button_status(FALSE)
		return
	var/isadmin = FALSE
	if(new_player.client?.holder)
		isadmin = TRUE
	var/datum/DBQuery/query_get_new_polls = SSdbcore.NewQuery({"
		SELECT id FROM [format_table_name("poll_question")]
		WHERE (adminonly = 0 OR :isadmin = 1)
		AND Now() BETWEEN starttime AND endtime
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_vote")]
			WHERE ckey = :ckey
		)
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_textreply")]
			WHERE ckey = :ckey
		)
	"}, list("isadmin" = isadmin, "ckey" = new_player.ckey))
	if(query_get_new_polls.Execute())
		if(query_get_new_polls.NextRow())
			new_poll = TRUE
		else
			new_poll = FALSE
	update_overlays()
	qdel(query_get_new_polls)
	if(QDELETED(new_player))
		set_button_status(FALSE)
		return

/atom/movable/screen/lobby/button/poll/proc/update_overlays()
	cut_overlays()
	if(new_poll)
		add_overlay(mutable_appearance('icons/hud/lobby/poll_overlay.dmi', "new_poll"))

/atom/movable/screen/lobby/button/poll/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/dead/new_player/new_player = hud.mymob
	new_player.handle_player_polling()

/atom/movable/screen/lobby/timer
	icon = 'icons/hud/lobby/countdown_background.dmi'
	icon_state = "hidden"
	screen_loc = "TOP,RIGHT"

	var/list/atom/movable/screen/lobby/display/displays = list()

	var/delayed = FALSE
	var/active = FALSE
	var/show_numbers = FALSE

	var/list/display_screen_locs = list(
		"TOP:-7,RIGHT:-64", 
		"TOP:-7,RIGHT:-44", 
		"TOP:-7,RIGHT:-31"
	)

GLOBAL_LIST_EMPTY(lobby_timers)

/atom/movable/screen/lobby/timer/New(loc, ...)
	. = ..()
	for(var/screen_loc as anything in display_screen_locs)
		var/atom/movable/screen/lobby/display/D = new()
		D.screen_loc = screen_loc
		displays += D
	
	if(SSticker.current_state > GAME_STATE_STARTUP)
		set_active(TRUE)
	else
		RegisterSignal(SSticker, COMSIG_TICKER_ENTER_PREGAME, .proc/activate)

/atom/movable/screen/lobby/timer/proc/set_active(new_active)
	if(new_active == active)
		return
	active = new_active

	if(active)
		flick("show_[delayed ? "delayed" : "eta"]", src)
		addtimer(VARSET_CALLBACK(src, show_numbers, 13))
		RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, .proc/deactivate)
		START_PROCESSING(SSlobbyprocess, src)
	else
		flick("hide_[delayed ? "delayed" : "eta"]", src)
		show_numbers = FALSE
		hide_numbers()
		STOP_PROCESSING(SSlobbyprocess, src)
	update_icon()

/atom/movable/screen/lobby/timer/proc/activate()
	UnregisterSignal(SSticker, COMSIG_TICKER_ENTER_PREGAME)
	set_active(TRUE)

/atom/movable/screen/lobby/timer/proc/deactivate()
	UnregisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP)
	set_active(FALSE)

/atom/movable/screen/lobby/timer/Destroy()
	. = ..()
	GLOB.lobby_timers -= src

/atom/movable/screen/lobby/timer/process()

	var/time = SSticker.GetTimeLeft()
	if(time == -10)
		if(!delayed)
			delay()
		return
	if(delayed)
		undelay()

	if(!show_numbers)
		return

	if(time < 0)
		time = 0

	var/seconds = round(time/10)
	if(seconds > 639)
		seconds = 639

	var/minutes = round(seconds/60)
	if(minutes > 9)
		minutes = 9
	seconds -= minutes * 60

	var/tens_seconds = round(seconds/10)
	var/single_seconds = seconds % 10

	displays[1].icon_state = "[minutes]-green"
	displays[2].icon_state = "[tens_seconds]-green"
	displays[3].icon_state = "[single_seconds]-green"

/atom/movable/screen/lobby/timer/postInit()
	. = ..()
	for(var/atom/movable/screen/lobby/display/D as anything in displays)
		D.hud = hud
		hud.static_inventory += D
	GLOB.lobby_timers += src

/atom/movable/screen/lobby/timer/proc/hide_numbers()
	for(var/atom/movable/screen/lobby/display/D as anything in displays)
		D.icon_state = ""

/atom/movable/screen/lobby/timer/proc/delay()
	if(delayed) return
	delayed = TRUE
	hide_numbers()
	flick("eta_delay", src)
	show_numbers = FALSE
	update_icon()

/atom/movable/screen/lobby/timer/proc/undelay()
	if(!delayed) return
	delayed = FALSE
	flick("delay_eta", src)
	addtimer(VARSET_CALLBACK(src, show_numbers, 6))
	update_icon()

/atom/movable/screen/lobby/timer/proc/update_icon()
	if(!active)
		icon_state = "hidden"
		return
	if(delayed)
		icon_state = "delayed"
	else
		icon_state = "eta"

/atom/movable/screen/lobby/display
	icon = 'icons/hud/lobby/countdown_letters.dmi'