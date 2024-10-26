#define ICARUS_IGNITION_TIME (20 SECONDS)

/**
 * GoldenEye defence network
 *
 * Contains: Subsystem, Keycard, Terminal and Objective
 */

SUBSYSTEM_DEF(goldeneye)
	name = "GoldenEye"
	flags = SS_NO_INIT | SS_NO_FIRE
	/// A tracked list of all our keys.
	var/list/goldeneye_keys = list()
	/// A list of minds that have been extracted and thus cannot be extracted again.
	var/list/goldeneye_extracted_minds = list()
	/// How many keys have been uploaded to GoldenEye.
	var/uploaded_keys = 0
	/// How many keys do we need to activate GoldenEye? Can be overriden by Dynamic if there aren't enough heads of staff.
	var/required_keys = GOLDENEYE_REQUIRED_KEYS_MAXIMUM
	/// Have we been activated?
	var/goldeneye_activated = FALSE
	/// How long until ICARUS fires?
	var/ignition_time = ICARUS_IGNITION_TIME

/datum/controller/subsystem/goldeneye/Recover()
	goldeneye_keys = SSgoldeneye.goldeneye_keys
	goldeneye_extracted_minds = SSgoldeneye.goldeneye_extracted_minds
	uploaded_keys = SSgoldeneye.uploaded_keys
	required_keys = SSgoldeneye.required_keys
	goldeneye_activated = SSgoldeneye.goldeneye_activated
	ignition_time = SSgoldeneye.ignition_time

/// A safe proc for adding a targets mind to the tracked extracted minds.
/datum/controller/subsystem/goldeneye/proc/extract_mind(datum/mind/target_mind)
	goldeneye_extracted_minds += target_mind

/// A safe proc for registering a new key to the goldeneye system.
/datum/controller/subsystem/goldeneye/proc/upload_key()
	uploaded_keys++
	check_condition()

/// Checks our activation condition after an upload has occured.
/datum/controller/subsystem/goldeneye/proc/check_condition()
	if(uploaded_keys >= required_keys)
		activate()
		return
	priority_announce("UNAUTHORISED KEYCARD UPLOAD DETECTED. [uploaded_keys]/[required_keys] KEYCARDS UPLOADED.", "GoldenEye Defence Network")

/// Activates goldeneye.
/datum/controller/subsystem/goldeneye/proc/activate()
	var/message = "/// GOLDENEYE DEFENCE NETWORK BREACHED /// \n \
	Unauthorised GoldenEye Defence Network access detected. \n \
	ICARUS online. \n \
	Targeting system override detected... \n \
	New target: /NTSS13/ \n \
	ICARUS firing protocols activated. \n \
	ETA to fire: [ignition_time / 10] seconds."

	priority_announce(message, "GoldenEye Defence Network", ANNOUNCER_ICARUS)
	goldeneye_activated = TRUE

	addtimer(CALLBACK(src, PROC_REF(fire_icarus)), ignition_time)


/datum/controller/subsystem/goldeneye/proc/fire_icarus()
	var/datum/round_event_control/icarus_sunbeam/event_to_start = new()
	event_to_start.run_event()

/// Checks if a mind(target_mind) is a head and if they aren't in the goldeneye_extracted_minds list.
/datum/controller/subsystem/goldeneye/proc/check_goldeneye_target(datum/mind/target_mind)
	var/list/heads_list = SSjob.get_all_heads()
	for(var/datum/mind/iterating_mind as anything in heads_list)
		if(target_mind == iterating_mind) // We have a match, let's check if they've already been extracted.
			if(target_mind in goldeneye_extracted_minds) // They've already been extracted, no double extracts!
				return FALSE
			return TRUE
	return FALSE

// Goldeneye key
/obj/item/goldeneye_key
	name = "\improper GoldenEye authentication keycard"
	desc = "A high profile authentication keycard to Nanotrasen's GoldenEye defence network. It seems indestructible."
	icon = 'monkestation/code/modules/assault_ops/icons/goldeneye.dmi'
	icon_state = "goldeneye_key"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	max_integrity = INFINITY
	/// A unique tag that is used to identify this key.
	var/goldeneye_tag = "G00000"
	/// Flavour text for who's mind is in the key.
	var/extract_name = "NO DATA"
	/// The color used for the tracking hUD element.
	var/beacon_color = COLOR_WHITE
	/// The tracking beacon component, used so the operatives can track it via HUD arrows.
	var/datum/component/tracking_beacon/beacon

