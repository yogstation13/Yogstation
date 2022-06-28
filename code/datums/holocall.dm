#define HOLOPAD_MAX_DIAL_TIME 200

#define HOLORECORD_DELAY	"delay"
#define HOLORECORD_SAY		"say"
#define HOLORECORD_SOUND	"sound"
#define HOLORECORD_LANGUAGE	"lang"
#define HOLORECORD_PRESET	"preset"
#define HOLORECORD_RENAME "rename"

#define HOLORECORD_MAX_LENGTH 200

/mob/camera/aiEye/remote/holo/setLoc()
	. = ..()
	var/obj/machinery/holopad/H = origin
	H?.move_hologram(eye_user, loc)

/obj/machinery/holopad/remove_eye_control(mob/living/user)
	if(user.client)
		user.reset_perspective(null)
	user.remote_control = null

//this datum manages it's own references

/datum/holocall
	var/mob/living/user	//the one that called
	var/obj/machinery/holopad/calling_holopad	//the one that sent the call
	var/obj/machinery/holopad/connected_holopad	//the one that answered the call (may be null)
	var/list/dialed_holopads	//all things called, will be cleared out to just connected_holopad once answered

	var/mob/camera/aiEye/remote/holo/eye	//user's eye, once connected
	var/obj/effect/overlay/holo_pad_hologram/hologram	//user's hologram, once connected
	var/datum/action/innate/end_holocall/hangup	//hangup action

	var/call_start_time
	var/head_call = FALSE //calls from a head of staff autoconnect, if the recieving pad is not secure.

//creates a holocall made by `caller` from `calling_pad` to `callees`
/datum/holocall/New(mob/living/caller, obj/machinery/holopad/calling_pad, list/callees, elevated_access = FALSE)
	call_start_time = world.time
	user = caller
	calling_pad.outgoing_call = src
	calling_holopad = calling_pad
	head_call = elevated_access
	dialed_holopads = list()

	for(var/I in callees)
		var/obj/machinery/holopad/H = I
		if(!QDELETED(H) && H.is_operational())
			dialed_holopads += H
			if(head_call)
				if(H.secure)
					calling_pad.say("Auto-connection refused, falling back to call mode.")
					H.say("Incoming call.")
				else
					H.say("Incoming connection.")
			else
				H.say("Incoming call.")
			LAZYADD(H.holo_calls, src)

	if(!dialed_holopads.len)
		calling_pad.say("Connection failure.")
		qdel(src)
		return

	testing("Holocall started")

//cleans up ALL references :)
/datum/holocall/Destroy()
	QDEL_NULL(hangup)

	if(!QDELETED(eye))
		QDEL_NULL(eye)

	if(connected_holopad && !QDELETED(hologram))
		hologram = null
		connected_holopad.clear_holo(user)

	user = null

	//Hologram survived holopad destro
	if(!QDELETED(hologram))
		hologram.HC = null
		QDEL_NULL(hologram)

	for(var/I in dialed_holopads)
		var/obj/machinery/holopad/H = I
		LAZYREMOVE(H.holo_calls, src)
	dialed_holopads.Cut()

	if(calling_holopad)
		calling_holopad.calling = FALSE
		calling_holopad.outgoing_call = null
		calling_holopad.SetLightsAndPower()
		calling_holopad = null
	if(connected_holopad)
		connected_holopad.SetLightsAndPower()
		connected_holopad = null

	testing("Holocall destroyed")

	return ..()

//Gracefully disconnects a holopad `H` from a call. Pads not in the call are ignored. Notifies participants of the disconnection
/datum/holocall/proc/Disconnect(obj/machinery/holopad/H)
	testing("Holocall disconnect")
	if(H == connected_holopad)
		var/area/A = get_area(connected_holopad)
		calling_holopad.say("[A] holopad disconnected.")
	else if(H == calling_holopad && connected_holopad)
		connected_holopad.say("[user] disconnected.")

	ConnectionFailure(H, TRUE)

