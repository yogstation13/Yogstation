// _process_numerical_display() for stack-only storage.
/datum/component/storage/concrete/stack
	display_numerical_stacking = TRUE
	max_items = 300
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = WEIGHT_CLASS_NORMAL * 14

/datum/component/storage/concrete/stack/_process_numerical_display()
	var/atom/real_location = real_location()
	. = list()
	for(var/i in real_location)
		var/obj/item/stack/I = i
		if(!istype(I) || QDELETED(I))				//We're specialized stack storage, just ignore non stacks.
			continue
		if(!.[I.merge_type])
			.[I.merge_type] = new /datum/numbered_display(I, I.amount)
		else
			var/datum/numbered_display/ND = .[I.merge_type]
			ND.number += I.amount
