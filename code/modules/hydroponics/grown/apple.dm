// Apple
/obj/item/seeds/apple
	name = "pack of apple seeds"
	desc = "These seeds grow into apple trees."
	icon_state = "seed-apple"
	species = "apple"
	plantname = "Apple Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/apple
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "apple-grow"
	icon_dead = "apple-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/apple/gold)
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.1)

/obj/item/reagent_containers/food/snacks/grown/apple
	seed = /obj/item/seeds/apple
	name = "apple"
	desc = "It's a little piece of Eden."
	icon_state = "apple"
	filling_color = "#FF4500"
	bitesize = 100 // Always eat the apple in one bite
	foodtype = FRUIT
	juice_results = list(/datum/reagent/consumable/applejuice = 0)
	tastes = list("apple" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/hcider

/obj/item/reagent_containers/food/snacks/grown/apple/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(isliving(hit_atom) && throwingdatum.thrower && isliving(throwingdatum.thrower))
		keep_away(hit_atom, throwingdatum.thrower)

/obj/item/reagent_containers/food/snacks/grown/apple/attack(mob/living/target, mob/living/user)
	. = ..()
	keep_away(target, user)

/obj/item/reagent_containers/food/snacks/grown/apple/proc/keep_away(mob/living/target, mob/living/user)
	if(target == user)
		return
	if(target.job == "Medical Doctor" || target.job == "Chief Medical Officer")
		var/atom/throw_target = get_edge_target_turf(M, user.dir)
		ADD_TRAIT(target, TRAIT_IMPACTIMMUNE, "apple")//keep them away, don't hurt them
		target.throw_at(throw_target, 1, 1, user, FALSE, TRUE, callback = CALLBACK(src, PROC_REF(afterimpact), target))

/obj/item/reagent_containers/food/snacks/grown/apple/proc/afterimpact(mob/living/M)
	REMOVE_TRAIT(M, TRAIT_IMPACTIMMUNE, "apple")

// Gold Apple
/obj/item/seeds/apple/gold
	name = "pack of golden apple seeds"
	desc = "These seeds grow into golden apple trees. Good thing there are no firebirds in space."
	icon_state = "seed-goldapple"
	species = "goldapple"
	plantname = "Golden Apple Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/apple/gold
	maturation = 10
	production = 10
	mutatelist = list()
	reagents_add = list(/datum/reagent/gold = 0.2, /datum/reagent/consumable/nutriment = 0.1)
	rarity = 40 // Alchemy!

/obj/item/reagent_containers/food/snacks/grown/apple/gold
	seed = /obj/item/seeds/apple/gold
	name = "golden apple"
	desc = "Emblazoned upon the apple is the word 'Kallisti'."
	icon_state = "goldapple"
	filling_color = "#FFD700"
	distill_reagent = null
	wine_power = 50
