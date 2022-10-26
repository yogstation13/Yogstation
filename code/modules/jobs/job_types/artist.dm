/datum/job/artist
	title = "Artist"
	flag = ARTIST
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"

	outfit = /datum/outfit/job/artist
	alt_titles = list("Painter", "Composer", "Artisan")
	added_access = list()
	base_access = list()
	paycheck = PAYCHECK_ASSISTANT
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_ARTIST
	minimal_character_age = 18 //Young folks can be crazy crazy artists, something talented that can be self-taught feasibly

/datum/outfit/job/artist
	name = "Artist"
	jobtype = /datum/job/artist

	pda_type = /obj/item/modular_computer/tablet/pda/preset/basic
	
	head = /obj/item/clothing/head/frenchberet
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/artist
	uniform_skirt = /obj/item/clothing/under/rank/artist/skirt
	gloves = /obj/item/clothing/gloves/fingerless
	neck = /obj/item/clothing/neck/artist
	l_pocket = /obj/item/laser_pointer
	backpack_contents = list(
		/obj/item/stack/cable_coil/random/thirty = 1,
		/obj/item/toy/crayon/spraycan = 1,
		/obj/item/storage/crayons = 1,
		/obj/item/camera = 1
	)
