//Regular syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate
	name = "red space helmet"
	icon_state = "syndicate"
	item_state = "syndicate"
	desc = "Has a tag on it: Totally not property of an enemy corporation, honest!"
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 80, "acid" = 85)

/obj/item/clothing/suit/space/syndicate
	name = "red space suit"
	icon_state = "syndicate"
	item_state = "space_suit_syndicate"
	desc = "Has a tag on it: Totally not property of an enemy corporation, honest!"
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/transforming/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 80, "acid" = 85)
	item_flags = NONE

//Black syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/black
	name = "black space helmet"
	icon_state = "syndicate-helm-black"
	item_state = "syndicate-helm-black"

/obj/item/clothing/suit/space/syndicate/black
	name = "black space suit"
	icon_state = "syndicate-black"
	item_state = "syndicate-black"


//Black medical syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/black/med
	name = "black medical space helmet"
	icon_state = "syndicate-helm-black-med"
	item_state = "syndicate-helm-black-med"

/obj/item/clothing/suit/space/syndicate/black/med
	name = "black medical space suit"
	icon_state = "syndicate-black-med"
	item_state = "syndicate-black-med"


//Black-red syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/black/red
	name = "black and red space helmet"
	icon_state = "syndicate-helm-black-red"
	item_state = "syndicate-helm-black-red"

/obj/item/clothing/suit/space/syndicate/black/red
	name = "black and red space suit"
	icon_state = "syndicate-black-red"
	item_state = "syndicate-black-red"

//Black-red syndicate contract varient
/obj/item/clothing/head/helmet/space/syndicate/contract
	name = "contractor space helmet"
	desc = "A specialised black and red helmet that's quicker, and more compact than its standard Syndicate counterpart. Can be ultra-compressed into even the tightest of spaces."
	slowdown = 0.55
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "syndicate-contract-helm"
	item_state = "syndicate-contract-helm"

/obj/item/clothing/suit/space/syndicate/contract
	name = "contractor space suit"
	desc = "A specialised black and red space suit that's quicker, and more compact than its standard Syndicate counterpart. Can be ultra-compressed into even the tightest of spaces."
	slowdown = 0.55
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "syndicate-contract"
	item_state = "syndicate-contract"

//Black with yellow/red engineering syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/black/engie
	name = "black engineering space helmet"
	icon_state = "syndicate-helm-black-engie"
	item_state = "syndicate-helm-black-engie"

/obj/item/clothing/suit/space/syndicate/black/engie
	name = "black engineering space suit"
	icon_state = "syndicate-black-engie"
	item_state = "syndicate-black-engie"
