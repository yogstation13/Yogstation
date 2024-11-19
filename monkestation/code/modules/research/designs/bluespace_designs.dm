/datum/design/advanced_gps
	name = "Advanced GPS Device"
	desc = /obj/item/gps/advanced::desc
	id = "advanced_gps"
	build_type = PROTOLATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 5,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/bluespace = SMALL_MATERIAL_AMOUNT * 1.5,
	)
	build_path = /obj/item/gps/advanced
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_BLUESPACE
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO
	autolathe_exportable = FALSE
