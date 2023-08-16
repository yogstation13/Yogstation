///////////////////////////////////
///////Biogenerator Designs ///////
///////////////////////////////////

/datum/design/milk
	name = "10u Milk"
	id = "milk"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 20)
	make_reagents = list(/datum/reagent/consumable/milk = 10)
	category = list("initial","Kitchen Chemicals")

/datum/design/soymilk
	name = "10u Soy Milk"
	id = "soymilk"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 50)
	make_reagents = list(/datum/reagent/consumable/soymilk = 10)
	category = list("initial","Kitchen Chemicals")

/datum/design/soysauce
	name = "10u Soy Sauce"
	id = "soysauce"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 75)
	make_reagents = list(/datum/reagent/consumable/soysauce = 10)
	category = list("initial","Kitchen Chemicals")

/datum/design/cream
	name = "10u Cream"
	id = "cream"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 30)
	make_reagents = list(/datum/reagent/consumable/cream = 10)
	category = list("initial","Kitchen Chemicals")

/datum/design/black_pepper
	name = "10u Black Pepper"
	id = "black_pepper"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 25)
	make_reagents = list(/datum/reagent/consumable/blackpepper = 10)
	category = list("initial","Kitchen Chemicals")

/datum/design/salt
	name = "10u Salt"
	id = "salt"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 25)
	make_reagents = list(/datum/reagent/consumable/sodiumchloride = 10)
	category = list("initial","Kitchen Chemicals")

/datum/design/enzyme
	name = "10u Universal Enzyme"
	id = "enzyme"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 30)
	make_reagents = list(/datum/reagent/consumable/enzyme = 10)
	category = list("initial","Kitchen Chemicals")

/datum/design/flour_sack
	name = "Flour Sack"
	id = "flour_sack"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 150)
	build_path = /obj/item/reagent_containers/food/condiment/flour
	category = list("initial","Food")

/datum/design/rice_sack
	name = "Rice Sack"
	id = "rice_sack"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 300)
	build_path = /obj/item/reagent_containers/food/condiment/rice
	category = list("initial","Food")

/datum/design/meat
	name = "Synthetic Meat"
	id = "meat"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 150)
	build_path = /obj/item/reagent_containers/food/snacks/meat/slab
	category = list("initial","Food")

/datum/design/egg
	name = "Synthetic Egg"
	id = "egg"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 100)
	build_path = /obj/item/reagent_containers/food/snacks/egg
	category = list("initial","Food")

/datum/design/monkey_cube
	name = "Monkey Cube"
	id = "mcube"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 250)
	build_path = /obj/item/reagent_containers/food/snacks/monkeycube
	category = list("initial", "Food")

/datum/design/goat_cube
	name = "Goat Cube"
	id = "gcube"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 350)
	build_path = /obj/item/reagent_containers/food/snacks/monkeycube/goat
	category = list("initial", "Food")

/datum/design/cow_cube
	name = "Cow Cube"
	id = "cowcube"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 500)
	build_path = /obj/item/reagent_containers/food/snacks/monkeycube/cow
	category = list("initial", "Food")

/datum/design/chicken_cube
	name = "Chicken Cube"
	id = "chickencube"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 200)
	build_path = /obj/item/reagent_containers/food/snacks/monkeycube/chicken
	category = list("initial", "Food")

/datum/design/sheep_cube
	name = "Sheep Cube"
	id = "sheepcube"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 350)
	build_path = /obj/item/reagent_containers/food/snacks/monkeycube/sheep
	category = list("initial", "Food")

/datum/design/seaweed_sheet
	name = "Seaweed Sheet"
	id = "seaweedsheet"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 30)
	build_path = /obj/item/reagent_containers/food/snacks/seaweedsheet
	category = list("initial","Food")

/datum/design/ez_nut
	name = "E-Z Nutrient"
	id = "ez_nut"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 10)
	build_path = /obj/item/reagent_containers/glass/bottle/nutrient/ez
	category = list("initial","Botany Chemicals")

/datum/design/l4z_nut
	name = "Left 4 Zed"
	id = "l4z_nut"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 20)
	build_path = /obj/item/reagent_containers/glass/bottle/nutrient/l4z
	category = list("initial","Botany Chemicals")

/datum/design/rh_nut
	name = "Robust Harvest"
	id = "rh_nut"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 25)
	build_path = /obj/item/reagent_containers/glass/bottle/nutrient/rh
	category = list("initial","Botany Chemicals")

/datum/design/weed_killer
	name = "Weed Killer"
	id = "weed_killer"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 50)
	build_path = /obj/item/reagent_containers/glass/bottle/killer/weedkiller
	category = list("initial","Botany Chemicals")

/datum/design/pest_spray
	name = "Pest Killer"
	id = "pest_spray"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 50)
	build_path = /obj/item/reagent_containers/glass/bottle/killer/pestkiller
	category = list("initial","Botany Chemicals")

/datum/design/botany_bottle
	name = "Empty Bottle"
	id = "botany_bottle"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 5)
	build_path = /obj/item/reagent_containers/glass/bottle/nutrient/empty
	category = list("initial", "Botany Chemicals")

/datum/design/rollingpapers
	name = "Rolling Papers"
	id = "rollingpapers"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 50)
	build_path = /obj/item/storage/fancy/rollingpapers
	category = list("initial", "Organic Materials")

/datum/design/cloth
	name = "Roll of Cloth"
	id = "cloth"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 50)
	build_path = /obj/item/stack/sheet/cloth
	category = list("initial","Organic Materials")

/datum/design/cardboard
	name = "Sheet of Cardboard"
	id = "cardboard"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 25)
	build_path = /obj/item/stack/sheet/cardboard
	category = list("initial","Organic Materials")

/datum/design/leather
	name = "Sheet of Leather"
	id = "leather"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 150)
	build_path = /obj/item/stack/sheet/leather
	category = list("initial","Organic Materials")

/datum/design/tape
	name = "Roll of Tape"
	id = "tape"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 50)
	build_path = /obj/item/stack/tape
	category = list("initial","Organic Materials")

/datum/design/secbelt
	name = "Security Belt"
	id = "secbelt"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 300)
	build_path = /obj/item/storage/belt/security
	category = list("initial","Organic Materials")

/datum/design/medbelt
	name = "Medical Belt"
	id = "medbel"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 300)
	build_path = /obj/item/storage/belt/medical
	category = list("initial","Organic Materials")

/datum/design/janibelt
	name = "Janitorial Belt"
	id = "janibelt"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 300)
	build_path = /obj/item/storage/belt/janitor
	category = list("initial","Organic Materials")

/datum/design/s_holster
	name = "Shoulder Holster"
	id = "s_holster"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 400)
	build_path = /obj/item/storage/belt/holster
	category = list("initial","Organic Materials")

/datum/design/rice_hat
	name = "Rice Hat"
	id = "rice_hat"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 300)
	build_path = /obj/item/clothing/head/rice_hat
	category = list("initial","Organic Materials")

/datum/design/mutagen
	name = "Unstable Mutagen"
	id = "unstable_mutagen"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 600)
	build_path = /obj/item/reagent_containers/glass/bottle/mutagen
	category = list("initial","Botany Chemicals")
