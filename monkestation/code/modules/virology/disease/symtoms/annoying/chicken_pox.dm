/datum/symptom/chickenpox
	name = "Chicken Pox"
	desc = "Causes the infected to begin coughing up eggs of the poultry variety."
	stage = 3
	badness = EFFECT_DANGER_ANNOYING
	var/eggspawn = /obj/item/food/egg

/datum/symptom/chickenpox/activate(mob/living/carbon/mob)
	if (prob(30))
		mob.say(pick("BAWWWK!", "BAAAWWK!", "CLUCK!", "CLUUUCK!", "BAAAAWWWK!"))
	if (prob(15))
		mob.emote("me",1,"vomits up a chicken egg!")
		playsound(mob.loc, 'sound/effects/splat.ogg', 50, 1)
		new eggspawn(get_turf(mob))
