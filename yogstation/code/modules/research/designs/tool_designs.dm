/datum/design/surgical_drapes
	name = "Surgical Drapes"
	id = "surgical_drapes"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 2500)
	build_path = /obj/item/surgical_drapes
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/tool_switcher
	name = "Programmable Tool Switcher"
	desc = "An advanced programmable device capable of quickly swapping to the correct tool for performing repetitive tasks quickly."
	id = "tool_switcher"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/diamond = 1500, /datum/material/uranium = 200)
	build_path = /obj/item/storage/belt/tool_switcher
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/tricorder
	name = "Tricorder"
	desc = "A multifunction handheld device useful for data sensing, analysis, and recording."
	id = "tricorder"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=500,/datum/material/silver=300,/datum/material/gold=300)
	build_path = /obj/item/multitool/tricorder
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING