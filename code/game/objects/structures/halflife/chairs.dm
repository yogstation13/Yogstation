/obj/structure/chair/halflife
	name = "base class Mojave Sun chair"
	desc = "Scream at the coders if you see this."
	icon = 'icons/obj/halflife/chairs.dmi'
	item_chair = /obj/item/chair/halflife
	layer = BELOW_OBJ_LAYER
	max_integrity = 100
	projectile_passchance = 100

/obj/structure/chair/halflife/attackby_secondary(mob/living/user, obj/item/weapon)
	return

// Metal Chairs //

/obj/structure/chair/halflife/metal
	name = "metal chair"
	desc = "An uncomfortable chair."
	icon_state = "metal_chair"
	item_chair = /obj/item/chair/halflife/metal
	buildstacktype = /obj/item/stack/sheet/metal
	buildstackamount = 1

/obj/structure/chair/halflife/metal/broken
	name = "broken metal chair"
	desc = "A broken chair that is somehow more comfortable than a regular one."
	icon_state = "metal_chair_broken"
	item_chair = /obj/item/chair/halflife/metal/broken

/obj/structure/chair/halflife/metal/unfinished
	name = "unfinished metal chair"
	desc = "Without a backrest, this chair is essentially a stool with rods."
	icon_state = "metal_chair_unfinished"
	item_chair = /obj/item/chair/halflife/metal/unfinished

/obj/structure/chair/halflife/metal/blue
	name = "metal chair"
	icon_state = "metal_chair_blue"
	item_chair = /obj/item/chair/halflife/metal/blue

/obj/structure/chair/halflife/metal/blue/broken
	name = "broken metal chair"
	desc = "A broken chair that is somehow more comfortable than a regular one."
	icon_state = "metal_chair_blue_broken"
	item_chair = /obj/item/chair/halflife/metal/blue/broken

/obj/structure/chair/halflife/metal/blue/unfinished
	name = "unfinished metal chair"
	desc = "Without a backrest, this chair is essentially a stool with rods."
	icon_state = "metal_chair_blue_unfinished"
	item_chair = /obj/item/chair/halflife/metal/blue/unfinished

/obj/structure/chair/halflife/metal/red
	icon_state = "metal_chair_red"
	item_chair = /obj/item/chair/halflife/metal/red

/obj/structure/chair/halflife/metal/red/broken
	name = "broken metal chair"
	desc = "A broken chair that is somehow more comfortable than a regular one."
	icon_state = "metal_chair_red_broken"
	item_chair = /obj/item/chair/halflife/metal/red/broken

/obj/structure/chair/halflife/metal/red/unfinished
	name = "unfinished metal chair"
	desc = "Without a backrest, this chair is essentially a stool with rods."
	icon_state = "metal_chair_red_unfinished"
	item_chair = /obj/item/chair/halflife/metal/red/unfinished

/obj/structure/chair/halflife/metal/folding
	name = "metal folding chair"
	desc = "Before the war, These were viewed as the lowest form of seat. Now? What's not to love. It's a chair that's easily moveable. Genius!"
	icon_state = "metal_chair_folding"
	item_chair = /obj/item/chair/halflife/metal/folding

/obj/structure/chair/halflife/metal/stool
	name = "bar stool"
	desc = "A bar stool. It's help up against time rather well. Perfect to prop yourself up on after a long day."
	icon_state = "barstool"
	item_chair = /obj/item/chair/halflife/metal/stool

// Wood Chairs //

/obj/structure/chair/halflife/wood
	name = "wooden chair"
	desc = "An antique wooden chair with a small green cushion."
	icon_state = "wood_chair"
	item_chair = /obj/item/chair/halflife/wood
	buildstacktype = /obj/item/stack/sheet/mineral/wood
	buildstackamount = 1

/obj/structure/chair/halflife/wood/padded
	name = "padded wooden chair"
	desc = "An antique wooden chair with a large, plush red cushion"
	icon_state = "wood_chair_padded"
	item_chair = /obj/item/chair/halflife/wood/padded

// Quirky Chairs //

/obj/structure/chair/comfy/halflife
	name = "base class Mojave Sun comfy chair"
	desc = "Scream at the coders if you see this."
	icon = 'icons/obj/halflife/chairs.dmi'
	color = null
	//buildstacktype = /obj/item/stack/sheet/halflife/leather
	buildstackamount = 1
	max_integrity = 100

/obj/structure/chair/comfy/halflife/attackby_secondary(mob/living/user, obj/item/weapon)
	return

/obj/structure/chair/comfy/halflife/GetArmrest()
	return mutable_appearance(icon, "(icon_state)_armrest")

/obj/structure/chair/comfy/halflife/armchair
	name = "armchair"
	desc = "A once plush velour accent piece, this chair's upholstery has faded."
	icon_state = "armchair"

/obj/structure/chair/comfy/halflife/retro
	name = "retro chair"
	desc = "With a fiberglass body, this chair harkens to a future that never came."
	icon_state = "retro_chair"
	buildstacktype = /obj/item/stack/sheet/metal

