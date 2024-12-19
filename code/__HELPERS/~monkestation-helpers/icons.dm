#define TMP_UPSCALE_PATH "tmp/resize_icon.png"

/// Upscales an icon using rust-g.
/// You really shouldn't use this TOO often, as it has to copy the icon to a temporary png file,
/// resize it, fcopy_rsc the resized png, and then create a new /icon from said png.
/// Cache the output where possible.
/proc/resize_icon(icon/icon, width, height, resize_type = RUSTG_RESIZE_NEAREST) as /icon
	RETURN_TYPE(/icon)
	SHOULD_BE_PURE(TRUE)

	if(!istype(icon))
		CRASH("Attempted to upscale non-icon")
	if(!IS_SAFE_NUM(width) || !IS_SAFE_NUM(height))
		CRASH("Attempted to upscale icon to non-number width/height")
	if(!fcopy(icon, TMP_UPSCALE_PATH))
		CRASH("Failed to create temporary png file to upscale")
	UNLINT(rustg_dmi_resize_png(TMP_UPSCALE_PATH, "[width]", "[height]", resize_type)) // technically impure but in practice its not
	. = icon(fcopy_rsc(TMP_UPSCALE_PATH))
	fdel(TMP_UPSCALE_PATH)

#undef TMP_UPSCALE_PATH

/// Returns the (isolated) security HUD icon for the given job.
/proc/get_job_hud_icon(datum/job/job, include_unknown = FALSE) as /icon
	RETURN_TYPE(/icon)
	var/static/list/icon_cache
	var/static/list/unknown_huds
	if(isnull(job))
		return
	else if(!is_job(job))
		if(ispath(job, /datum/job))
			job = locate(job) in SSjob.all_occupations
		else if(istext(job))
			job_loop:
				for(var/datum/job/job_instance as anything in SSjob.all_occupations)
					if(cmptext(job_instance.title, job) || cmptext(job_instance.config_tag, job))
						job = job_instance
						break
					for(var/alt_title in job_instance.alt_titles)
						if(cmptext(alt_title, job))
							job = job_instance
							break job_loop
		if(!job)
			return null

	// populate the cache if it hasn't been already
	if(isnull(icon_cache))
		icon_cache = list()
		unknown_huds = list()
		for(var/datum/job/job_instance as anything in SSjob.all_occupations)
			var/datum/outfit/job_outfit = job_instance.outfit
			if(!job_outfit || !job_outfit::id_trim)
				continue
			var/datum/id_trim/job_trim = job_outfit::id_trim
			var/icon_state = job_trim::sechud_icon_state
			if(!icon_state || icon_state == SECHUD_UNKNOWN)
				icon_state = "hud_noid"
				unknown_huds[job_instance.type] = TRUE
			var/icon/sechud_icon = icon('icons/mob/huds/hud.dmi', icon_state)
			sechud_icon.Crop(1, 17, 8, 24)
			icon_cache[job_instance.type] = sechud_icon

	var/job_type = job.type
	if(icon_cache[job_type] && (include_unknown || !unknown_huds[job_type]))
		return icon(icon_cache[job_type])
