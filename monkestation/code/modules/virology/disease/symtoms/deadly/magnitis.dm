/datum/symptom/magnitis
	name = "Magnitis"
	desc = "This disease disrupts the magnetic field of the body, making it act as if a powerful magnet."
	stage = 4
	badness = EFFECT_DANGER_DEADLY
	chance = 5
	max_chance = 20

/datum/symptom/magnitis/activate(mob/living/carbon/mob)
	if(mob.reagents.has_reagent(/datum/reagent/iron))
		return

	var/intensity = 1 + (count > 10) + (count > 20)
	if (prob(20))
		to_chat(mob, span_warning("You feel a [intensity < 3 ? "slight" : "powerful"] shock course through your body."))
	for(var/obj/thingy in orange(3 * intensity, mob))
		if(!thingy.anchored || thingy.move_resist > MOVE_FORCE_STRONG)
			continue
		var/iter = rand(1, intensity)
		for(var/i in 0 to iter)
			step_towards(thingy, mob)
	for(var/mob/living/silicon/robutt in orange(3 * intensity,mob))
		if(isAI(robutt))
			continue
		var/iter = rand(1, intensity)
		for(var/i in 0 to iter)
			step_towards(robutt, mob)
