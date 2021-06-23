/datum/design/nanite_heart
	name = "Nanite Heart"
	desc = "A heart made of nanites that improves their function in the body."
	id = "nanite_heart"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 80
	materials = list(/datum/material/iron = 200, /datum/material/glass = 500, /datum/material/silver=300, /datum/material/gold=300)
	build_path = /obj/item/organ/heart/nanite
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/rollerstasis
	name = "Stasis Roller Bed"
	desc = "A collapsed stasis roller bed that can be carried around to help stabilize critical patients."
	id = "rollerstasis"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=5000, /datum/material/glass = 2000, /datum/material/gold=1000, /datum/material/diamond = 500)
	build_path = /obj/item/roller/stasis
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE
