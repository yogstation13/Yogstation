/obj/item/assembly/radio
	name = "radio announcer"
	desc = "A device that anounces a message over a radio channel."
	icon_state = "control"

	var/obj/item/radio/radio
	var/radio_key
	var/radio_channel = RADIO_CHANNEL_COMMON
	var/use_command = FALSE

	// Message sent when activated
	var/message = "Hello!"
	// How long before another message can be sent
	var/cooldown_time = 0 SECONDS
	// What area is required for this device to work, if there is any 
	var/required_area
	// If the encryption key can be removed
	var/key_locked = FALSE

/obj/item/assembly/radio/Initialize()
	. = ..()
	radio = new(src)
	if(radio_key)
		radio.keyslot = new radio_key
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.use_command = use_command
	radio.recalculateChannels()

// Can't do screwdrivers as assemblies have code linked to that
/obj/item/assembly/radio/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(key_locked)
		to_chat(user, span_notice("[src]'s encryption key slot is locked!"))
		return
	if(!radio.keyslot)
		to_chat(user, span_notice("[src] doesn't have any encryption keys!"))
		return 
	to_chat(user, span_notice("You pop out [radio.keyslot] from [src]."))
	user.put_in_hands(radio.keyslot)
	radio.keyslot = null
	radio.recalculateChannels()

/obj/item/assembly/radio/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	message = pretty_filter(stripped_input(user, "What would you like the new message to be?", "[src]", message))

/obj/item/assembly/radio/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(istype(I, /obj/item/encryptionkey))
		if(radio.keyslot)
			to_chat(user, span_warning("[src] can't hold another key!"))
			return
		if(!user.transferItemToLoc(I, src))
			return
		radio.keyslot = I
	
/obj/item/assembly/radio/activate()
	if(TIMER_COOLDOWN_CHECK(src, "message") || (required_area && !istype(get_area(src), required_area)) || !message)
		return
	TIMER_COOLDOWN_START(src, "message", cooldown_time)
	radio.talk_into(src, message, radio_channel)


/// Desk Bells ///

/obj/item/assembly/radio/bell
	name = "desk bell announcer"
	message = "Presence requested at the front desk"
	cooldown_time = 1 MINUTES
	key_locked = TRUE

// Command
/obj/item/assembly/radio/bell/meeting
	message = "Presence requested at the meeting room"
	required_area = /area/bridge/meeting_room
	radio_key = /obj/item/encryptionkey/headset_com
	radio_channel = RADIO_CHANNEL_COMMAND
	use_command = TRUE

/obj/item/assembly/radio/bell/hop
	message = "Presence requested at the Head of Personnel's office"
	required_area = /area/crew_quarters/heads/hop
	radio_key = /obj/item/encryptionkey/headset_com
	radio_channel = RADIO_CHANNEL_COMMAND

// Sec
/obj/item/assembly/radio/bell/sec
	required_area = /area/security/brig
	radio_key = /obj/item/encryptionkey/headset_sec
	radio_channel = RADIO_CHANNEL_SECURITY

/obj/item/assembly/radio/bell/sec_meeting
	message = "Presence requested at the security office"
	required_area = /area/security/main
	radio_key = /obj/item/encryptionkey/headset_sec
	radio_channel = RADIO_CHANNEL_SECURITY
	use_command = TRUE

/obj/item/assembly/radio/bell/warden
	message = "Presence requested at the brig control"
	required_area = /area/security/warden
	radio_key = /obj/item/encryptionkey/headset_sec
	radio_channel = RADIO_CHANNEL_SECURITY
	use_command = TRUE

/obj/item/assembly/radio/bell/armory
	message = "Presence requested at the armory"
	required_area = /area/ai_monitored/security/armory
	radio_key = /obj/item/encryptionkey/headset_sec
	radio_channel = RADIO_CHANNEL_SECURITY
	use_command = TRUE

// Engi
/obj/item/assembly/radio/bell/engi
	required_area = /area/engine/foyer
	radio_key = /obj/item/encryptionkey/headset_eng
	radio_channel = RADIO_CHANNEL_ENGINEERING

/obj/item/assembly/radio/bell/atmos
	message = "Presence requested at the atmospherics desk"
	required_area = /area/engine/atmos
	radio_key = /obj/item/encryptionkey/headset_eng
	radio_channel = RADIO_CHANNEL_ENGINEERING

// Sci
/obj/item/assembly/radio/bell/sci
	required_area = /area/science/lab
	radio_key = /obj/item/encryptionkey/headset_sci
	radio_channel = RADIO_CHANNEL_SCIENCE

/obj/item/assembly/radio/bell/robotics
	message = "Presence requested at the robotics desk"
	required_area = /area/science/robotics/lab
	radio_key = /obj/item/encryptionkey/headset_sci
	radio_channel = RADIO_CHANNEL_SCIENCE

/obj/item/assembly/radio/bell/xenobio
	message = "Presence requested at the xenobiology desk"
	required_area = /area/science/xenobiology
	radio_key = /obj/item/encryptionkey/headset_sci
	radio_channel = RADIO_CHANNEL_SCIENCE

// Med
/obj/item/assembly/radio/bell/med
	required_area = /area/medical/medbay/lobby
	radio_key = /obj/item/encryptionkey/headset_med
	radio_channel = RADIO_CHANNEL_MEDICAL

/obj/item/assembly/radio/bell/chemistry
	message = "Presence requested at the chemistry desk"
	required_area = /area/medical/chemistry
	radio_key = /obj/item/encryptionkey/headset_med
	radio_channel = RADIO_CHANNEL_MEDICAL

/obj/item/assembly/radio/bell/genetics
	message = "Presence requested at the genetics desk"
	required_area = /area/medical/genetics
	radio_key = /obj/item/encryptionkey/headset_med
	radio_channel = RADIO_CHANNEL_MEDICAL

/obj/item/assembly/radio/bell/paramedic
	message = "Presence requested at the paramedic desk"
	required_area = /area/medical/paramedic
	radio_key = /obj/item/encryptionkey/headset_med
	radio_channel = RADIO_CHANNEL_MEDICAL

// Supply
/obj/item/assembly/radio/bell/supply
	required_area = /area/quartermaster/office
	radio_key = /obj/item/encryptionkey/headset_cargo
	radio_channel = RADIO_CHANNEL_SUPPLY

/obj/item/assembly/radio/bell/delivery
	message = "Presence requested at the delivery desk"
	required_area = /area/quartermaster/sorting
	radio_key = /obj/item/encryptionkey/headset_cargo
	radio_channel = RADIO_CHANNEL_SUPPLY

// Service
/obj/item/assembly/radio/bell/kitchen
	message = "Presence requested at the kitchen"
	required_area = /area/crew_quarters/kitchen
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE

/obj/item/assembly/radio/bell/bar
	message = "Presence requested at the bar"
	required_area = /area/crew_quarters/bar
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE

/obj/item/assembly/radio/bell/hydroponics
	message = "Presence requested at the hydroponics desk"
	required_area = /area/hydroponics
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE

/obj/item/assembly/radio/bell/library
	message = "Presence requested at the library"
	required_area = /area/library
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE
