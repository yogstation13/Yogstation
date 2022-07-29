/datum/job/curator
	title = "Curator"
	flag = CURATOR
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"

	outfit = /datum/outfit/job/curator

	alt_titles = list("Librarian", "Journalist", "Archivist")

	added_access = list()
	base_access = list(ACCESS_LIBRARY, ACCESS_CONSTRUCTION, ACCESS_MINING_STATION)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_CURATOR
	minimal_character_age = 18 //Don't need to be some aged-ass fellow to know how to care for things, possessions could easily have come from parents and the like. Bloodsucker knowledge is another thing, though that's likely mostly consulted by the book

/datum/outfit/job/curator
	name = "Curator"
	jobtype = /datum/job/curator

	pda_type = /obj/item/pda/curator

	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/curator
	uniform_skirt = /obj/item/clothing/under/rank/curator/skirt
	l_hand = /obj/item/storage/bag/books
	r_pocket = /obj/item/key/displaycase
	l_pocket = /obj/item/laser_pointer
	accessory = /obj/item/clothing/accessory/pocketprotector/full
	backpack_contents = list(
		/obj/item/choice_beacon/hero = 1,
		/obj/item/soapstone = 1,
		/obj/item/barcodescanner = 1
	)

/datum/outfit/job/curator/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	H.grant_all_languages(TRUE, TRUE, TRUE, LANGUAGE_CURATOR)
