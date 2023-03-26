///Global list of recipes for atmospheric machines to use
GLOBAL_LIST_INIT(gas_recipe_meta, gas_recipes_list())

/*
 * Global proc to build the gas recipe global list
 */
/proc/gas_recipes_list()
	. = list()
	for(var/recipe_path in subtypesof(/datum/gas_recipe))
		var/datum/gas_recipe/recipe = new recipe_path()

		.[recipe.id] = recipe

/datum/gas_recipe
	///Id of the recipe for easy identification in the code
	var/id = ""
	///What machine the recipe is for
	var/machine_type = ""
	///Displayed name of the recipe
	var/name = ""
	///Minimum temperature for the recipe
	var/min_temp = TCMB
	///Maximum temperature for the recipe
	var/max_temp = INFINITY
	/**
	 * Amount of thermal energy released/consumed by the reaction.
	 * Positive numbers make the reaction release energy (exothermic) while negative numbers make the reaction consume energy (endothermic).
	 */
	var/energy_release = 0
	var/dangerous = FALSE
	///Gas required for the recipe to work
	var/list/requirements
	///Products made from the recipe
	var/list/products

/datum/gas_recipe/crystallizer
	machine_type = "Crystallizer"

/datum/gas_recipe/crystallizer/metallic_hydrogen
	id = "metal_h"
	name = "Metallic hydrogen"
	min_temp = 50000
	max_temp = 150000
	energy_release = -2500000
	requirements = list(/datum/gas/hydrogen = 300, /datum/gas/bz = 50)
	products = list(/obj/item/stack/sheet/mineral/metal_hydrogen = 1)

/datum/gas_recipe/crystallizer/supermatter_extraction_tongs
	id = "sm_tongs"
	name = "supermatter extraction tongs"
	min_temp = 50000
	max_temp = 150000
	energy_release = -150000
	requirements = list(/datum/gas/hydrogen = 100, /datum/gas/hypernoblium = 5, /datum/gas/bz = 5)
	products = list(/obj/item/hemostat/supermatter = 1)

/datum/gas_recipe/crystallizer/supermatter_base_structure
	id = "sm_structure"
	name = "supermatter base structure"
	min_temp = 50000
	max_temp = 150000
	energy_release = -200000
	requirements = list(/datum/gas/hydrogen = 1000, /datum/gas/bz = 100, /datum/gas/hypernoblium = 10)
	products = list(/obj/structure/supermatter_base_structure = 1)

/datum/gas_recipe/crystallizer/healium_grenade
	id = "healium_g"
	name = "Healium crystal"
	min_temp = 200
	max_temp = 400
	energy_release = -2000000
	requirements = list(/datum/gas/healium = 100, /datum/gas/freon = 120, /datum/gas/plasma = 50)
	products = list(/obj/item/grenade/gas_crystal/healium_crystal = 1)

/datum/gas_recipe/crystallizer/pluonium_grenade
	id = "pluonium_g"
	name = "Pluonium crystal"
	min_temp = 200
	max_temp = 400
	energy_release = 1500000
	requirements = list(/datum/gas/pluonium = 100, /datum/gas/nitrogen = 80, /datum/gas/oxygen = 80)
	products = list(/obj/item/grenade/gas_crystal/pluonium_crystal = 1)

/datum/gas_recipe/crystallizer/hot_ice
	id = "hot_ice"
	name = "Hot ice"
	min_temp = 15
	max_temp = 35
	energy_release = -3000000
	requirements = list(/datum/gas/freon = 60, /datum/gas/plasma = 160, /datum/gas/oxygen = 80)
	products = list(/obj/item/stack/sheet/hot_ice = 1)

/datum/gas_recipe/crystallizer/ammonia_crystal
	id = "ammonia_crystal"
	name = "Ammonia crystal"
	min_temp = 200
	max_temp = 240
	energy_release = 950000
	requirements = list(/datum/gas/hydrogen = 50, /datum/gas/nitrogen = 40)
	products = list(/obj/item/stack/ammonia_crystals = 2)

/datum/gas_recipe/crystallizer/tesla
	id = "tesla"
	name = "Tesla generator"
	min_temp = 8000
	max_temp = 12000
	energy_release = -350000
	dangerous = TRUE
	requirements = list(/datum/gas/stimulum = 500, /datum/gas/freon = 500, /datum/gas/nitryl = 800)
	products = list(/obj/machinery/the_singularitygen/tesla = 1)

/datum/gas_recipe/crystallizer/supermatter_silver
	id = "supermatter"
	name = "Supermatter silver"
	min_temp = 100000
	max_temp = 200000
	energy_release = -250000
	dangerous = TRUE
	requirements = list(/datum/gas/bz = 100, /datum/gas/hypernoblium = 125, /datum/gas/tritium = 250, /datum/gas/plasma = 750)
	products = list(/obj/item/nuke_core/supermatter_sliver = 1)

/datum/gas_recipe/crystallizer/n2o_crystal
	id = "n2o_crystal"
	name = "Nitrous oxide crystal"
	min_temp = 50
	max_temp = 350
	energy_release = 3500000
	requirements = list(/datum/gas/nitrous_oxide = 100, /datum/gas/bz = 5)
	products = list(/obj/item/grenade/gas_crystal/nitrous_oxide_crystal = 1)

/datum/gas_recipe/crystallizer/diamond
	id = "diamond"
	name = "Diamond"
	min_temp = 10000
	max_temp = 30000
	energy_release = -9500000
	requirements = list(/datum/gas/carbon_dioxide = 10000)
	products = list(/obj/item/stack/sheet/mineral/diamond = 1)

/datum/gas_recipe/crystallizer/uranium
	id = "uranium"
	name = "Uranium"
	min_temp = 1000
	max_temp = 5000
	energy_release = -2500000
	requirements = list(/datum/gas/tritium = 200, /datum/gas/hypernoblium = 50)
	products = list(/obj/item/stack/sheet/mineral/uranium = 1)

/datum/gas_recipe/crystallizer/plasma_sheet
	id = "plasma_sheet"
	name = "Plasma sheet"
	min_temp = 10
	max_temp = 20
	energy_release = 3500000
	requirements = list(/datum/gas/plasma = 450)
	products = list(/obj/item/stack/sheet/mineral/plasma = 1)

/datum/gas_recipe/crystallizer/crystal_cell
	id = "crystal_cell"
	name = "Crystal Cell"
	min_temp = 50
	max_temp = 90
	energy_release = -800000
	requirements = list(/datum/gas/plasma = 800, /datum/gas/healium = 100, /datum/gas/bz = 50)
	products = list(/obj/item/stock_parts/cell/crystal_cell = 1)

/datum/gas_recipe/crystallizer/zaukerite
	id = "zaukerite"
	name = "Zaukerite sheet"
	min_temp = 5
	max_temp = 20
	energy_release = 2900000
	requirements = list(/datum/gas/hypernoblium = 5, /datum/gas/zauker = 10, /datum/gas/bz = 7.5)
	products = list(/obj/item/stack/sheet/mineral/zaukerite = 2)

/datum/gas_recipe/crystallizer/hypernoblium_crystal
	id = "hyper_crystalium"
	name = "Hypernoblium Crystal"
	min_temp = 100000
	max_temp = 200000
	energy_release = 2800000
	requirements = list(/datum/gas/bz = 100, /datum/gas/hypernoblium = 100, /datum/gas/oxygen = 1000)
	products = list(/obj/item/stack/hypernoblium_crystal = 1)
