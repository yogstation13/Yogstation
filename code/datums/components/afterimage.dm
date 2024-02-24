/datum/component/after_image
	dupe_mode =	 COMPONENT_DUPE_UNIQUE_PASSARGS
	var/rest_time
	var/list/obj/after_image/after_images
	
	//cycles colors
	var/color_cycle = FALSE
	var/list/hsv

/datum/component/after_image/Initialize(count = 4, rest_time = 1, color_cycle = FALSE)
	..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	src.rest_time = rest_time
	src.after_images = list()
	src.color_cycle = color_cycle
	if(count > 1)
		for(var/number = 1 to count)
			var/obj/after_image/added_image = new /obj/after_image(null)
			added_image.finalized_alpha = 200 - 100 * (number - 1) / (count - 1)
			after_images += added_image
	else
		var/obj/after_image/added_image = new /obj/after_image(null)
		added_image.finalized_alpha = 100
		after_images |= added_image
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(move))
	RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, PROC_REF(change_dir))
	RegisterSignal(parent, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(throw_landed))
	
/datum/component/after_image/RegisterWithParent()
	for(var/obj/after_image/listed_image in src.after_images)
		listed_image.active = TRUE
	src.sync_after_images()

/datum/component/after_image/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE, COMSIG_MOVABLE_THROW_LANDED))
	for(var/obj/after_image/listed_image in src.after_images)
		listed_image.active = FALSE
		qdel(listed_image)
	. = ..()

/datum/component/after_image/Destroy()
	if(length(src.after_images))
		for(var/obj/after_image/listed_image in src.after_images)
			qdel(listed_image)
		src.after_images.Cut()
		src.after_images = null
	. = ..()

/datum/component/after_image/proc/change_dir(atom/movable/AM, new_dir, old_dir)
	src.sync_after_images(new_dir)

/datum/component/after_image/proc/set_loc(atom/movable/AM, atom/last_loc)
	return src.move(AM, last_loc, AM.dir)

/datum/component/after_image/proc/move(atom/movable/AM, turf/last_turf, direct)
	src.sync_after_images()

/datum/component/after_image/proc/throw_landed(atom/movable/AM, datum/thrownthing/thing)
	src.sync_after_images() // necessary to fix pixel_x and pixel_y

/datum/component/after_image/proc/sync_after_images(dir_override=null)
	set waitfor = FALSE
	var/obj/after_image/targeted_image = new(null)
	targeted_image.active = TRUE
	targeted_image.sync_with_parent(parent)
	targeted_image.loc = null

	if(color_cycle)
		if(!hsv)
			hsv = RGBtoHSV(rgb(255, 0, 0))
		hsv = RotateHue(hsv, world.time - rest_time * 15)
		targeted_image.color = HSVtoRGB(hsv)

	if(!isnull(dir_override))
		targeted_image.setDir(dir_override)

	var/atom/movable/parent_am = parent
	var/atom/target_loc = parent_am.loc
	for(var/obj/after_image/listed_image in src.after_images)
