/obj/item/radio/radio_mic
	name = "Radio Microphone"
	desc = "Used to talk over the radio"

	icon = 'monkestation/code/modules/cassettes/icons/radio_station.dmi'
	icon_state = "unce_machine"

	radio_host = TRUE
	universal = TRUE
	command = TRUE

	lossless = TRUE

	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	pass_flags_self = parent_type::pass_flags_self | LETPASSCLICKS

	/// overlay when speaker is on
	overlay_speaker_idle = null
	/// overlay when recieving a message
	overlay_speaker_active = null

	/// overlay when mic is on
	overlay_mic_idle = null
	/// overlay when speaking a message (is displayed simultaniously with speaker_active)
	overlay_mic_active = null


/obj/item/radio/radio_mic/Initialize(mapload)
	. = ..()
	REGISTER_REQUIRED_MAP_ITEM(1, INFINITY)

	frequency = FREQ_RADIO
	broadcasting = TRUE
	use_command = TRUE

	perform_update_icon = FALSE
	should_update_icon = FALSE

	set_broadcasting(TRUE)

/obj/item/radio/radio_mic/ui_interact(mob/user, datum/tgui/ui, datum/ui_state/state)
	return

/obj/item/radio/screwdriver_act(mob/living/user, obj/item/tool)
	add_fingerprint(user)
