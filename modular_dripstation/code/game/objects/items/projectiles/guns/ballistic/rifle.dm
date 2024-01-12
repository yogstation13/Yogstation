/obj/item/gun/ballistic/rifle/boltaction/brand_new
	desc = "A brand new Mosin Nagant issued by Nanotrasen for their interns. You would rather not to damage it."
	icon_state = "mosinprime"
	item_state = "mosinprime"
	sawn_desc = "A sawn-off Brand New Nagant... Doing this was a sin, I hope you're happy. \
		You are now probably one of the few people in the universe to ever hold a \"Brand New Obrez\". \
		Even thinking about that name combination makes you ill."
	icon = 'modular_dripstation/icons/obj/weapons/48x32.dmi'
	mob_overlay_icon = 'modular_dripstation/icons/mob/clothing/guns_on_back.dmi'
	lefthand_file = 'modular_dripstation/icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_dripstation/icons/mob/inhands/guns_righthand.dmi'

/obj/item/gun/ballistic/rifle/boltaction/brand_new/sawoff(mob/user)
	. = ..()
	if(.)
		name = "\improper Brand New Obrez" // wear it loud and proud

/obj/item/gun/ballistic/rifle/boltaction/qmrifle
	name = "\improper 'Forbidden' precision rifle"
	desc = "Modernized boltaction rifle, the frame feels robust as cargotech liver. \
	This thing was probably built with a conversion kit from a shady NTnet site. \
	<br><br>\
	<i>BRAND NEW: Cannot be sawn off.</i>"
	icon = 'modular_dripstation/icons/obj/weapons/48x32.dmi'
	mob_overlay_icon = 'modular_dripstation/icons/mob/clothing/guns_on_back.dmi'
	lefthand_file = 'modular_dripstation/icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_dripstation/icons/mob/inhands/guns_righthand.dmi'
	icon_state = "mosintactical"
	item_state = "mosintactical"
	can_be_sawn_off = FALSE