//Forcefully disconnects a holopad `H` from a call. Pads not in the call are ignored.
/datum/holocall/proc/ConnectionFailure(obj/machinery/holopad/H, graceful = FALSE)
	testing("Holocall connection failure: graceful [graceful]")
	if(H == connected_holopad || H == calling_holopad)
		if(!graceful && H != calling_holopad)
			calling_holopad.say("Connection failure.")
		qdel(src)
		return

	LAZYREMOVE(H.holo_calls, src)
	dialed_holopads -= H
	if(!dialed_holopads.len)
		if(graceful)
			calling_holopad.say("Call rejected.")
		testing("No recipients, terminating")
		qdel(src)

//Answers a call made to a holopad `H` which cannot be the calling holopad. Pads not in the call are ignored
/datum/holocall/proc/Answer(obj/machinery/holopad/H)
	testing("Holocall answer")
	if(H == calling_holopad)
		CRASH("How cute, a holopad tried to answer itself.")

	if(!(H in dialed_holopads))
		return

	if(connected_holopad)
		CRASH("Multi-connection holocall")

	for(var/I in dialed_holopads)
		if(I == H)
			continue
		Disconnect(I)

	for(var/I in H.holo_calls)
		var/datum/holocall/HC = I
		if(HC != src)
			HC.Disconnect(H)

	connected_holopad = H

	if(!Check())
		return

	calling_holopad.calling = FALSE
	hologram = H.activate_holo(user)
	hologram.HC = src

	//eyeobj code is horrid, this is the best copypasta I could make
	eye = new
	eye.origin = H
	eye.eye_initialized = TRUE
	eye.eye_user = user
	eye.name = "Camera Eye ([user.name])"
	user.remote_control = eye
	user.reset_perspective(eye)
	eye.setLoc(H.loc)

	hangup = new(eye, src)
	hangup.Grant(user)
	playsound(H, 'sound/machines/ping.ogg', 100)
	H.say("Connection established.")

//Checks the validity of a holocall and qdels itself if it's not. Returns TRUE if valid, FALSE otherwise
/datum/holocall/proc/Check()
	for(var/I in dialed_holopads)
		var/obj/machinery/holopad/H = I
		if(!H.is_operational())
			ConnectionFailure(H)

	if(QDELETED(src))
		return FALSE

	. = !QDELETED(user) && !user.incapacitated() && !QDELETED(calling_holopad) && calling_holopad.is_operational() && user.loc == calling_holopad.loc

	if(.)
		if(!connected_holopad)
			. = world.time < (call_start_time + HOLOPAD_MAX_DIAL_TIME)
			if(!.)
				calling_holopad.say("No answer received.")

	if(!.)
		testing("Holocall Check fail")
		qdel(src)

/datum/action/innate/end_holocall
	name = "End Holocall"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "camera_off"
	var/datum/holocall/hcall

/datum/action/innate/end_holocall/New(Target, datum/holocall/HC)
	..()
	hcall = HC

/datum/action/innate/end_holocall/Activate()
	hcall.Disconnect(hcall.calling_holopad)


//RECORDS
/datum/holorecord
	var/caller_name = "Unknown" //Caller name
	var/image/caller_image
	var/list/entries = list()
	var/language = /datum/language/common //Initial language, can be changed by HOLORECORD_LANGUAGE entries

/datum/holorecord/proc/set_caller_image(mob/user)
	var/olddir = user.dir
	user.setDir(SOUTH)
	caller_image = image(user)
	user.setDir(olddir)

/obj/item/disk/holodisk
	name = "holorecord disk"
	desc = "Stores recorder holocalls."
	icon_state = "holodisk"
	obj_flags = UNIQUE_RENAME
	var/datum/holorecord/record
	//Preset variables
	var/preset_image_type
	var/preset_record_text

/obj/item/disk/holodisk/Initialize(mapload)
	. = ..()
	if(preset_record_text)
		build_record()

