/datum/job/bartender
	title = "Bartender"
	flag = BARTENDER
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	exp_type_department = EXP_TYPE_SERVICE // This is so the jobs menu can work properly

	alt_titles = list("Barkeep", "Tapster", "Barista", "Mixologist")

	outfit = /datum/outfit/job/bartender

	added_access = list(ACCESS_HYDROPONICS, ACCESS_KITCHEN, ACCESS_MORGUE)
	base_access = list(ACCESS_BAR, ACCESS_MINERAL_STOREROOM, ACCESS_WEAPONS)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	display_order = JOB_DISPLAY_ORDER_BARTENDER
	minimal_character_age = 21 //I shouldn't have to explain this one

	changed_maps = list("OmegaStation")

/datum/job/bartender/proc/OmegaStationChanges()
	added_access = list()
	base_access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_WEAPONS)

/datum/outfit/job/bartender
	name = "Bartender"
	jobtype = /datum/job/bartender

	pda_type = /obj/item/modular_computer/tablet/pda/preset/basic/fountainpen

	glasses = /obj/item/clothing/glasses/sunglasses/reagent
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/bartender
	uniform_skirt = /obj/item/clothing/under/rank/bartender/skirt
	suit = /obj/item/clothing/suit/armor/vest
	backpack_contents = list(/obj/item/storage/box/beanbag=1)
	shoes = /obj/item/clothing/shoes/laceup
	
/datum/outfit/job/bartender/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()

	var/obj/item/card/id/W = H.wear_id
	if(H.age < AGE_MINOR)
		W.registered_age = AGE_MINOR
		to_chat(H, span_notice("You're not technically old enough to access or serve alcohol, but your ID has been discreetly modified to display your age as [AGE_MINOR]. Try to keep that a secret!"))
