/datum/blood_type
	/// Displayed name of the blood type.
	var/name = "?"
	/// Shown color of the blood type.
	var/color = COLOR_BLOOD
	/// Blood types that are safe to use with people that have this blood type.
	var/compatible_types = list()

/datum/blood_type/New()
	. = ..()
	compatible_types |= typesof(/datum/blood_type/universal)

/datum/blood_type/universal
	name = "U"

/datum/blood_type/universal/New()
	. = ..()
	compatible_types |= subtypesof(/datum/blood_type)

////////////////////////////////////////////////////////////////
//--------------------Normal human bloodtypes-----------------//
////////////////////////////////////////////////////////////////
/datum/blood_type/a_minus
	name = "A-"
	compatible_types = list(/datum/blood_type/a_minus, /datum/blood_type/o_minus)

/datum/blood_type/a_plus
	name = "A+"
	compatible_types = list(/datum/blood_type/a_minus, /datum/blood_type/a_plus, /datum/blood_type/o_minus, /datum/blood_type/o_plus)

/datum/blood_type/b_minus
	name = "B-"
	compatible_types = list(/datum/blood_type/b_minus, /datum/blood_type/o_minus)

/datum/blood_type/b_plus
	name = "B+"
	compatible_types = list(/datum/blood_type/b_minus, /datum/blood_type/b_plus, /datum/blood_type/o_minus, /datum/blood_type/o_plus)

/datum/blood_type/ab_minus
	name = "AB-"
	compatible_types = list(/datum/blood_type/b_minus, /datum/blood_type/a_minus, /datum/blood_type/ab_minus, /datum/blood_type/o_minus)

/datum/blood_type/ab_plus
	name = "AB+"
	compatible_types = list(/datum/blood_type/b_minus, /datum/blood_type/a_minus, /datum/blood_type/ab_minus, /datum/blood_type/o_minus, /datum/blood_type/b_plus, /datum/blood_type/a_plus, /datum/blood_type/ab_plus, /datum/blood_type/o_plus)

/datum/blood_type/o_minus
	name = "O-"
	compatible_types = list(/datum/blood_type/o_minus)

/datum/blood_type/o_plus
	name = "O+"
	compatible_types = list(/datum/blood_type/o_minus, /datum/blood_type/o_plus)

////////////////////////////////////////////////////////////////
//--------------------Other species bloodtypes----------------//
////////////////////////////////////////////////////////////////
/datum/blood_type/lizard
	name = "L"
	color = LIGHT_COLOR_BLUEGREEN
	compatible_types = list(/datum/blood_type/lizard)


/datum/blood_type/universal/synthetic //Blood for preterni
	name = "Synthetic"
	color = LIGHT_COLOR_ELECTRIC_CYAN

/*
	The species have exotic blood, but with how dna is stored, they still need a blood type
	They're literally ONLY used to colour bloodsplats as far as I know (maybe it will be possible to podclone from bloodsplats)
*/
/datum/blood_type/xenomorph //for xenomorph gib dna and polysmorph bloodsplats
	name = "X"
	color = "#96bb00"
	compatible_types = list(/datum/blood_type/xenomorph)

/datum/blood_type/electricity
	name = "E"
	color = "#cbee63" //slightly more yellowy than regular liquid electricity because of the grey scale image used
	compatible_types = list(/datum/blood_type/electricity)

////////////////////////////////////////////////////////////////
//-----------------Wonky simplemob(?) bloodtypes--------------//
////////////////////////////////////////////////////////////////
/datum/blood_type/animal //for simplemob gib dna
	name = "Y-"
	compatible_types = list(/datum/blood_type/animal)

/datum/blood_type/gorilla
	name = "G"
	compatible_types = list(/datum/blood_type/gorilla)
