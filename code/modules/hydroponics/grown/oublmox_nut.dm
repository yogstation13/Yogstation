//Oublmox Nut
/obj/item/seeds/oublmox_nut
	name = "pack of oublmox nut seeds"
	desc = "These seeds grow into oublmox nut bushes, native to Sangris."
	icon_state = "seed-oublmox"
	species = "oublmoxnut"
	plantname = "Oublmox Nut Bush"
	product = /obj/item/reagent_containers/food/snacks/grown/oublmox_nut
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "oublmoxnut-grow"
	icon_dead = "oublmoxnut-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/oublmox_nut/sweet)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/reagent_containers/food/snacks/grown/oublmox_nut
	seed = /obj/item/seeds/oublmox_nut
	name = "oublmox nut"
	desc = "A small nut. Has a peppery shell that can be ground into flour. Inside is a soft, pulpy interior that produces a milky fluid when juiced. Or you can eat them whole, as a quick snack."
	icon_state = "oublmox_nut"
	grind_results = list(/datum/reagent/consumable/oublmox_flour = 0)
	juice_results = list(/datum/reagent/consumable/oublmox_milk = 0)
	tastes = list("peppery heat" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/oublmoxa

//Sweet Oublmox Nut
/obj/item/seeds/oublmox_nut/sweet
	name = "pack of sweet oublmox nut seeds"
	desc = "These seeds grow into sweet oublmox nuts, a mutation of the original species that produces a thick syrup that vuulen use in desserts."
	icon_state = "seed-sweetoublmox"
	species = "oublmoxnut"
	plantname = "Sweet Oublmox Nut Bush"
	product = /obj/item/reagent_containers/food/snacks/grown/oublmox_nut/sweet
	maturation = 10
	production = 10
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/oublmox_nectar = 0.1, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	rarity = 20

/obj/item/reagent_containers/food/snacks/grown/oublmox_nut/sweet
	seed = /obj/item/seeds/oublmox_nut/sweet
	name = "sweet oublmox nut"
	desc = "A sweet treat lizards love to eat."
	icon_state = "oublmox_nut"
	grind_results = list(/datum/reagent/consumable/oublmox_flour = 0)
	juice_results = list(/datum/reagent/consumable/oublmox_milk = 0, /datum/reagent/consumable/oublmox_nectar = 0)
	tastes = list("peppery sweet" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/oublmoxa
