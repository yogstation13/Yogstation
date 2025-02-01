#define STREAM_ALERT_COOLDOWN (5 SECONDS)
/// Global lazylist containing who's watching what spesstv streams.
GLOBAL_LIST(spesstv_viewers)

/datum/computer_file/program/secureye/spesstv
	filename = "spesstv"
	filedesc = "Spess.tv"
	extended_desc = "This program allows users to tune into public streams."
	transfer_access = list()
	usage_flags = PROGRAM_ALL
	size = 0
	program_icon = FA_ICON_VIDEO
	alert_able = TRUE
	network = list()
	/// The radio used to listen to the entertainment channel.
	var/obj/item/radio/entertainment/speakers/pda/radio
	/// Coolwdown for stream alerts.
	COOLDOWN_DECLARE(alert_cooldown)

/datum/computer_file/program/secureye/spesstv/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_NETWORK_BROADCAST_UPDATED, PROC_REF(on_network_broadcast_updated))

/datum/computer_file/program/secureye/spesstv/Destroy()
	LAZYREMOVE(GLOB.spesstv_viewers, REF(src))
	UnregisterSignal(SSdcs, COMSIG_GLOB_NETWORK_BROADCAST_UPDATED)
	QDEL_NULL(radio)
	return ..()

/datum/computer_file/program/secureye/spesstv/on_start(mob/living/user)
	. = ..()
	if(. && QDELETED(radio) && !QDELETED(computer))
		radio = new(computer)

/datum/computer_file/program/secureye/spesstv/kill_program(mob/user)
	. = ..()
	if(.)
		LAZYREMOVE(GLOB.spesstv_viewers, REF(src))
		QDEL_NULL(radio)

/datum/computer_file/program/secureye/spesstv/background_program()
	. = ..()
	if(.)
		LAZYREMOVE(GLOB.spesstv_viewers, REF(src))

/datum/computer_file/program/secureye/spesstv/update_active_camera_screen()
	. = ..()
	update_spesstv_watcher_list(REF(src), camera_ref)

/datum/computer_file/program/secureye/spesstv/proc/on_network_broadcast_updated(datum/source, tv_show_id, is_show_active, announcement)
	SIGNAL_HANDLER
	if(is_show_active)
		network |= tv_show_id
		alert_pending = TRUE
	else
		network -= tv_show_id
		if(!length(network))
			alert_pending = FALSE
			LAZYREMOVE(GLOB.spesstv_viewers, REF(src))
	if(!QDELETED(computer))
		if(announcement && COOLDOWN_FINISHED(src, alert_cooldown))
			computer.alert_call(src, announcement, vision_distance = 2)
			COOLDOWN_START(src, alert_cooldown, STREAM_ALERT_COOLDOWN)
		INVOKE_ASYNC(computer, TYPE_PROC_REF(/datum, update_static_data_for_all_viewers))

/obj/item/radio/entertainment/speakers/pda
	canhear_range = 0

/obj/item/radio/entertainment/speakers/pda/Initialize(mapload)
	. = ..()
	if(!istype(loc, /obj/item/modular_computer))
		stack_trace("[type] spawned outside of a modular computer!")
		return INITIALIZE_HINT_QDEL
	RegisterSignal(loc, COMSIG_QDELETING, PROC_REF(on_loc_destroyed))

/obj/item/radio/entertainment/speakers/pda/Destroy()
	if(!isnull(loc))
		UnregisterSignal(loc, COMSIG_QDELETING)
	return ..()

/obj/item/radio/entertainment/speakers/pda/proc/on_loc_destroyed(datum/source)
	SIGNAL_HANDLER
	if(!QDELETED(src))
		qdel(src)

/obj/item/radio/entertainment/speakers/pda/emp_act(severity)
	return

/proc/update_spesstv_watcher_list(key, obj/machinery/camera/active_camera)
	if(istype(active_camera, /datum/weakref))
		var/datum/weakref/camera_ref = active_camera
		active_camera = camera_ref.resolve()
	if(QDELETED(active_camera) || !active_camera.can_use())
		LAZYREMOVE(GLOB.spesstv_viewers, key)
	else
		LAZYSET(GLOB.spesstv_viewers, key, active_camera.c_tag)

#undef STREAM_ALERT_COOLDOWN
