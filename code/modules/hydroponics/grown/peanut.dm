/obj/item/seeds/peanut
	name = "pack of peanut seeds"
	desc = "These seeds grow into peanut plants."
	icon_state = "seed-peanut"
	species = "peanut"
	plantname = "Peanut Plant"
	product = /obj/item/reagent_containers/food/snacks/grown/peanut
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'icons/obj/hydroponics/growing.dmi'
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/reagent_containers/food/snacks/grown/peanut
	seed = /obj/item/seeds/peanut
	name = "peanut"
	desc = "A tasty pair of groundnuts concealed in a tough shell."
	icon_state = "peanut"
	foodtype = NUTS
	grind_results = list(/datum/reagent/consumable/peanut_butter = 0)
	tastes = list("peanuts" = 1)