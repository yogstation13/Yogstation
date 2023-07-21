/obj/structure/chair/bananium
	icon = 'yogstation/icons/obj/chairs.dmi'
	icon_state = "bananium_chair"
	name = "bananium chair"
	desc = "A chair made out of bananium. A lot more comfortable than you would think."
	resistance_flags = NONE
	max_integrity = 70
	buildstacktype = /obj/item/stack/sheet/mineral/bananium
	buildstackamount = 2

/obj/structure/chair/bananium/honk_act()
	return FALSE

/obj/item/chair/bananium
	name = "bananium chair"
	icon = 'yogstation/icons/obj/chairs.dmi'
	icon_state = "bananium_chair_toppled"
	item_state = "woodenchair"
	resistance_flags = NONE
	max_integrity = 70
	hitsound = 'sound/items/bikehorn.ogg'
	origin_type = /obj/structure/chair/bananium
	materials = null
