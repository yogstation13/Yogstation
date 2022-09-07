/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/crates.dmi'
	icon_state = "crate"
	req_access = null
	can_weld_shut = FALSE
	horizontal = TRUE
	allow_objects = TRUE
	allow_dense = TRUE
	dense_when_open = TRUE
	climbable = TRUE
	climb_time = 10 //real fast, because let's be honest stepping into or onto a crate is easy
	climb_stun = 0 //climbing onto crates isn't hard, guys
	delivery_icon = "deliverycrate"
	door_anim_time = 0 // no animation
	var/obj/item/paper/fluff/jobs/cargo/manifest/manifest

/obj/structure/closet/crate/Initialize()
	. = ..()
	if(icon_state == "[initial(icon_state)]open")
		opened = TRUE
	update_icon()

/obj/structure/closet/crate/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(!istype(mover, /obj/structure/closet))
		var/obj/structure/closet/crate/locatedcrate = locate(/obj/structure/closet/crate) in get_turf(mover)
		if(locatedcrate) //you can walk on it like tables, if you're not in an open crate trying to move to a closed crate
			if(opened) //if we're open, allow entering regardless of located crate openness
				return TRUE
			if(!locatedcrate.opened) //otherwise, if the located crate is closed, allow entering
				return TRUE

/obj/structure/closet/crate/update_icon()
	icon_state = "[initial(icon_state)][opened ? "open" : ""]"

	cut_overlays()
	if(manifest)
		add_overlay("manifest")

/obj/structure/closet/crate/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(manifest)
		tear_manifest(user)

/obj/structure/closet/crate/open(mob/living/user)
	. = ..()
	if(. && manifest)
		to_chat(user, span_notice("The manifest is torn off [src]."))
		playsound(src, 'sound/items/poster_ripped.ogg', 75, 1)
		manifest.forceMove(get_turf(src))
		manifest = null
		update_icon()

/obj/structure/closet/crate/proc/tear_manifest(mob/user)
	to_chat(user, span_notice("You tear the manifest off of [src]."))
	playsound(src, 'sound/items/poster_ripped.ogg', 75, 1)

	manifest.forceMove(loc)
	if(ishuman(user))
		user.put_in_hands(manifest)
	manifest = null
	update_icon()

/obj/structure/closet/crate/coffin
	name = "coffin"
	desc = "It's a burial receptacle for the dearly departed."
	icon_state = "coffin"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	material_drop = /obj/item/stack/sheet/mineral/wood
	material_drop_amount = 5

/obj/structure/closet/crate/internals
	desc = "An internals crate."
	name = "internals crate"
	icon_state = "o2crate"

/obj/structure/closet/crate/trashcart
	desc = "A heavy, metal trashcart with wheels."
	name = "trash cart"
	icon_state = "trashcart"

/obj/structure/closet/crate/medical
	desc = "A medical crate."
	name = "medical crate"
	icon_state = "medicalcrate"

/obj/structure/closet/crate/freezer
	desc = "A freezer."
	name = "freezer"
	icon_state = "freezer"

//Snowflake organ freezer code
//Order is important, since we check source, we need to do the check whenever we have all the organs in the crate

/obj/structure/closet/crate/freezer/open()
	recursive_organ_check(src)
	..()

/obj/structure/closet/crate/freezer/close()
	..()
	recursive_organ_check(src)

/obj/structure/closet/crate/freezer/Destroy()
	recursive_organ_check(src)
	..()

/obj/structure/closet/crate/freezer/Initialize()
	..()
	recursive_organ_check(src)



/obj/structure/closet/crate/freezer/blood
	name = "blood freezer"
	desc = "A freezer containing packs of blood."
	icon_state = "freezerblood"