/obj/item/goldeneye_key/Initialize(mapload)
	. = ..()
	SSgoldeneye.goldeneye_keys += src
	goldeneye_tag = "G[rand(10000, 99999)]"
	name = "\improper GoldenEye authentication keycard: [goldeneye_tag]"
	AddComponent(/datum/component/stationloving/goldeneye)
	AddComponent(/datum/component/gps, goldeneye_tag)
	beacon = AddComponent(/datum/component/tracking_beacon, "goldeneye_key", _colour = choose_beacon_color(), _global = TRUE, _always_update = TRUE)
	SSpoints_of_interest.make_point_of_interest(src)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_GOLDENEYE_KEY_CREATED, src)

/obj/item/goldeneye_key/Destroy(force)
	SSgoldeneye.goldeneye_keys -= src
	QDEL_NULL(beacon)
	return ..()

/obj/item/goldeneye_key/proc/choose_beacon_color()
	var/static/list/possible_beacon_colors
	var/static/next_beacon_color = 1
	if(isnull(possible_beacon_colors))
		possible_beacon_colors = shuffle(flatten_list(GLOB.cable_colors))
	beacon_color = possible_beacon_colors[next_beacon_color]
	next_beacon_color = WRAP_UP(next_beacon_color, length(possible_beacon_colors))
	return beacon_color

/obj/item/goldeneye_key/examine(mob/user)
	. = ..()
	. += "The DNA data link belongs to: [extract_name]"

// Upload terminal
/obj/machinery/goldeneye_upload_terminal
	name = "\improper GoldenEye Defnet Upload Terminal"
	desc = "An ominous terminal with some ports and keypads, the screen is scrolling with illegible nonsense. It has a strange marking on the side, a red ring with a gold circle within."
	icon = 'monkestation/code/modules/assault_ops/icons/goldeneye.dmi'
	icon_state = "goldeneye_terminal"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	/// Is the system currently in use? Used to prevent spam and abuse.
	var/uploading = FALSE


/obj/machinery/goldeneye_upload_terminal/attackby(obj/item/weapon, mob/user, params)
	. = ..()
	if(uploading)
		return
	if(!is_station_level(z))
		say("CONNECTION TO GOLDENEYE NOT DETECTED: Please return to comms range.")
		playsound(src, 'sound/machines/nuke/angry_beep.ogg', 100)
		return
	if(!istype(weapon, /obj/item/goldeneye_key))
		say("AUTHENTICATION ERROR: Please do not insert foreign objects into terminal.")
		playsound(src, 'sound/machines/nuke/angry_beep.ogg', 100)
		return
	var/obj/item/goldeneye_key/inserting_key = weapon
	say("GOLDENEYE KEYCARD ACCEPTED: Please wait while the keycard is verified...")
	playsound(src, 'sound/machines/nuke/general_beep.ogg', 100)
	uploading = TRUE
	if(do_after(user, 10 SECONDS, src))
		say("GOLDENEYE KEYCARD AUTHENTICATED!")
		playsound(src, 'sound/machines/nuke/confirm_beep.ogg', 100)
		SSgoldeneye.upload_key()
		uploading = FALSE
		// Remove its stationloving, so we can delete it.
		qdel(inserting_key.GetComponent(/datum/component/stationloving/goldeneye))
		qdel(inserting_key)
	else
		say("GOLDENEYE KEYCARD VERIFICATION FAILED: Please try again.")
		playsound(src, 'sound/machines/nuke/angry_beep.ogg', 100)
		uploading = FALSE

// Objective
/datum/objective/goldeneye
	name = "subvert goldeneye"
	objective_name = "Subvert GoldenEye"
	explanation_text = "Extract all of the required GoldenEye authentication keys from the heads of staff and activate GoldenEye."
	martyr_compatible = TRUE

/datum/objective/goldeneye/check_completion()
	return ..() || SSgoldeneye.goldeneye_activated

// Variant of stationloving that also allows it to be at the assop base, used by the goldeneye keycards.
/datum/component/stationloving/goldeneye
	inform_admins = TRUE

/datum/component/stationloving/goldeneye/atom_in_bounds(atom/atom_to_check)
	if(istype(get_area(atom_to_check), /area/cruiser_dock))
		return TRUE
	return ..()

#undef ICARUS_IGNITION_TIME
