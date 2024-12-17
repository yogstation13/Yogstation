/datum/design/bronze
	name = "Bronze"
	id = "bronze"
	build_type = AUTOLATHE
	materials = list(/datum/material/bronze = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/bronze
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS,
	)
	maxstack = 50
