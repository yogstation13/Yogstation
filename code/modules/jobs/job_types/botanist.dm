/datum/job/hydro
	title = "Botanist"
	flag = BOTANIST
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#bbe291"

	outfit = /datum/outfit/job/botanist

	alt_titles = list("Ecologist", "Agriculturist", "Botany Greenhorn", "Hydroponicist")

	added_access = list(ACCESS_BAR, ACCESS_KITCHEN)
	base_access = list(ACCESS_HYDROPONICS, ACCESS_MORGUE, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SRV
	display_order = JOB_DISPLAY_ORDER_BOTANIST
	minimal_character_age = 22 //Biological understanding of plants and how to manipulate their DNAs and produces relatively "safely". Not just something that comes to you without education

	changed_maps = list("OmegaStation", "EclipseStation")

/datum/job/hydro/proc/OmegaStationChanges()
	added_access = list()
	base_access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)

/datum/job/hydro/proc/EclipseStationChanges()
	total_positions = 4
	spawn_positions = 3

/datum/outfit/job/botanist
	name = "Botanist"
	jobtype = /datum/job/hydro

	pda_type = /obj/item/modular_computer/tablet/pda/preset/basic

	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/hydroponics
	uniform_skirt = /obj/item/clothing/under/rank/hydroponics/skirt
	suit = /obj/item/clothing/suit/apron
	gloves  =/obj/item/clothing/gloves/botanic_leather
	suit_store = /obj/item/plant_analyzer

	backpack = /obj/item/storage/backpack/botany
	satchel = /obj/item/storage/backpack/satchel/hyd


