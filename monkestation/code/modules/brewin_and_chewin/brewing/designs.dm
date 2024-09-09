/datum/design/bottling_kit
	name = "Bottling Kit"
	id = "bottling_kit"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass=2000, /datum/material/iron=2000)
	build_path = /obj/item/bottle_kit
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_KITCHEN,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/recipe_card
	name = "Fermentation Recipe Card"
	id = "recipe_card"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron=100)
	build_path = /obj/item/recipe_card
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_KITCHEN,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE
