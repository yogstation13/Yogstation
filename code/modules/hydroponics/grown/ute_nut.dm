//Ute Nut
/obj/item/seeds/ute_nut
	name = "pack of ute nut seeds"
	desc = "These seeds grow into ute nut bushes, native to Sangris."
	icon_state = "seed-ute"
	species = "utenut"
	plantname = "Ute Nut Bush"
	product = /obj/item/reagent_containers/food/snacks/grown/ute_nut
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "utenut-grow"
	icon_dead = "utenut-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/ute_nut/sweet)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/reagent_containers/food/snacks/grown/ute_nut
	seed = /obj/item/seeds/ute_nut
	name = "ute nut"
	desc = "A small nut. Has a peppery shell that can be ground into flour. Inside is a soft, pulpy interior that produces a milky fluid when juiced. Or you can eat them whole, as a quick snack."
	icon_state = "ute_nut"
	grind_results = list(/datum/reagent/consumable/ute_flour = 0)
	juice_results = list(/datum/reagent/consumable/ute_milk = 0)
	tastes = list("peppery heat" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/utri

//Sweet Ute Nut
/obj/item/seeds/ute_nut/sweet
	name = "pack of sweet ute nut seeds"
	desc = "These seeds grow into sweet ute nuts, a mutation of the original species that produces a thick syrup that vuulen use in desserts."
	icon_state = "seed-sweetute"
	species = "utenut"
	plantname = "Sweet Ute Nut Bush"
	product = /obj/item/reagent_containers/food/snacks/grown/ute_nut/sweet
	maturation = 10
	production = 10
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/ute_nectar = 0.1, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	rarity = 20

/obj/item/reagent_containers/food/snacks/grown/ute_nut/sweet
	seed = /obj/item/seeds/ute_nut/sweet
	name = "sweet ute nut"
	desc = "A sweet treat lizards love to eat."
	icon_state = "ute_nut"
	grind_results = list(/datum/reagent/consumable/ute_flour = 0)
	juice_results = list(/datum/reagent/consumable/ute_milk = 0, /datum/reagent/consumable/ute_nectar = 0)
	tastes = list("peppery sweet" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/utri
