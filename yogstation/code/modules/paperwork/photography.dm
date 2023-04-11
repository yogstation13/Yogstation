/obj/item/storage/photobook
	name = "photo book"
	icon = 'yogstation/icons/obj/toy.dmi'
	icon_state = "photobook"
	item_state = "photobook"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE

/obj/item/storage/photobook/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 70
	STR.max_items = 70
	STR.can_hold = typecacheof(/obj/item/photo)

/obj/item/storage/bag/photo
	name = "Photo Bag"
	desc = "This satchel can be used to store all your photo related items."
	icon = 'yogstation/icons/obj/toy.dmi'
	icon_state = "photobag"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/photo/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 50
	STR.max_items = 50
	STR.can_hold = typecacheof(list(/obj/item/camera_film,/obj/item/photo,/obj/item/storage/photo_album,/obj/item/camera,/obj/item/storage/photobook))