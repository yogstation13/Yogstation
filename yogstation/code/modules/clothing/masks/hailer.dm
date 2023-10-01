/datum/action/item_action/dispatch
	name = "Signal dispatch"
	desc = "Opens up a quick select wheel for reporting crimes, including your current location, to your fellow security officers."
	button_icon_state = "dispatch"
	button_icon = 'yogstation/icons/mob/actions/actions.dmi'

/obj/item/clothing/mask/gas/sechailer
	var/obj/item/radio/radio //For engineering alerts.
	var/radio_key = /obj/item/encryptionkey/headset_medsec //needs med to in order to request medical help for one of the things
	var/dispatch_cooldown = 250
	var/last_dispatch = 0
	var/list/options = list(
		"601 (Murder)" = RADIO_CHANNEL_SECURITY, 
		"101 (Resisting Arrest)" = RADIO_CHANNEL_SECURITY, 
		"309 (Breaking and entering)" = RADIO_CHANNEL_SECURITY, 
		"306 (Riot)" = RADIO_CHANNEL_SECURITY, 
		"401 (Assault, Officer)" = RADIO_CHANNEL_SECURITY,
		"69 (Injured Civilian)" = RADIO_CHANNEL_MEDICAL
		)

/obj/item/clothing/mask/gas/sechailer/Initialize(mapload)
	. = ..()
	GLOB.sechailers += src
	radio = new(src)
	radio.keyslot = new radio_key
	radio.listening = FALSE
	radio.recalculateChannels()

/obj/item/clothing/mask/gas/sechailer/Destroy()
	QDEL_NULL(radio)
	GLOB.sechailers -= src
	. = ..()

/obj/item/clothing/mask/gas/sechailer/proc/dispatch(mob/user)
	var/area/A = get_area(src)
	if(world.time < last_dispatch + dispatch_cooldown)
		to_chat(user, span_notice("Dispatch radio broadcasting systems are recharging."))
		return FALSE
	var/list/display = list()
	for(var/option in options)
		display[option] = image(icon = 'yogstation/icons/effects/aiming.dmi', icon_state = option)
	var/message = show_radial_menu(user, user, display)
	if(!message)
		return FALSE
	radio.talk_into(src, "Dispatch, code [message] in progress in [A], requesting assistance.", options[message])
	last_dispatch = world.time
	for(var/atom/movable/hailer in GLOB.sechailers)
		if(hailer.loc &&ismob(hailer.loc))
			playsound(hailer.loc, "yogstation/sound/voice/dispatch_please_respond.ogg", 100, FALSE)