/obj/structure/chair/comfy/halflife/captain
	name = "captain's chair"
	desc = "Show everyone who is in charge."
	icon_state = "captain_chair"

/obj/structure/chair/comfy/halflife/ergo
	name = "ergonomic chair"
	desc = "Even in a nuclear wasteland, one should never neglect their back."
	icon_state = "ergo_chair"
	anchored = FALSE

/obj/structure/chair/comfy/halflife/ergo/Moved()
	. = ..()
	if(has_gravity())
		playsound(src, 'sound/effects/roll.ogg', 100, TRUE)

/obj/structure/chair/halflife/overlaypickup/plastic
	name = "plastic chair"
	desc = "The most generic chair known to pre-war man."
	icon_state = "plastic_chair"
	armrest_icon = "plastic_chair_armrest"
	item_chair = /obj/item/chair/halflife/plastic
	buildstacktype = /obj/item/stack/sheet/plastic
	buildstackamount = 1
	max_integrity = 100

/obj/structure/chair/halflife/overlaypickup //overlay chairs you can pick up
	var/mutable_appearance/armrest
	var/armrest_icon = "comfychair_armrest"

/obj/structure/chair/halflife/overlaypickup/Initialize()
	. = ..()
	armrest = GetArmrest()
	armrest.layer = ABOVE_MOB_LAYER
	return

/obj/structure/chair/halflife/overlaypickup/proc/GetArmrest()
	return mutable_appearance(icon, "(icon_state)_armrest")

/obj/structure/chair/halflife/overlaypickup/Destroy()
	. = ..()
	QDEL_NULL(armrest)
	return

/obj/structure/chair/halflife/overlaypickup/post_buckle_mob(mob/living/M)
	. = ..()
	update_armrest()

/obj/structure/chair/halflife/overlaypickup/proc/update_armrest()
	if(has_buckled_mobs())
		add_overlay(armrest)
	else
		cut_overlay(armrest)

/obj/structure/chair/halflife/overlaypickup/post_unbuckle_mob()
	. = ..()
	update_armrest()

// Office Chairs //

/obj/structure/chair/office/Moved()
	. = ..()
	if(has_gravity())
		playsound(src, 'sound/effects/roll.ogg', 100, TRUE)

/obj/structure/chair/office/halflife
	name = "base class Mojave sun office chair"
	desc = "Scream at the coders if you see this."
	icon = 'icons/obj/halflife/chairs.dmi'
	buildstacktype = /obj/item/stack/sheet/metal
	buildstackamount = 1
	max_integrity = 100

/obj/structure/chair/office/halflife/attackby_secondary(mob/living/user, obj/item/weapon)
	return

/obj/structure/chair/office/halflife/red
	name = "office chair"
	desc = "Still spins."
	icon_state = "office_chair"

/obj/structure/chair/office/halflife/red/broken
	name = "office chair"
	desc = "Hardly spins."
	icon_state = "office_chair_broken"

/obj/structure/chair/office/halflife/blue
	name = "office chair"
	icon_state = "office_chair_blue"

/obj/structure/chair/office/halflife/blue/broken
	icon_state = "office_chair_blue_broken"

/obj/structure/chair/office/halflife/green
	name = "office chair"
	icon_state = "office_chair_green"

/obj/structure/chair/office/halflife/green/broken
	icon_state = "office_chair_green_broken"

//// ITEM VARIANTS ////

/obj/item/chair/halflife
	name = "base class Mojave Sun chair"
	desc = "Scream at the coders if you see this."
	icon = 'icons/obj/halflife/chairs.dmi'
	icon_state = "metal_chair_toppled"
	item_state = "metal_chair"
	lefthand_file = 'icons/mob/inhands/misc/chairs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/chairs_righthand.dmi'
	custom_materials = null
	origin_type = /obj/structure/chair/halflife
	break_chance = 0

// Metal Chair Items //

/obj/item/chair/halflife/metal
	name = "metal chair"
	desc = "An uncomfortable chair."
	icon_state = "metal_chair_toppled"
	item_state = "metal_chair"
	origin_type = /obj/structure/chair/halflife/metal

/obj/item/chair/halflife/metal/broken
	desc = "A broken chair that is somehow more comfortable than a regular one."
	icon_state = "metal_chair_broken_toppled"
	item_state = "metal_chair_broken"
	origin_type = /obj/structure/chair/halflife/metal/broken

/obj/item/chair/halflife/metal/unfinished
	desc = "Without a backrest, this chair is essentially a stool with rods."
	icon_state = "metal_chair_unfinished_toppled"
	item_state = "metal_chair_unfinished"
	origin_type = /obj/structure/chair/halflife/metal/unfinished

/obj/item/chair/halflife/metal/blue
	name = "metal chair"
	desc = "An uncomfortable chair."
	icon_state = "metal_chair_blue_toppled"
	item_state = "metal_chair"
	origin_type = /obj/structure/chair/halflife/metal/blue

/obj/item/chair/halflife/metal/blue/broken
	desc = "A broken chair that is somehow more comfortable than a regular one."
	icon_state = "metal_chair_blue_broken_toppled"
	item_state = "metal_chair_broken"
	origin_type = /obj/structure/chair/halflife/metal/blue/broken

