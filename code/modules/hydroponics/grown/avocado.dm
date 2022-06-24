// Avocado!!
/obj/item/seeds/avocado
	name = "pack of avocado seeds"
	desc = "These seeds grow into an avocado tree."
	icon_state = "seed-apple" //todo
	species = "avocado"
	plantname = "Avocado Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/avocado
	lifespan = 55
	endurance = 35
	yield = 4
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "apple-grow"//todo
	icon_dead = "apple-dead"//todo
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.1)


/obj/item/reagent_containers/food/snacks/grown/avocado
	seed = /obj/item/seeds/avocado
	name = "avocado"
	desc = "The crop of a tropical tree, not yet ripe."
	icon_state = "avocado_raw"
	filling_color = "#62bb58"
	bitesize = 200 
	foodtype = VEGETABLES
	tastes = list("raw avocado" = 1,)

/obj/item/reagent_containers/food/snacks/grown/avocado/ripe
	name = "avocado"
	desc = "The crop of a tropical tree, ripen to perfection."
	icon_state = "avocado_ripe"
	filling_color = "#a2bf1f"
	bitesize = 200 
	foodtype = VEGETABLES
	tastes = list("avocado" = 2, "zoomer nostalgia" = 1)

//still need to add grind results!!
//add code for riping avocados