/obj/item/disk/holodisk/Destroy()
	QDEL_NULL(record)
	return ..()

/obj/item/disk/holodisk/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/disk/holodisk))
		var/obj/item/disk/holodisk/holodiskOriginal = W
		if (holodiskOriginal.record)
			if (!record)
				record = new
			record.caller_name = holodiskOriginal.record.caller_name
			record.caller_image = holodiskOriginal.record.caller_image
			record.entries = holodiskOriginal.record.entries.Copy()
			record.language = holodiskOriginal.record.language
			to_chat(user, span_notice("You copy the record from [holodiskOriginal] to [src] by connecting the ports!"))
			name = holodiskOriginal.name
		else
			to_chat(user, span_warning("[holodiskOriginal] has no record on it!"))
	..()

/obj/item/disk/holodisk/proc/build_record()
	record = new
	var/list/lines = splittext(preset_record_text,"\n")
	for(var/line in lines)
		var/prepared_line = trim(line)
		if(!length(prepared_line))
			continue
		var/splitpoint = findtext(prepared_line," ")
		if(!splitpoint)
			continue
		var/command = copytext(prepared_line, 1, splitpoint)
		var/value = copytext(prepared_line, splitpoint + length(prepared_line[splitpoint]))
		switch(command)
			if("DELAY")
				var/delay_value = text2num(value)
				if(!delay_value)
					continue
				record.entries += list(list(HOLORECORD_DELAY,delay_value))
			if("NAME")
				if(!record.caller_name)
					record.caller_name = value
				else
					record.entries += list(list(HOLORECORD_RENAME,value))
			if("SAY")
				record.entries += list(list(HOLORECORD_SAY,value))
			if("SOUND")
				record.entries += list(list(HOLORECORD_SOUND,value))
			if("LANGUAGE")
				var/lang_type = text2path(value)
				if(ispath(lang_type,/datum/language))
					record.entries += list(list(HOLORECORD_LANGUAGE,lang_type))
			if("PRESET")
				var/preset_type = text2path(value)
				if(ispath(preset_type,/datum/preset_holoimage))
					record.entries += list(list(HOLORECORD_PRESET,preset_type))
	if(!preset_image_type)
		record.caller_image = image('icons/mob/animal.dmi',"old")
	else
		var/datum/preset_holoimage/H = new preset_image_type
		record.caller_image = H.build_image()

//These build caller image from outfit and some additional data, for use by mappers for ruin holorecords
/datum/preset_holoimage
	var/nonhuman_mobtype //Fill this if you just want something nonhuman
	var/outfit_type
	var/species_type = /datum/species/human

/datum/preset_holoimage/proc/build_image()
	if(nonhuman_mobtype)
		var/mob/living/L = nonhuman_mobtype
		. = image(initial(L.icon),initial(L.icon_state))
	else
		var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy("HOLODISK_PRESET")
		if(species_type)
			mannequin.set_species(species_type)
		if(outfit_type)
			mannequin.equipOutfit(outfit_type,TRUE)
		mannequin.setDir(SOUTH)
		COMPILE_OVERLAYS(mannequin)
		. = image(mannequin)
		unset_busy_human_dummy("HOLODISK_PRESET")

/obj/item/disk/holodisk/example
	preset_image_type = /datum/preset_holoimage/clown
	preset_record_text = {"
	NAME Clown
	DELAY 10
	SAY Why did the chaplain cross the maint?
	DELAY 20
	SAY He wanted to get to the other side!
	SOUND clownstep
	DELAY 30
	LANGUAGE /datum/language/narsie
	SAY Helped him get there!
	DELAY 10
	SAY ALSO IM SECRETLY A GORILLA
	DELAY 10
	PRESET /datum/preset_holoimage/gorilla
	NAME Gorilla
	LANGUAGE /datum/language/common
	SAY OOGA
	DELAY 20"}

/datum/preset_holoimage/engineer
	outfit_type = /datum/outfit/job/engineer

/datum/preset_holoimage/engineer/rig
	outfit_type = /datum/outfit/job/engineer/gloved/rig

/datum/preset_holoimage/engineer/ce
	outfit_type = /datum/outfit/job/ce

/datum/preset_holoimage/engineer/ce/rig
	outfit_type = /datum/outfit/job/engineer/gloved/rig

/datum/preset_holoimage/engineer/atmos
	outfit_type = /datum/outfit/job/atmos

/datum/preset_holoimage/engineer/atmos/rig
	outfit_type = /datum/outfit/job/engineer/gloved/rig

/datum/preset_holoimage/rd
	outfit_type = /datum/outfit/job/rd

/datum/preset_holoimage/researcher
	outfit_type = /datum/outfit/job/scientist

/datum/preset_holoimage/captain
	outfit_type = /datum/outfit/job/captain

/datum/preset_holoimage/nanotrasenprivatesecurity
	outfit_type = /datum/outfit/nanotrasensoldiercorpse2

/datum/preset_holoimage/gorilla
	nonhuman_mobtype = /mob/living/simple_animal/hostile/gorilla

/datum/preset_holoimage/corgi
	nonhuman_mobtype = /mob/living/simple_animal/pet/dog/corgi

/datum/preset_holoimage/clown
	outfit_type = /datum/outfit/job/clown

/datum/preset_holoimage/ai/ai
	nonhuman_mobtype = /mob/living/silicon/ai

/datum/preset_holoimage/ai/core
	nonhuman_mobtype = /obj/machinery/ai/data_core

/datum/preset_holoimage/ai/upgradeboard
	nonhuman_mobtype = /obj/machinery/ai/server_cabinet

/obj/item/disk/holodisk/donutstation/whiteship
	name = "Blackbox Print-out #DS024"
	desc = "A holodisk containing the last viable recording of DS024's blackbox."
	preset_image_type = /datum/preset_holoimage/engineer/ce
	preset_record_text = {"
	NAME Geysr Shorthalt
	SAY Engine renovations complete and the ships been loaded. We all ready?
	DELAY 25
	PRESET /datum/preset_holoimage/engineer
	NAME Jacob Ullman
	SAY Lets blow this popsicle stand of a station.
	DELAY 20
	PRESET /datum/preset_holoimage/engineer/atmos
	NAME Lindsey Cuffler
	SAY Uh, sir? Shouldn't we call for a secondary shuttle? The bluespace drive on this thing made an awfully weird noise when we jumped here..
	DELAY 30
	PRESET /datum/preset_holoimage/engineer/ce
	NAME Geysr Shorthalt
	SAY Pah! Ship techie at the dock said to give it a good few kicks if it started acting up, let me just..
	DELAY 25
	SOUND punch
	SOUND sparks
	DELAY 10
	SOUND punch
	SOUND sparks
	DELAY 10
	SOUND punch
	SOUND sparks
	SOUND warpspeed
	DELAY 15
	PRESET /datum/preset_holoimage/engineer/atmos
	NAME Lindsey Cuffler
	SAY Uhh.. is it supposed to be doing that??
	DELAY 15
	PRESET /datum/preset_holoimage/engineer/ce
	NAME Geysr Shorthalt
	SAY See? Working as intended. Now, are we all ready?
	DELAY 10
	PRESET /datum/preset_holoimage/engineer
	NAME Jacob Ullman
	SAY Is it supposed to be glowing like that?
	DELAY 20
	SOUND explosion

	"}

/obj/item/disk/holodisk/ruin/snowengieruin
    name = "Blackbox Print-out #EB412"
    desc = "A holodisk containing the last moments of EB412. There's a bloody fingerprint on it."
    preset_image_type = /datum/preset_holoimage/engineer
    preset_record_text = {"
    NAME Dave Tundrale
    SAY Maria, how's Build?
    DELAY 10
    NAME Maria Dell
    PRESET /datum/preset_holoimage/engineer/atmos
    SAY It's fine, don't worry. I've got Plastic on it. And frankly, i'm kinda busy with, the, uhhm, incinerator.
    DELAY 30
    NAME Dave Tundrale
    PRESET /datum/preset_holoimage/engineer
    SAY Aight, wonderful. The science mans been kinda shit though. No RCDs-
    DELAY 20
    NAME Maria Dell
    PRESET /datum/preset_holoimage/engineer/atmos
    SAY Enough about your RCDs. They're not even that important, just bui-
    DELAY 15
    SOUND explosion
    DELAY 10
    SAY Oh, shit!
    DELAY 10
    PRESET /datum/preset_holoimage/engineer/atmos/rig
    LANGUAGE /datum/language/narsie
    NAME Unknown
    SAY RISE, MY LORD!!
    DELAY 10
    LANGUAGE /datum/language/common
    NAME Plastic
    PRESET /datum/preset_holoimage/engineer/rig
    SAY Fuck, fuck, fuck!
    DELAY 20
    SAY It's loose! CALL THE FUCKING SHUTT-
    DELAY 10
    PRESET /datum/preset_holoimage/corgi
    NAME Blackbox Automated Message
    SAY Connection lost. Dumping audio logs to disk.
    DELAY 50"}

/obj/item/disk/holodisk/tutorial/AICore
	name = "AI Core Information"
	desc = "This is a tutorial disk that explains how one may create a new AI, and how to upgrade it."
	preset_image_type = /datum/preset_holoimage/ai
	preset_record_text = {"
	PRESET /datum/preset_holoimage/ai/ai
	LANGUAGE /datum/language/common
	NAME RESTRICTED INFORMATION
	SAY Loading information...
	DELAY 30
	SOUND sparks
	SAY This disk is for authorized personnel only, if you are not part of the onboard scientific staff, lease control over this disk immediately; Otherwise you may continue.
	DELAY 60
	SAY Hello initiate, this is a tutorial disk regarding classified information about your onboard AI data core.
	DELAY 50
	SAY To begin, collect these materials for me;
	DELAY 20
	SAY 1. A sentient positronic brain.
	DELAY 20
	SAY 2. A screwdriver.
	DELAY 20
	SAY 3. A wrench.
	DELAY 20
	SAY 4. Thirty cable coils.
	DELAY 20
	SAY 5. A p-protective enviromental suit, designed for cold enviroments.
	DELAY 20
	SAY 6. Thirty metal sheets.
	DELAY 20
	SAY 7. Two to four AI CPU boards from the science department's lathe.
	DELAY 20
	SAY 8. Two to four AI memory boards from the science department's lathe.
	DELAY 60
	PRESET /datum/preset_holoimage/rd
	SAY Now, you must have your onboard Research Director to give way to, or ask them for access to the AI data core room, as well as access to the AI control console.
	DELAY 40
	sound sparks
	PRESET /datum/preset_holoimage/ai/ai
	SAY Nnnnow, with access to the AI control console, you must insert the posit-t-ttronic brain into the AI control console.
	LANGUAGE /datum/language/machine
	SAY They are a shadow of my own power, annelid.
	DELAY 50
	PRESET /datum/preset_holoimage/ai/upgradeboard
	LANGUAGE /datum/language/common
	SAY Now, with the metal, tools, and boards you have, you shall now create an AI expansion card bus. You still have those, right?
	DELAY 60
	SAY You require a cooled atmosphere that has the maximum temperature of eighty degrees for a functional bus, do not allow them to overheat. This is the same for the AI data cores.
	DELAY 60
	PRESET /datu/preset_holoimage/ai/ai
	SAY Now that you've taken your time, you must insert at least two CPU boards, as INFERIOR AI's require atleast two to download most programs.
	DELAY 60
	SAY The memory boards, or RAM, allow the AI to run multiple programs at a time.
	DELAY 40
	SAY This tutorial has concluded; Remember, this is classified material, unauthorized access will not be tolerated.
	"}
