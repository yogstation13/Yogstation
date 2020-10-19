/datum/design/nanite_heart
	name = "Nanite Heart"
	desc = "A heart made of nanites that improves their function in the body."
	id = "nanite_heart"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 80
	materials = list(MAT_METAL = 200, MAT_GLASS = 500, MAT_SILVER=300, MAT_GOLD=300)
	build_path = /obj/item/organ/heart/nanite
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE