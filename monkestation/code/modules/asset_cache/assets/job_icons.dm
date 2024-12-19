/datum/asset/spritesheet/job_icons
	name = "job_icons"
	/// The width and height to scale the job icons to.
	var/icon_size = 24

/datum/asset/spritesheet/job_icons/create_spritesheets()
	var/list/id_list = list()
	for(var/datum/job/job as anything in SSjob.all_occupations)
		var/id = sanitize_css_class_name(lowertext(job.config_tag || job.title))
		if(id_list[id])
			continue
		var/icon/job_icon = get_job_hud_icon(job)
		if(!job_icon)
			continue
		var/icon/resized_icon = resize_icon(job_icon, icon_size, icon_size)
		if(!resized_icon)
			stack_trace("Failed to upscale icon for [job.type], upscaling using BYOND!")
			job_icon.Scale(icon_size, icon_size)
			resized_icon = job_icon
		Insert(id, resized_icon)
		id_list[id] = TRUE
