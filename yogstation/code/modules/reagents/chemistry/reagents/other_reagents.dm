/datum/reagent/cluwnification
	name = "Cluwne Tears"
	id = "cluwnification"
	description = "Tears from thousands of cluwnes compressed into a dangerous cluwnification virus."
	color = "#535E66" // rgb: 62, 224, 33
	can_synth = FALSE
	taste_description = "something funny"

/datum/reagent/cluwnification/reaction_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/cluwnification(), FALSE, TRUE)

/datum/reagent/unstablemutationtoxin	//For some reason the TG Menace seems to have deleted this one :(
	name = "Unstable Mutation Toxin"	//Also putting this in the hippie tree so that we don't get fucked by TG messing with the reagents again
	id = "unstablemutationtoxin"
	description = "A corruptive toxin... it seems to bubble and froth unpredictably. Are you sure you want to be around this for long?"
	color = "#a872e6" // rgb: 168, 114, 230
	metabolization_rate = INFINITY
	taste_description = "fizzy slime"
	can_synth = TRUE

/datum/reagent/unstablemutationtoxin/on_mob_add(mob/living/carbon/human/H)
	..()
	if(!istype(H))
		return
	H.reagents.add_reagent(pick("stablemutationtoxin","lizardmutationtoxin","flymutationtoxin", "mothmutationtoxin", "podmutationtoxin", "jellymutationtoxin", "golemmutationtoxin", "abductormutationtoxin", "androidmutationtoxin", "skeletonmutationtoxin", "zombiemutationtoxin", "ashmutationtoxin", "shadowmutationtoxin"), 1) //No plasmaman 4u xDDD
	return