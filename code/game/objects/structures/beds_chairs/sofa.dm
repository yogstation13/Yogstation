/obj/structure/chair/sofa
	name = "sofa"
	icon_state = "sofamiddle"
	icon = 'icons/obj/sofa.dmi'
	buildstackamount = 1
	item_chair = null

/obj/structure/chair/sofa/left
	icon_state = "sofaend_left"

/obj/structure/chair/sofa/right
	icon_state = "sofaend_right"

/obj/structure/chair/sofa/corner
	icon_state = "sofacorner"

// Bamboo benches
/obj/structure/chair/sofa/bamboo
	name = "bamboo bench"
	desc = "A makeshift bench with a rustic aesthetic."
	icon_state = "bamboo_sofamiddle"
	resistance_flags = FLAMMABLE
	max_integrity = 60
	buildstacktype = /obj/item/stack/sheet/mineral/bamboo
	buildstackamount = 3

/obj/structure/chair/sofa/bamboo/left
	icon_state = "bamboo_sofaend_left"

/obj/structure/chair/sofa/bamboo/right
	icon_state = "bamboo_sofaend_right"
