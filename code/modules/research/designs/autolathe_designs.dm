///////////////////////////////////
//////////Autolathe Designs ///////
///////////////////////////////////

/datum/design/airlock_board
	name = "Airlock Electronics"
	id = "airlock_board"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 50)
	build_path = /obj/item/electronics/airlock
	category = list("initial", "Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/metal
	name = "Metal"
	id = "metal"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/metal
	category = list("initial","Construction")
	maxstack = 50

/datum/design/glass
	name = "Glass"
	id = "glass"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/glass
	category = list("initial","Construction")
	maxstack = 50

/datum/design/rglass
	name = "Reinforced Glass"
	id = "rglass"
	build_type = AUTOLATHE | SMELTER | PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/rglass
	category = list("initial","Construction","Stock Parts")
	maxstack = 50

/datum/design/rods
	name = "Metal Rod"
	id = "rods"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/stack/rods
	category = list("initial","Construction")
	maxstack = 50
