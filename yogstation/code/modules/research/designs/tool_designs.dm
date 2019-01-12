/datum/design/surgical_drapes
	name = "Surgical Drapes"
	id = "surgical_drapes"
	build_type = PROTOLATHE
	materials = list(MAT_PLASTIC = 2500)
	build_path = /obj/item/surgical_drapes
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/tool_switcher
	name = "Programmable Tool Switcher"
	desc = "An advanced programmable device capable of quickly swapping to the correct tool for performing repetitive tasks quickly."
	id = "tool_switcher"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_DIAMOND = 1500, MAT_URANIUM = 200)
	build_path = /obj/item/storage/belt/tool_switcher
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_MEDICAL
