/obj/item/access_kit
	name = "access kit (unset)"
	desc = "A one-use device that can be used to spoof and grant the access associated with a low-level job."
	icon_state = "red_phone"
	var/datum/job/job
	var/list/available_jobs = list(/datum/job/hydro, /datum/job/janitor, /datum/job/cargo_tech, /datum/job/scientist, /datum/job/doctor, /datum/job/engineer)

/obj/item/access_kit/interact(mob/user)
	. = ..()
	if (!ishuman(user))
		return
	if (syndicate && !is_syndicate(user))
		to_chat(user, span_warning("You have no idea how to use [src]..."))
		return
	if (job)
		to_chat(user, span_warning("[src] has already been used! Apply it to your ID to use it."))
		return
	var/list/radial_menu = list()
	for (var/J in available_jobs)
		var/datum/job/job = new J
		radial_menu[job.title] = get_flat_human_icon("accesskit_[job.type]", job, showDirs = list(SOUTH))
	var/result = show_radial_menu(user, src, radial_menu)
	if (!result)
		return
	job = SSjob.GetJob(result)
	name = "access kit ([job.title])"
	to_chat(user, span_notice("You set up [src] to spoof and grant access to [job.title]."))

/obj/item/access_kit/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if (syndicate && !is_syndicate(user))
		return
	if (!istype(target, /obj/item/card/id))
		return
	if (!job)
		to_chat(user, span_warning("[src] has not been set to a specific job yet! Use it in-hand to set up the access kit."))
		return
	var/obj/item/card/id/id = target
	id.assignment = job.title
	id.originalassignment = job.title
	id.access |= job.base_access
	id.update_label()
	to_chat(user, span_notice("You apply [src] to [id], granting it the access of a [job.title]!"))
	if (is_infiltrator(user))
		to_chat(user, span_boldnotice("Ensure to properly update your chameleon clothes to reflect that of a [job.title]!"))
	do_sparks(5, FALSE, user)
	user.dropItemToGround(src)
	qdel(src)

/obj/item/access_kit/syndicate
	syndicate = TRUE
