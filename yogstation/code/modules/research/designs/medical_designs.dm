/////////////////////////////////////////
////////////Medical Tools////////////////
/////////////////////////////////////////
/datum/design/autosurgeon
	name = "Autosurgeon"
	desc = "An autosurgeon, similar to that issued to the Chief Medical Officer at shift start. This one, however, has diamond implements, and as such can host a theoretically infinite number of uses. Use a screwdriver to remove implants."
	id = "autosurgeon"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12000, MAT_GLASS = 6000, MAT_GOLD = 4000, MAT_DIAMOND = 4000)
	build_path = /obj/item/autosurgeon
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/////////////////////////////////////////
////////////Regular Implants/////////////
/////////////////////////////////////////

//Cybernetic organs

/datum/design/cybernetic_lungs_m
	name = "Military Cybernetic Lungs"
	desc = "A pair of military-grade cybernetic lungs."
	id = "cybernetic_lungs_m"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_GOLD = 500, MAT_PLASMA = 500, MAT_URANIUM = 500)
	build_path = /obj/item/organ/lungs/cybernetic/military
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL