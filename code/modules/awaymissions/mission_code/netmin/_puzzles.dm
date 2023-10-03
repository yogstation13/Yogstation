GLOBAL_VAR_INIT(decrypted_puzzle_disks, 0)

/obj/item/disk/puzzle
	name = "encrypted floppy drive"
	desc = "Likely contains the access key to a locked door."
	icon = 'icons/obj/card.dmi'
	icon_state = "data_3"
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	var/decrypted = FALSE
	var/id
	var/decryption_progress = 0
	var/detail_color = COLOR_ASSEMBLY_BLUE

/obj/item/disk/puzzle/examine(mob/user)
	. = ..()
	. += "The disk seems to be [decrypted ? "decrypted" : "encrypted"]."

/obj/item/disk/puzzle/Initialize(mapload)
	.=..()
	update_icon()

/obj/item/disk/puzzle/update_overlays()
	. = ..()
	if(detail_color == COLOR_FLOORTILE_GRAY)
		return
	var/mutable_appearance/detail_overlay = mutable_appearance('icons/obj/card.dmi', "[icon_state]-color")
	detail_overlay.color = detail_color
	add_overlay(detail_overlay)

