<<<<<<< HEAD
=======
/obj/item/storage/internal/implant
	name = "bluespace pocket"
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 6
	cant_hold = list(/obj/item/disk/nuclear)
	silent = TRUE


>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
/obj/item/implant/storage
	name = "storage implant"
	desc = "Stores up to two big items in a bluespace pocket."
	icon_state = "storage"
	item_color = "r"
	var/max_slot_stacking = 4

/obj/item/implant/storage/activate()
	SendSignal(COMSIG_TRY_STORAGE_SHOW, imp_in, TRUE)

/obj/item/implant/storage/removed(source, silent = FALSE, special = 0)
<<<<<<< HEAD
	. = ..()
	if(.)
=======
	if(..())
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
		if(!special)
			qdel(GetComponent(/datum/component/storage/concrete/implant))

/obj/item/implant/storage/implant(mob/living/target, mob/user, silent = FALSE)
	for(var/X in target.implants)
		if(istype(X, type))
			var/obj/item/implant/storage/imp_e = X
			GET_COMPONENT_FROM(STR, /datum/component/storage, imp_e)
			if(!STR || (STR && STR.max_items < max_slot_stacking))
				imp_e.AddComponent(/datum/component/storage/concrete/implant)
				qdel(src)
				return TRUE
			return FALSE
	AddComponent(/datum/component/storage/concrete/implant)

	return ..()

/obj/item/implanter/storage
	name = "implanter (storage)"
	imp_type = /obj/item/implant/storage