/obj/item/chair/halflife/metal/blue/unfinished
	desc = "Without a backrest, this chair is essentially a stool with rods."
	icon_state = "metal_chair_blue_unfinished_toppled"
	item_state = "metal_chair_unfinished"
	origin_type = /obj/structure/chair/halflife/metal/blue/unfinished

/obj/item/chair/halflife/metal/red
	name = "metal chair"
	desc = "An uncomfortable chair."
	icon_state = "metal_chair_red_toppled"
	item_state = "metal_chair"
	origin_type = /obj/structure/chair/halflife/metal/red

/obj/item/chair/halflife/metal/red/broken
	desc = "A broken chair that is somehow more comfortable than a regular one."
	icon_state = "metal_chair_red_broken_toppled"
	item_state = "metal_chair_broken"
	origin_type = /obj/structure/chair/halflife/metal/red/broken

/obj/item/chair/halflife/metal/red/unfinished
	desc = "Without a backrest, this chair is essentially a stool with rods."
	icon_state = "metal_chair_red_unfinished_toppled"
	item_state = "metal_chair_unfinished"
	origin_type = /obj/structure/chair/halflife/metal/red/unfinished

/obj/item/chair/halflife/metal/folding
	name = "metal folding chair"
	desc = "Before the war, These were viewed as the lowest form of seat. Now? What's not to love. It's a chair that's easily moveable. Genius!"
	icon_state = "metal_chair_folding_toppled"
	item_state = "metal_chair_folding"
	origin_type = /obj/structure/chair/halflife/metal/folding

/obj/item/chair/halflife/metal/stool
	name = "bar stool"
	desc = "A bar stool. It's help up against time rather well. Perfect to prop yourself up on after a long day."
	icon_state = "barstool_toppled"
	item_state = "stool"
	origin_type = /obj/structure/chair/halflife/metal/stool

// Office Chair Items //

/obj/item/chair/halflife/metal/office
	name = "base class office chair"
	desc = "Scream at the coders if you see this."
	origin_type = /obj/structure/chair/office/halflife

/obj/item/chair/halflife/metal/office/red
	name = "office chair"
	desc = "Still spins, but not like this."
	icon_state = "office_chair_toppled"
	item_state = "office_chair"
	origin_type = /obj/structure/chair/office/halflife/red

/obj/item/chair/halflife/metal/office/red/broken
	desc = "Hardly spins. Especially not like this."
	icon_state = "office_chair_broken_toppled"
	item_state = "office_chair_broken"
	origin_type = /obj/structure/chair/office/halflife/red/broken

/obj/item/chair/halflife/metal/office/blue
	name = "office chair"
	desc = "Still spins, but not like this."
	icon_state = "office_chair_blue_toppled"
	item_state = "office_chair_blue"
	origin_type = /obj/structure/chair/office/halflife/blue

/obj/item/chair/halflife/metal/office/blue/broken
	desc = "Hardly spins. Especially not like this."
	icon_state = "office_chair_blue_broken_toppled"
	item_state = "office_chair_blue"
	origin_type = /obj/structure/chair/office/halflife/blue/broken

/obj/item/chair/halflife/metal/office/green
	name = "office chair"
	desc = "Still spins, but not like this."
	icon_state = "office_chair_green_toppled"
	item_state = "office_chair_green"
	origin_type = /obj/structure/chair/office/halflife/green

/obj/item/chair/halflife/metal/office/green/broken
	desc = "Hardly spins. Especially not like this."
	icon_state = "office_chair_green_broken_toppled"
	item_state = "office_chair_green"
	origin_type = /obj/structure/chair/office/halflife/green/broken

// Wood Chair Items //

/obj/item/chair/halflife/wood
	name = "wooden chair"
	desc = "An antique wooden chair with a small green cushion."
	icon_state = "wood_chair_toppled"
	item_state = "wood_chair"
	origin_type = /obj/structure/chair/halflife/wood

/obj/item/chair/halflife/wood/padded
	name = "padded wooden chair"
	desc = "An antique wooden chair with a large, plush red cushion"
	icon_state = "wood_chair_padded_toppled"
	item_state = "wood_chair_padded"
	origin_type = /obj/structure/chair/halflife/wood/padded

// Misc Chair Items //

/obj/item/chair/halflife/plastic
	name = "plastic chair"
	desc = "The most generic chair known to pre-war man."
	hitsound = "sound/halflifeweapons/meleesounds/plastic_slam.ogg"
	w_class = WEIGHT_CLASS_NORMAL
	force = 7
	throw_range = 5
	break_chance = 5
	icon_state = "plastic_chair_toppled"
	item_state = "plastic_chair"
	origin_type = /obj/structure/chair/halflife/overlaypickup/plastic

/obj/structure/chair/comfy/halflife/diner
	name = "diner seat"
	desc = "A nice padded diner style seat. A fantastic place to rest your feet."
	icon_state = "diner_chair"
	buildstacktype = /obj/item/stack/sheet/metal
	buildstackamount = 1
