/datum/component/storage/concrete/implant
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 6
	max_items = 2
	drop_all_on_destroy = TRUE
	drop_all_on_deconstruct = TRUE
	silent = TRUE
	allow_big_nesting = TRUE

/datum/component/storage/concrete/implant/Initialize()
	. = ..()
	set_holdable(null, list(/obj/item/disk/nuclear))

/datum/component/storage/concrete/implant/InheritComponent(datum/component/storage/concrete/implant/I, original)
	if(!istype(I))
		return ..()
	max_combined_w_class += I.max_combined_w_class
	max_items += I.max_items

/datum/component/storage/concrete/implant/remove_from_storage(atom/movable/AM, atom/new_location)
	. = ..()
	flash_out(new_loc = new_location)
	if(AM.GetComponent(/datum/component/storage))
		UnregisterSignal(AM, list(COMSIG_STORAGE_INSERTED, COMSIG_STORAGE_REMOVED))

/datum/component/storage/concrete/implant/handle_item_insertion(obj/item/I, prevent_warning, mob/M, datum/component/storage/remote)
	. = ..()
	flash_in(inserter = M)
	if(I.GetComponent(/datum/component/storage))
		RegisterSignal(I, COMSIG_STORAGE_INSERTED, PROC_REF(flash_in))
		RegisterSignal(I, COMSIG_STORAGE_REMOVED, PROC_REF(flash_out))

/datum/component/storage/concrete/implant/proc/flash_in(datum/source, obj/item/I, mob/inserter)
	var/turf/new_turf = get_turf(inserter)
	if(!new_turf || !istype(new_turf))
		return
	var/obj/effect/temp_visual/dir_setting/cult/phase/efx = new(new_turf)
	efx.color = "#5C5CFF"

/datum/component/storage/concrete/implant/proc/flash_out(datum/source, atom/movable/AM, new_loc)
	var/turf/new_turf = get_turf(new_loc)
	if(!new_turf || !istype(new_turf))
		return
	var/obj/effect/temp_visual/dir_setting/cult/phase/out/efx = new(new_turf)
	efx.color = "#5C5CFF"
