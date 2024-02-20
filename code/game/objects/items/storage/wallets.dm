/obj/item/storage/wallet
	name = "wallet"
	desc = "It can hold a few small and personal things."
	icon_state = "wallet"
	base_icon_state = "wallet"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	slot_flags = ITEM_SLOT_ID

	var/obj/item/card/id/front_id = null
	var/list/combined_access

/obj/item/storage/wallet/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 4
	STR.set_holdable(list(
		/obj/item/stack/spacecash,
		/obj/item/holochip,
		/obj/item/card,
		/obj/item/clothing/mask/cigarette,
		/obj/item/flashlight/pen,
		/obj/item/seeds,
		/obj/item/stack/medical,
		/obj/item/toy/crayon,
		/obj/item/coin,
		/obj/item/dice,
		/obj/item/disk,
		/obj/item/implanter,
		/obj/item/lighter,
		/obj/item/lipstick,
		/obj/item/match,
		/obj/item/paper,
		/obj/item/pen,
		/obj/item/photo,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/screwdriver,
		/obj/item/stamp),
		list(/obj/item/handdrill))

/obj/item/storage/wallet/Exited(atom/movable/AM)
	. = ..()
	refreshID()

/obj/item/storage/wallet/proc/refreshID()
	LAZYCLEARLIST(combined_access)
	if(!(front_id in src))
		front_id = null
	for(var/obj/item/card/id/I in contents)
		if(!front_id)
			front_id = I
		LAZYINITLIST(combined_access)
		combined_access |= I.access
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.wear_id == src)
			H.sec_hud_set_ID()
	update_appearance(UPDATE_ICON)

/obj/item/storage/wallet/Entered(atom/movable/AM)
	. = ..()
	refreshID()

/obj/item/storage/wallet/update_icon_state()
	. = ..()
	if(front_id)
		icon_state = "[base_icon_state]_[front_id.icon_state]"
		return
	icon_state = base_icon_state

/obj/item/storage/wallet/GetID()
	return front_id

/obj/item/storage/wallet/RemoveID()
	if(!front_id)
		return
	. = front_id
	front_id.forceMove(get_turf(src))

/obj/item/storage/wallet/InsertID(obj/item/inserting_item)
	var/obj/item/card/inserting_id = inserting_item.RemoveID()
	if(!inserting_id)
		return FALSE
	attackby(inserting_id)
	if(inserting_id in contents)
		return TRUE
	return FALSE

/obj/item/storage/wallet/GetAccess()
	if(LAZYLEN(combined_access))
		return combined_access
	else
		return ..()

/obj/item/storage/wallet/random
	icon_state = "random_wallet"

/obj/item/storage/wallet/random/PopulateContents()
	new /obj/item/holochip(src, rand(5,30))
	update_appearance(UPDATE_ICON)
