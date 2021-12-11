/datum/job/prisoner
	title = "Prisoner"
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	selection_color = "#dddddd"
	minimal_player_age = 2
	exp_requirements = 30
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_SPECIAL

	outfit = /datum/outfit/job/prisoner

	display_order = JOB_DISPLAY_ORDER_PRISONER

/datum/outfit/job/prisoner
	name = "Prisoner"
	jobtype = /datum/job/prisoner

	id = /obj/item/card/id/prisoner
	uniform = /obj/item/clothing/under/rank/prisoner
	shoes = /obj/item/clothing/shoes/sneakers/orange
	alt_shoes = /obj/item/clothing/shoes/xeno_wraps

	// No cheaty items or other things
	backpack = null
	satchel  = null
	duffelbag = null
	belt = null
	ears = null

/datum/outfit/job/prisoner/post_equip(mob/living/carbon/human/H, visualsOnly)
	return // No bank cards 4 u