/obj/structure/closet/crate/freezer/blood/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/blood(src)
	new /obj/item/reagent_containers/blood(src)
	new /obj/item/reagent_containers/blood/AMinus(src)
	new /obj/item/reagent_containers/blood/BMinus(src)
	new /obj/item/reagent_containers/blood/BPlus(src)
	new /obj/item/reagent_containers/blood/OMinus(src)
	new /obj/item/reagent_containers/blood/OPlus(src)
	new /obj/item/reagent_containers/blood/lizard(src)
	new /obj/item/reagent_containers/blood/gorilla(src) // yogs -- gorilla people
	new /obj/item/reagent_containers/blood/ethereal(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/blood/random(src)

/obj/structure/closet/crate/freezer/surplus_limbs
	name = "surplus prosthetic limbs"
	desc = "A crate containing an assortment of cheap prosthetic limbs."
	icon_state = "freezermedical"

/obj/structure/closet/crate/freezer/surplus_limbs/PopulateContents()
	. = ..()
	new /obj/item/bodypart/l_arm/robot/surplus(src)
	new /obj/item/bodypart/l_arm/robot/surplus(src)
	new /obj/item/bodypart/r_arm/robot/surplus(src)
	new /obj/item/bodypart/r_arm/robot/surplus(src)
	new /obj/item/bodypart/l_leg/robot/surplus(src)
	new /obj/item/bodypart/l_leg/robot/surplus(src)
	new /obj/item/bodypart/r_leg/robot/surplus(src)
	new /obj/item/bodypart/r_leg/robot/surplus(src)

/obj/structure/closet/crate/radiation
	desc = "A crate with a radiation sign on it."
	name = "radiation crate"
	icon_state = "radiation"

/obj/structure/closet/crate/hydroponics
	name = "hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon_state = "hydrocrate"

/obj/structure/closet/crate/engineering
	name = "engineering crate"
	icon_state = "engi_crate"

/obj/structure/closet/crate/engineering/electrical
	icon_state = "engi_e_crate"

/obj/structure/closet/crate/rcd
	desc = "A crate for the storage of an RCD."
	name = "\improper RCD crate"
	icon_state = "engi_crate"

/obj/structure/closet/crate/rcd/PopulateContents()
	..()
	for(var/i in 1 to 4)
		new /obj/item/rcd_ammo(src)
	new /obj/item/construction/rcd(src)

/obj/structure/closet/crate/science
	name = "science crate"
	desc = "A science crate."
	icon_state = "scicrate"

/obj/structure/closet/crate/solarpanel_small
	name = "budget solar panel crate"
	icon_state = "engi_e_crate"

/obj/structure/closet/crate/solarpanel_small/PopulateContents()
	..()
	for(var/i in 1 to 13)
		new /obj/item/solar_assembly(src)
	new /obj/item/circuitboard/computer/solar_control(src)
	new /obj/item/paper/guides/jobs/engi/solars(src)
	new /obj/item/electronics/tracker(src)

/obj/structure/closet/crate/goldcrate
	name = "gold crate"

/obj/structure/closet/crate/goldcrate/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/stack/sheet/mineral/gold(src, 1, FALSE)
	new /obj/item/storage/belt/champion(src)

/obj/structure/closet/crate/silvercrate
	name = "silver crate"

/obj/structure/closet/crate/silvercrate/PopulateContents()
	..()
	for(var/i in 1 to 5)
		new /obj/item/coin/silver(src)

/obj/structure/closet/crate/magic
	name = "Rune Crate"
	desc = "This crate glows with a weak glow, are you sure you want to open it?"


/obj/structure/closet/crate/magic/PopulateContents()
	var/table = rand(1,12) //12 customized surprise mechanics�  for you all
	switch(table)
		if(1)
			new /obj/item/gun/magic/rune/icycle_rune(src)
			new /obj/item/gun/magic/rune/tentacle_rune(src)
			new /obj/item/gun/magic/rune/heal_rune(src)
			new /obj/item/gun/magic/rune/fire_rune(src)
		if(2)
			new /obj/item/gun/magic/rune/honk_rune(src)
			new /obj/item/gun/magic/rune/chaos_rune(src)
			new /obj/item/gun/magic/rune/bomb_rune(src)
			new /obj/item/gun/magic/rune/toxic_rune(src)
		if(3)
			new /obj/item/gun/magic/rune/_rune(src)
			new /obj/item/gun/magic/rune/bullet_rune(src)
			new /obj/item/gun/magic/rune/mutation_rune(src)
			new /obj/item/gun/magic/rune/resizement_rune(src)
		if(4)
			new /obj/item/gun/magic/rune/icycle_rune(src)
			new /obj/item/gun/magic/rune/heal_rune(src)
			new /obj/item/gun/magic/rune/honk_rune(src)
			new /obj/item/gun/magic/rune/bomb_rune(src)
		if(5)
			new /obj/item/gun/magic/rune/_rune(src)
			new /obj/item/gun/magic/rune/mutation_rune(src)
			new /obj/item/gun/magic/rune/tentacle_rune(src)
			new /obj/item/gun/magic/rune/fire_rune(src)
		if(6)
			new	/obj/item/gun/magic/rune/chaos_rune(src)
			new	/obj/item/gun/magic/rune/toxic_rune(src)
			new /obj/item/gun/magic/rune/bullet_rune(src)
			new /obj/item/gun/magic/rune/resizement_rune(src)
		if(7)
			new /obj/item/gun/magic/rune/icycle_rune(src)
			new /obj/item/gun/magic/rune/fire_rune(src)
			new /obj/item/gun/magic/rune/bomb_rune(src)
			new /obj/item/gun/magic/rune/bullet_rune(src)
		if(8)
			new /obj/item/gun/magic/rune/tentacle_rune(src)
			new /obj/item/gun/magic/rune/honk_rune(src)
			new /obj/item/gun/magic/rune/toxic_rune(src)
			new /obj/item/gun/magic/rune/mutation_rune(src)
		if(9)
			new /obj/item/gun/magic/rune/heal_rune(src)
			new /obj/item/gun/magic/rune/chaos_rune(src)
			new /obj/item/gun/magic/rune/_rune(src)
			new /obj/item/gun/magic/rune/resizement_rune(src)
		if(10)
			new /obj/item/gun/magic/rune/fire_rune(src)
			new /obj/item/gun/magic/rune/bomb_rune(src)
			new /obj/item/gun/magic/rune/bullet_rune(src)
			new /obj/item/gun/magic/rune/icycle_rune(src)
		if(11)
			new /obj/item/gun/magic/rune/honk_rune(src)
			new /obj/item/gun/magic/rune/toxic_rune(src)
			new /obj/item/gun/magic/rune/mutation_rune(src)
			new /obj/item/gun/magic/rune/tentacle_rune(src)
		if(12)
			new /obj/item/gun/magic/rune/chaos_rune(src)
			new /obj/item/gun/magic/rune/_rune(src)
			new /obj/item/gun/magic/rune/resizement_rune(src)
			new /obj/item/gun/magic/rune/heal_rune(src)

/obj/structure/closet/crate/sphere
	desc = "An Advanced Crate that defies all known cargo standards."
	name = "Advanced Crate"
	icon = 'yogstation/icons/obj/crates.dmi'
	icon_state = "round"

/obj/structure/closet/crate/critter/exoticgoats
	name = "goat crate"
	desc = "Contains a completly random goat from Goat Tech Industries that may or may not break the laws of science!"

/obj/structure/closet/crate/critter/exoticgoats/Initialize()
	. = ..()
	var/loot = rand(1,40) //40 different goats!
	switch(loot)
		if(1)
			new /mob/living/simple_animal/hostile/retaliate/goat(loc)
		if(2)
			new /mob/living/simple_animal/hostile/retaliate/goat/clown(loc)
		if(3)
			new /mob/living/simple_animal/hostile/retaliate/goat/ras(loc)
		if(4)
			new /mob/living/simple_animal/hostile/retaliate/goat/blue(loc)
		if(5)
			new /mob/living/simple_animal/hostile/retaliate/goat/chocolate(loc)
		if(6)
			new /mob/living/simple_animal/hostile/retaliate/goat/christmas(loc)
		if(7)
			new /mob/living/simple_animal/hostile/retaliate/goat/confetti(loc)
		if(8)
			new /mob/living/simple_animal/hostile/retaliate/goat/cottoncandy(loc)
		if(9)
			new /mob/living/simple_animal/hostile/retaliate/goat/glowing(loc)
		if(10)
			new /mob/living/simple_animal/hostile/retaliate/goat/goatgoat(loc)
		if(11)
			new /mob/living/simple_animal/hostile/retaliate/goat/horror(loc)
		if(12)
			new /mob/living/simple_animal/hostile/retaliate/goat/inverted(loc)
		if(13)
			new /mob/living/simple_animal/hostile/retaliate/goat/memory(loc)
		if(14)
			new /mob/living/simple_animal/hostile/retaliate/goat/mirrored(loc)
		if(15)
			new /mob/living/simple_animal/hostile/retaliate/goat/paper(loc)
		if(16)
			new /mob/living/simple_animal/hostile/retaliate/goat/pixel(loc)
		if(17)
			new /mob/living/simple_animal/hostile/retaliate/goat/radioactive(loc)
		if(18)
			new /mob/living/simple_animal/hostile/retaliate/goat/rainbow(loc)
		if(19)
			new /mob/living/simple_animal/hostile/retaliate/goat/cute(loc)
		if(20)
			new /mob/living/simple_animal/hostile/retaliate/goat/star(loc)
		if(21)
			new /mob/living/simple_animal/hostile/retaliate/goat/twisted(loc)
		if(22)
			new /mob/living/simple_animal/hostile/retaliate/goat/huge(loc)
		if(23)
			new /mob/living/simple_animal/hostile/retaliate/goat/tiny(loc)
		if(24)
			new /mob/living/simple_animal/hostile/retaliate/goat/ghost(loc)
		if(25)
			new /mob/living/simple_animal/hostile/retaliate/goat/brick(loc)
		if(26)
			new /mob/living/simple_animal/hostile/retaliate/goat/watercolor(loc)
		if(27)
			new /mob/living/simple_animal/hostile/retaliate/goat/brown(loc)
		if(28)
			new /mob/living/simple_animal/hostile/retaliate/goat/panda(loc)
		if(29)
			new /mob/living/simple_animal/hostile/retaliate/goat/black(loc)
		if(30)
			new /mob/living/simple_animal/hostile/retaliate/goat/green(loc)
		if(31)
			new /mob/living/simple_animal/hostile/retaliate/goat/orange(loc)
		if(32)
			new /mob/living/simple_animal/hostile/retaliate/goat/purple(loc)
		if(33)
			new /mob/living/simple_animal/hostile/retaliate/goat/red(loc)
		if(34)
			new /mob/living/simple_animal/hostile/retaliate/goat/yellow(loc)
		if(35)
			new /mob/living/simple_animal/hostile/retaliate/goat/legitgoat(loc)
		if(36)
			new /mob/living/simple_animal/hostile/retaliate/goat/skiddo(loc)
		if(37)
			new /mob/living/simple_animal/hostile/retaliate/goat/gogoat(loc)
		if(38)
			new /mob/living/simple_animal/hostile/retaliate/goat/sanic(loc)
		if(39)
			new /mob/living/simple_animal/hostile/retaliate/goat/plunger(loc)
		if(40)
			new /mob/living/simple_animal/hostile/retaliate/goat/suspicious(loc)
