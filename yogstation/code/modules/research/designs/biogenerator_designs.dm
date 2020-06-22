//Botanical Chemicals//

/datum/design/mutagen
	name = "Unstable Mutagen"
	id = "unstable_mutagen"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 600)
	build_path = /obj/item/reagent_containers/glass/bottle/mutagen
	category = list("initial","Botanical Chemicals")

//Food//

/datum/design/goat_cube
	name = "Goat Cube"
	id = "gcube"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 300)
	build_path = /obj/item/reagent_containers/food/snacks/monkeycube/goat
	category = list("initial", "Food")

/datum/design/sheep_cube
	name = "Sheep Cube"
	id = "scube"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 450)
	build_path = /obj/item/reagent_containers/food/snacks/monkeycube/sheep
	category = list("initial", "Food")

/datum/design/cow_cube
	name = "Cow Cube"
	id = "ccube"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 600)
	build_path = /obj/item/reagent_containers/food/snacks/monkeycube/cow
	category = list("initial", "Food")

//Special//

/datum/design/xpod_seeds
	name = "Xpod Seeds"
	id = "xpodseeds"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 40000)
	build_path = /obj/item/seeds/random
	category = list("initial", "Special")
