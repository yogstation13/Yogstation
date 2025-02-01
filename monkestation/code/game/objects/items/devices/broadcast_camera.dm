/datum/status_effect/streamer
	id = "streamer"
	alert_type = null
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	/// How many people are currently watching the stream.
	var/viewers = 0
	/// The camera being used to stream.
	var/obj/machinery/camera/camera
	/// Simple screen element used to hold the maptext for the viewer counter.
	var/atom/movable/screen/stream_viewers/viewer_display
	/// Callback to see if the stream is still valid.
	var/datum/callback/extra_checks

/datum/status_effect/streamer/Destroy()
	extra_checks = null
	camera = null
	QDEL_NULL(viewer_display)
	return ..()

/datum/status_effect/streamer/on_creation(mob/living/new_owner, obj/machinery/camera/camera, datum/callback/extra_checks)
	src.camera = camera
	src.extra_checks = extra_checks
	return ..()

/datum/status_effect/streamer/on_apply()
	if(QDELETED(camera))
		return FALSE
	else if(!istype(camera))
		CRASH("Invalid camera ([camera]) passed to [type] (expected an /obj/machinery/camera)")
	if(extra_checks && !extra_checks.Invoke(src))
		return FALSE
	give_hud()
	RegisterSignal(owner, COMSIG_MOB_LOGIN, PROC_REF(give_hud))
	RegisterSignal(owner, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_item))
	RegisterSignal(camera, COMSIG_QDELETING, PROC_REF(hamburger_time))
	return TRUE

/datum/status_effect/streamer/on_remove()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_MOB_LOGIN, COMSIG_MOB_GET_STATUS_TAB_ITEMS))
	UnregisterSignal(camera, COMSIG_QDELETING)
	if(!isnull(viewer_display))
		owner.client?.screen -= viewer_display

/datum/status_effect/streamer/before_remove(source)
	if(!isnull(source) && !QDELETED(camera) && source == camera)
		return FALSE
	return ..()

/datum/status_effect/streamer/tick(seconds_per_tick, times_fired)
	if(extra_checks && !extra_checks.Invoke(src))
		qdel(src)
		return
	viewers = camera.count_spesstv_viewers()
	viewer_display?.update_maptext(camera.count_spesstv_viewers())

/datum/status_effect/streamer/proc/give_hud()
	SIGNAL_HANDLER
	if(QDELETED(viewer_display))
		viewer_display = new
	viewers = camera.count_spesstv_viewers()
	viewer_display.update_maptext(viewers)
	owner.client?.screen |= viewer_display

/datum/status_effect/streamer/proc/get_status_tab_item(mob/living/source, list/items)
	SIGNAL_HANDLER
	items += "Stream Viewers: [viewers]"

/datum/status_effect/streamer/proc/hamburger_time()
	SIGNAL_HANDLER
	qdel(src)

/atom/movable/screen/stream_viewers
	screen_loc = ui_more_under_health_and_to_the_left
	maptext_width = 84
	maptext_height = 24

/atom/movable/screen/stream_viewers/proc/update_maptext(amt)
	maptext = "<div align='left' valign='top' style='position: relative; top: 0px; left: 6px'>Viewers: <font color='#33FF33'>[amt]</font></div>"
