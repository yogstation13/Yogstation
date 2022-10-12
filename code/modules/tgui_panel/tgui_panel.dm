/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * tgui_panel datum
 * Hosts tgchat and other nice features.
 */
/datum/tgui_panel
	var/client/client
	var/datum/tgui_window/window
	var/broken = FALSE
	var/initialized_at
	var/retries = 0

/datum/tgui_panel/New(client/client)
	src.client = client
	window = new(client, "browseroutput")
	window.subscribe(src, .proc/on_message)

/datum/tgui_panel/Del()
	window.unsubscribe(src)
	window.close()
	return ..()

/**
 * public
 *
 * TRUE if panel is initialized and ready to receive messages.
 */
/datum/tgui_panel/proc/is_ready()
	return !broken && window.is_ready()

/**
 * public
 *
 * Initializes tgui panel.
 */
/datum/tgui_panel/proc/initialize(force = FALSE)
	set waitfor = FALSE
	// Minimal sleep to defer initialization to after client constructor
	sleep(0.1 SECONDS)
	initialized_at = world.time
	// Perform a clean initialization
	window.initialize(inline_assets = list(
		get_asset_datum(/datum/asset/simple/tgui_common),
		get_asset_datum(/datum/asset/simple/tgui_panel),
	))
	window.send_asset(get_asset_datum(/datum/asset/simple/namespaced/fontawesome))
	window.send_asset(get_asset_datum(/datum/asset/spritesheet/chat))
	request_telemetry()
	if(!telemetry_connections && retries < 6)
		addtimer(CALLBACK(src, .proc/check_telemetry), 2 SECONDS)
	addtimer(CALLBACK(src, .proc/on_initialize_timed_out), 2 SECONDS)

/datum/tgui_panel/proc/check_telemetry()
	if(!telemetry_connections) /// Somethings fucked lets try again.
		if(retries > 2)
			if(client && istype(client))
				winset(client, null, "command=.reconnect") /// Kitchen Sink
				qdel(client)
		if(retries > 3)
			qdel(client)
		if(retries > 5)
			return // I give up
		if(retries < 6)
			retries++
		src << browse(file('html/statbrowser.html'), "window=statbrowser")  /// Reloads the statpanel as well
		initialize() /// Lets just start again
		var/mob/dead/new_player/M = client?.mob
		if(istype(M))
			M.Login()

/**
 * private
 *
 * Called when initialization has timed out.
 */
 
/datum/tgui_panel/proc/on_initialize_timed_out()
	// Currently does nothing but sending a message to old chat.
	SEND_TEXT(client, span_userdanger("Failed to load fancy chat, click <a href='?src=[REF(src)];reload_tguipanel=1'>HERE</a> to attempt to reload it."))

/**
 * private
 *
 * Callback for handling incoming tgui messages.
 */
/datum/tgui_panel/proc/on_message(type, payload)
	if(type == "ready")
		broken = FALSE
		window.send_message("update", list(
			"config" = list(
				"client" = list(
					"ckey" = client.ckey,
					"address" = client.address,
					"computer_id" = client.computer_id,
				),
				"window" = list(
					"fancy" = FALSE,
					"locked" = FALSE,
				),
			),
		))
		return TRUE
	if(type == "audio/setAdminMusicVolume")
		client.admin_music_volume = payload["volume"]
		return TRUE
	if(type == "telemetry")
		analyze_telemetry(payload)
		return TRUE

/**
 * public
 *
 * Sends a round restart notification.
 */
/datum/tgui_panel/proc/send_roundrestart()
	window.send_message("roundrestart")

/datum/tgui_panel/proc/send_connected()
	window.send_message("reconnected")
