/datum/plant_gene/trait/noreact
	// Makes plant reagents not react until squashed.
	name = "Separated Chemicals"

/datum/plant_gene/trait/noreact/on_new(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	..()
	G.reagents.set_reacting(FALSE)

/datum/plant_gene/trait/noreact/on_squash(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	G.reagents.set_reacting(FALSE)
	G.reagents.handle_reactions()
