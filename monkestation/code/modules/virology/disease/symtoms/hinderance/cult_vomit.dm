/datum/symptom/cult_vomit
	name = "Hemoptysis"
	desc = "Causes the infected to cough up blood."
	stage = 2
	badness = EFFECT_DANGER_HINDRANCE
	var/active = 0

/datum/symptom/cult_vomit/activate(mob/living/carbon/mob)
	if(!ishuman(mob) || active)
		return
	if(istype(get_area(mob), /area/station/service/chapel))
		return
	if(IS_CULTIST(mob))
		return

	var/mob/living/carbon/human/victim = mob
	active = 1
	to_chat(victim, span_warning("You feel a burning sensation in your throat."))
	sleep(10 SECONDS)
	to_chat(victim, span_danger("You feel an agonizing pain in your throat!"))
	sleep(10 SECONDS)
	victim.vomit(10, TRUE)
	active = 0
