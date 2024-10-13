/datum/symptom/bee_vomit
	name = "Melisso-Emeto Syndrome"
	desc = "Converts the lungs of the infected into a bee-hive."
	encyclopedia = "Giving the infected a steady drip of honey in exchange of coughing up a bee every so often. The higher the symptom strength, the more honey is generated, and the more bees will be coughed up and more often as well. While Honey is a great healing reagent, it is also high on nutrients. Expect to become fat quickly.."
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	max_multiplier = 4

/datum/symptom/bee_vomit/activate(mob/living/mob)
	if(!ismouse(mob))
		if ((mob.reagents.get_reagent_amount(/datum/reagent/consumable/sugar) < 5 + multiplier * 0.5) && prob(multiplier * 8)) //honey quickly decays into sugar
			mob.reagents.add_reagent(/datum/reagent/consumable/honey, multiplier)
			if(prob(25))
				to_chat(mob, span_notice("You taste someting sweet"))

	if(prob(20 + (20 * multiplier)))
		to_chat(mob, span_warning("You feel a buzzing in your throat"))

		addtimer(CALLBACK(src, PROC_REF(spawn_bee), mob), 5 SECONDS)

/datum/symptom/bee_vomit/proc/kill_bee(mob/living/basic/bee/bee)
	bee.visible_message(span_warning("The bee falls apart!"), span_warning("You fall apart"))
	bee.death()
	sleep(0.1 SECONDS)
	qdel(bee)

/datum/symptom/bee_vomit/proc/spawn_bee(mob/living/mob)
	var/turf/open/T = get_turf(mob)
	if(prob(40 + 10 * multiplier))
		mob.visible_message(span_warning("[mob] coughs out a bee!"),span_danger("You cough up a bee!"))
		var/bee_type = pick(
			100;/mob/living/basic/bee/friendly,
			10;/mob/living/basic/bee,
			5;/mob/living/basic/bee/toxin,
			)
		var/mob/living/basic/bee/bee = new bee_type(T)
		if(multiplier < 4)
			addtimer(CALLBACK(src, PROC_REF(kill_bee), bee), 20 SECONDS * multiplier)
