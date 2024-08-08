/datum/job/tourist
	title = "Tourist"
	description = "Enjoy the new sights and scenery on board the station, free of any woes that might assail you."
	orbit_icon = "camera-retro"
	faction = "Station"
	total_positions = -1
	spawn_positions = -1
	supervisors = "the head of personnel"
	added_access = list()
	base_access = list()
	alt_titles = list("Visitor", "Traveler", "Siteseer")
	outfit = /datum/outfit/job/tourist
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CIV
	display_order = JOB_DISPLAY_ORDER_TOURIST
	minimal_character_age = 18 //Gotta go explore the galaxy and see the stuff

	mail_goodies = list(
		/obj/effect/spawner/lootdrop/plushies = 15,
		/obj/item/fakeartefact = 5,
		/obj/item/binoculars = 5,
		/obj/item/storage/photo_album = 4,
		/obj/item/clothing/glasses/sunglasses = 1
  )

	departments_list = list(
		/datum/job_department/service,
	)

	smells_like = "sunscreen"

	//we use this in an inverse way
	exp_requirements = 3000 //50 hours of playing lock the job off
	exp_type = EXP_TYPE_CREW

/**
 * Yogs change:
 * Tourist is now exclusively for new players and donators
 * it forces quiet mode upon spawning
 */	
/datum/job/tourist/after_spawn(mob/living/spawned, mob/M, latejoin = FALSE)
	. = ..()
	if(spawned.mind)
		spawned.mind.quiet_round = TRUE //always quiet round

/datum/job/tourist/required_playtime_remaining(client/C)
	if(!C)
		return 0
	if(!CONFIG_GET(flag/use_exp_tracking))
		return 0
	if(!SSdbcore.Connect())
		return 0
	if(!exp_requirements || !exp_type)
		return 0
	if(!job_is_xp_locked(src.title))
		return 0
	if(CONFIG_GET(flag/use_exp_restrictions_admin_bypass) && check_rights_for(C,R_ADMIN))
		return 0
	if(is_donator(C)) //donators can always pick tourist
		return 0
	var/isexempt = C.prefs.db_flags & DB_FLAG_EXEMPT
	if(isexempt)
		return 0
	var/my_exp = C.calc_exp_type(get_exp_req_type())
	var/job_requirement = get_exp_req_amount()
	if(my_exp >= job_requirement)
		return 0
	else
		return max(0, my_exp - job_requirement) //this is flipped around so it eventually locks the player off from picking tourist

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
