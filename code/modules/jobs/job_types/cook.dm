/datum/job/cook
	title = "Cook"
	description = "Serve food, cook meat, keep the crew fed."
	orbit_icon = "utensils"
	department_head = list("Head of Personnel")
	faction = "Station"
	total_positions = 2
	spawn_positions = 1
	supervisors = "the head of personnel"
	var/cooks = 0 //Counts cooks amount

	outfit = /datum/outfit/job/cook

	alt_titles = list("Chef", "Hash Slinger", "Sous-chef", "Culinary Artist", "Culinarian")

	added_access = list(ACCESS_HYDROPONICS, ACCESS_BAR)
	base_access = list(ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_MINERAL_STOREROOM, ACCESS_SERVHALL)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_COOK
	minimal_character_age = 18 //My guy they just a cook

	departments_list = list(
		/datum/job_department/service,
	)

	mail_goodies = list(
		///obj/item/storage/box/ingredients/random = 80,
		/obj/item/reagent_containers/glass/bottle/caramel = 20,
		/obj/item/reagent_containers/food/condiment/flour = 20,
		/obj/item/reagent_containers/food/condiment/rice = 20,
		/obj/item/reagent_containers/food/condiment/enzyme = 15,
		/obj/item/reagent_containers/food/condiment/soymilk = 15,
		/obj/item/kitchen/knife/butcher = 2,
		/obj/item/taster = 2,
		/obj/item/sharpener = 1
	)
	
	minimal_lightup_areas = list(/area/crew_quarters/kitchen, /area/medical/morgue)
	lightup_areas = list(/area/hydroponics)

	smells_like = "delicious food"

/datum/outfit/job/cook
	name = "Cook"
	jobtype = /datum/job/cook

	pda_type = /obj/item/modular_computer/tablet/pda/preset/cook

	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/chef
	uniform_skirt = /obj/item/clothing/under/rank/chef/skirt
	suit = /obj/item/clothing/suit/toggle/chef
	head = /obj/item/clothing/head/chefhat
	mask = /obj/item/clothing/mask/fakemoustache/italian
	backpack_contents = list(
		/obj/item/sharpener = 1,
		/obj/item/book/granter/crafting_recipe/cooking_sweets_101 = 1,
		)

/datum/outfit/job/cook/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/datum/job/cook/J = SSjob.GetJobType(jobtype)
	if(J) // Fix for runtime caused by invalid job being passed
		if(J.cooks>0)//Cooks
			suit = /obj/item/clothing/suit/apron/chef
			head = /obj/item/clothing/head/soft/mime
		if(!visualsOnly)
			J.cooks++

/datum/outfit/job/cook/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	var/list/possible_boxes = subtypesof(/obj/item/storage/box/ingredients)
	var/chosen_box = pick(possible_boxes)
	var/obj/item/storage/box/I = new chosen_box(src)
	H.equip_to_slot_or_del(I,ITEM_SLOT_BACKPACK)
	var/datum/martial_art/cqc/under_siege/justacook = new
	justacook.teach(H)

/datum/outfit/job/cook/get_types_to_preload()
	. = ..()
	. += /obj/item/clothing/suit/apron/chef
	. += /obj/item/clothing/head/soft/mime
