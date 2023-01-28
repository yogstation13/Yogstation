/datum/job/tourist
	title = "Tourist"
	description = "Enjoy the sights and scenery on board of the station."
	flag = TOUR
	orbit_icon = "camera-retro"
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = -1
	spawn_positions = 0
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	added_access = list()
	base_access = list()
	alt_titles = list("Visitor", "Traveler", "Siteseer", "Fisher")
	outfit = /datum/outfit/job/tourist
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CIV
	display_order = JOB_DISPLAY_ORDER_TOURIST
	minimal_character_age = 18 //Gotta go explore the galaxy and see the stuff

	mail_goodies = list(
		/obj/effect/spawner/lootdrop/plushies = 15,
		/obj/item/fakeartefact = 5,
		/obj/item/twohanded/binoculars = 5,
		/obj/item/storage/photo_album = 4,
		/obj/item/clothing/glasses/sunglasses = 1
  )

	smells_like = "sunscreen"

/datum/outfit/job/tourist
	name = "Tourist"
	jobtype = /datum/job/tourist

	uniform = /obj/item/clothing/under/yogs/tourist
	shoes = /obj/item/clothing/shoes/sneakers/black
	ears = /obj/item/radio/headset
	backpack_contents = list(/obj/item/camera_film, /obj/item/stack/spacecash/c20, /obj/item/stack/spacecash/c20, /obj/item/stack/spacecash/c20)
	r_hand =  /obj/item/camera
	l_pocket = /obj/item/camera_film
	r_pocket = /obj/item/camera_film
