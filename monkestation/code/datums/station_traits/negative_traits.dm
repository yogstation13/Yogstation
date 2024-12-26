/datum/station_trait/clown_bridge
	name = "Clown Bridge Access"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	show_in_report = TRUE
	report_message = "The Clown Planet has discovered a weakness in the ID scanners of specific airlocks."
	trait_to_give = STATION_TRAIT_CLOWN_BRIDGE

/datum/station_trait/overflow_job_bureaucracy
	/// Has the initial notification been sent to all players yet?
	var/notified = FALSE
	/// Current type of the picked job.
	var/datum/job/picked_job
	/// The icon tag for the job, used to display the job icon in the pregame/login notification,
	var/icon_tag

/datum/station_trait/overflow_job_bureaucracy/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CLIENT_CONNECT, PROC_REF(notify_on_login))
	RegisterSignal(SSticker, COMSIG_TICKER_ENTER_PREGAME, PROC_REF(notify_all_players))

/// Picks and sets the overflow role.
/datum/station_trait/overflow_job_bureaucracy/proc/set_overflow_job_override(datum/source)
	SIGNAL_HANDLER
	var/list/possible_jobs = SSjob.joinable_occupations.Copy()
	possible_jobs -= SSjob.GetJobType(SSjob.overflow_role)
	while(length(possible_jobs) && !picked_job?.allow_overflow)
		picked_job = pick_n_take(possible_jobs)
	if(!picked_job)
		CRASH("Failed to find valid job to pick for overflow!")
	chosen_job_name = lowertext(picked_job.title) // like Chief Engineers vs like chief engineers
	SSjob.set_overflow_role(picked_job.type)
	var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/job_icons)
	icon_tag = sheet.icon_tag(sanitize_css_class_name(lowertext(picked_job.config_tag || picked_job.title)))
	if(icon_tag)
		icon_tag = "<span style='vertical-align: middle'>[icon_tag]</span> " // vertically align and add a space to the end

/// Signal handler to notify all connected clients of the overflow role, ran after all initializations are complete.
/datum/station_trait/overflow_job_bureaucracy/proc/notify_all_players(datum/source)
	SIGNAL_HANDLER
	notified = TRUE
	for(var/mob/dead/new_player/lobby_user in GLOB.new_player_list)
		INVOKE_ASYNC(src, PROC_REF(notify_client), lobby_user)
l
/// Signal handler to notify newly connecting clients of the overflow role.
/datum/station_trait/overflow_job_bureaucracy/proc/notify_on_login(datum/source, client/client)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(notify_client), client)

/// Notifies a single client of the current overflow role.
/datum/station_trait/overflow_job_bureaucracy/proc/notify_client(target)
	if(!picked_job || !notified)
		return
	var/client/client = get_player_client(target)
	client?.tgui_panel?.window?.send_asset(get_asset_datum(/datum/asset/spritesheet/job_icons))
	to_chat(
		target = client,
		html = boxed_message(span_big(span_info("Current overflow role is [icon_tag][span_name(html_encode(picked_job.title))], make sure to check your job preferences!"))),
		type = MESSAGE_TYPE_INFO,
	)
