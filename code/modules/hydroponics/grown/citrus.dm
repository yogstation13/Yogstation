// Citrus - base type
/obj/item/reagent_containers/food/snacks/grown/citrus
	seed = /obj/item/seeds/lime
	name = "citrus"
	desc = "It's so sour, your face will twist."
	icon_state = "lime"
	bitesize_mod = 2
	foodtype = FRUIT
	wine_power = 30

// Lime
/obj/item/seeds/lime
	name = "pack of lime seeds"
	desc = "These are very sour seeds."
	icon_state = "seed-lime"
	species = "lime"
	plantname = "Lime Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/citrus/lime
	lifespan = 55
	endurance = 50
	yield = 4
	potency = 15
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/orange, /obj/item/seeds/lime_3d)
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.05)

/obj/item/reagent_containers/food/snacks/grown/citrus/lime
	seed = /obj/item/seeds/lime
	name = "lime"
	desc = "It's so sour, your face will twist."
	icon_state = "lime"
	filling_color = "#00FF00"
	juice_results = list(/datum/reagent/consumable/limejuice = 0)

//3D Lime
/obj/item/seeds/lime_3d
	name = "pack of extradimensional lime seeds"
	desc = "A product of research into the overlapping of 3D dimensions."
	icon_state = "seed-lime3d"
	species = "lime"
	plantname = "Extradimensional Lime Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/citrus/lime_3d
	lifespan = 60
	endurance = 50
	yield = 5
	potency = 20
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "lime-grow"
	icon_dead = "lime-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.1, /datum/reagent/consumable/nutriment/vitamin = 0.15, /datum/reagent/consumable/sodiumchloride = 0.15)
	rarity = 30

/obj/item/reagent_containers/food/snacks/grown/citrus/lime_3d
	seed = /obj/item/seeds/lime_3d
	name = "extradimensional lime"
	desc = "You can hardly wrap your head around this thing."
	icon_state = "lim"
	filling_color = "#00FF00"
	juice_results = list(/datum/reagent/consumable/limejuice = 0)
	volume = 150
	distill_reagent = /datum/reagent/consumable/ethanol/triple_sec
	tastes = list("polygons" = 1, "limes" = 1)

/obj/item/reagent_containers/food/snacks/grown/citrus/lime_3d/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/max = rand(10, 20)

	for (var/counter = 1 to max)
		var/obj/item/reagent_containers/food/snacks/grown/citrus/lime/lime = new(get_turf(src))
		lime.throw_at(pick(oview(7, get_turf(src))), 10, 1)
		lime.seed.lifespan = seed.lifespan
		lime.seed.endurance = seed.endurance
		lime.seed.maturation = seed.maturation
		lime.seed.production = seed.production
		lime.seed.yield = seed.yield
		lime.seed.potency = seed.potency
		lime.seed.weed_rate = seed.weed_rate
		lime.seed.weed_chance = seed.weed_chance
		lime.seed.genes |= seed.genes
		for(var/datum/reagent/R  in reagents.reagent_list)
			R.volume /= 2
			lime.reagents.reagent_list |= reagents.reagent_list

	audible_message("[src] splits!")
	qdel(src)
	return ..()

// Orange
/obj/item/seeds/orange
	name = "pack of orange seeds"
	desc = "Sour seeds."
	icon_state = "seed-orange"
	species = "orange"
	plantname = "Orange Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/citrus/orange
	lifespan = 60
	endurance = 50
	yield = 5
	potency = 20
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "lime-grow"
	icon_dead = "lime-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/lime)
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.05)

/obj/item/reagent_containers/food/snacks/grown/citrus/orange
	seed = /obj/item/seeds/orange
	name = "orange"
	desc = "It's a tangy fruit."
	icon_state = "orange"
	filling_color = "#FFA500"
	juice_results = list(/datum/reagent/consumable/orangejuice = 0)
	distill_reagent = /datum/reagent/consumable/ethanol/triple_sec

// Lemon
/obj/item/seeds/lemon
	name = "pack of lemon seeds"
	desc = "These are sour seeds."
	icon_state = "seed-lemon"
	species = "lemon"
	plantname = "Lemon Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/citrus/lemon
	lifespan = 55
	endurance = 45
	yield = 4
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "lime-grow"
	icon_dead = "lime-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/firelemon)
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.05)

/obj/item/reagent_containers/food/snacks/grown/citrus/lemon
	seed = /obj/item/seeds/lemon
	name = "lemon"
	desc = "When life gives you lemons, make lemonade."
	icon_state = "lemon"
	filling_color = "#FFD700"
	juice_results = list(/datum/reagent/consumable/lemonjuice = 0)

// Combustible lemon
/obj/item/seeds/firelemon //combustible lemon is too long so firelemon
	name = "pack of combustible lemon seeds"
	desc = "When life gives you lemons, don't make lemonade. Make life take the lemons back! Get mad! I don't want your damn lemons!"
	icon_state = "seed-firelemon"
	species = "firelemon"
	plantname = "Combustible Lemon Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/firelemon
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "lime-grow"
	icon_dead = "lime-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	lifespan = 55
	endurance = 45
	yield = 4
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.05)
	rarity = 20

/obj/item/reagent_containers/food/snacks/grown/firelemon
	seed = /obj/item/seeds/firelemon
	name = "Combustible Lemon"
	desc = "Made for burning houses down."
	icon_state = "firelemon"
	bitesize_mod = 2
	foodtype = FRUIT
	wine_power = 70

/obj/item/reagent_containers/food/snacks/grown/firelemon/attack_self(mob/living/user)
	user.visible_message(span_warning("[user] primes [src]!"), span_userdanger("You prime [src]!"))
	log_bomber(user, "primed a", src, "for detonation")
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.throw_mode_on()
	icon_state = "firelemon_active"
	playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	addtimer(CALLBACK(src, PROC_REF(prime)), rand(10, 60))

/obj/item/reagent_containers/food/snacks/grown/firelemon/burn()
	prime()
	..()

/obj/item/reagent_containers/food/snacks/grown/firelemon/proc/update_mob()
	if(ismob(loc))
		var/mob/M = loc
		M.dropItemToGround(src)

/obj/item/reagent_containers/food/snacks/grown/firelemon/ex_act(severity)
	qdel(src) //Ensuring that it's deleted by its own explosion

/obj/item/reagent_containers/food/snacks/grown/firelemon/proc/prime()
	switch(seed.potency) //Combustible lemons are alot like IEDs, lots of flame, very little bang.
		if(0 to 30)
			update_mob()
			explosion(src.loc,-1,-1,2, flame_range = 1)
			qdel(src)
		if(31 to 50)
			update_mob()
			explosion(src.loc,-1,-1,2, flame_range = 2)
			qdel(src)
		if(51 to 70)
			update_mob()
			explosion(src.loc,-1,-1,2, flame_range = 3)
			qdel(src)
		if(71 to 90)
			update_mob()
			explosion(src.loc,-1,-1,2, flame_range = 4)
			qdel(src)
		else
			update_mob()
			explosion(src.loc,-1,-1,2, flame_range = 5)
			qdel(src)
