/datum/generecipe
	var/required = "" //it hurts so bad but initial is not compatible with lists
	var/result = null

/proc/get_mixed_mutation(mutation1, mutation2)
	if(!mutation1 || !mutation2)
		return FALSE
	if(mutation1 == mutation2) //this could otherwise be bad
		return FALSE
	for(var/A in GLOB.mutation_recipes)
		if(findtext(A, "[mutation1]") && findtext(A, "[mutation2]"))
			return GLOB.mutation_recipes[A]

/* RECIPES */

/datum/generecipe/mindread
	required = "/datum/mutation/human/antenna; /datum/mutation/human/paranoia"
	result = MINDREAD

/datum/generecipe/shock
	required = "/datum/mutation/human/insulated; /datum/mutation/human/radioactive"
	result = SHOCKTOUCH

/datum/generecipe/shockfar
	required = "/datum/mutation/human/shock; /datum/mutation/human/telekinesis"
	result = SHOCKTOUCHFAR

/datum/generecipe/antiglow
	required = "/datum/mutation/human/glow; /datum/mutation/human/void"
	result = ANTIGLOWY

/datum/generecipe/cerebral
	required = "/datum/mutation/human/insulated; /datum/mutation/human/mindreader"
	result = CEREBRAL
