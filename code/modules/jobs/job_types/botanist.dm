/datum/job/hydro
	title = "Botanist"
	description = "Grow plants for the cook, for medicine, and for recreation."
	flag = BOTANIST
	orbit_icon = "seedling"
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#bbe291"

	outfit = /datum/outfit/job/botanist

	alt_titles = list("Ecologist", "Agriculturist", "Botany Greenhorn", "Hydroponicist", "Gardener")

	added_access = list(ACCESS_BAR, ACCESS_KITCHEN)
	base_access = list(ACCESS_HYDROPONICS, ACCESS_MORGUE, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	display_order = JOB_DISPLAY_ORDER_BOTANIST
	minimal_character_age = 22 //Biological understanding of plants and how to manipulate their DNAs and produces relatively "safely". Not just something that comes to you without education

	departments_list = list(
		/datum/job_department/service,
	)

	mail_goodies = list(
		/obj/item/reagent_containers/glass/bottle/mutagen = 20,
		/obj/item/reagent_containers/glass/bottle/saltpetre = 20,
		/obj/item/reagent_containers/glass/bottle/diethylamine = 20,
		/obj/item/gun/energy/floragun = 10,
		/obj/effect/spawner/lootdrop/seed_rare = 5,// These are strong, rare seeds, so use sparingly.
		/obj/item/reagent_containers/food/snacks/monkeycube/bee = 2
	)

	smells_like = "fertilizer"

	bounty_types = CIV_JOB_GROW

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


