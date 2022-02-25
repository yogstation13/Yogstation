/obj/item/seeds/cinnamomum
	name = "pack of cinnamomum tree seeds"
	desc = "These seeds grow into a cinnamomum tree, which can be harvested for cinnamon."
	icon_state = "seed-cinnamomum"
	species = "cinnamomum"
	plantname = "Cinnamomum Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/cinnamon_stick
	lifespan = 50
	endurance = 50
	yield = 3
	potency = 35
	growthstages = 4
	icon_grow = "cinnamomum-grow"
	icon_dead = "cinnamomum-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/consumable/cinnamon = 0.15, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/reagent_containers/food/snacks/grown/cinnamon_stick
	seed = /obj/item/seeds/cinnamomum
	name = "Cinnamon"
	desc = "Straight from the bark!"
	icon_state = "cinnamon_stick"
	bitesize_mod = 2
