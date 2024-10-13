/datum/symptom/teratoma
	name = "Teratoma Syndrome"
	desc = "Causes the infected to oversynthesize stem cells engineered towards organ generation, causing damage to the host's organs in the process. Said generated organs are expelled from the body upon completion."
	stage = 3
	badness = EFFECT_DANGER_HARMFUL
	COOLDOWN_DECLARE(organ_cooldown)

/datum/symptom/teratoma/activate(mob/living/carbon/mob)
	if(!COOLDOWN_FINISHED(src, organ_cooldown))
		return
	COOLDOWN_START(src, organ_cooldown, 2 MINUTES)
	var/fail_counter = 0
	var/not_passed = TRUE
	var/obj/item/organ/spawned_organ
	while(not_passed && fail_counter <= 10)
		var/organ_type = pick(mob?.organs)
		spawned_organ = new organ_type(get_turf(mob))
		if(spawned_organ.status != ORGAN_ORGANIC)
			qdel(spawned_organ)
			fail_counter++
			continue
		not_passed = FALSE

	if(!not_passed)
		if(ismouse(mob))
			var/mob/living/basic/mouse/mouse = mob
			mouse.splat() //tumors are bad for you, tumors equal to your body in size doubley so
		if(ismonkey(mob)) //monkeys are smaller and thus have less space for human-organ sized tumors
			mob.adjustBruteLoss(15)
		if(mob.bruteloss <= 50)
			mob.adjustBruteLoss(5)
		mob.visible_message(span_warning("\A [spawned_organ.name] is extruded from \the [mob]'s body and falls to the ground!"),span_warning("\A [spawned_organ.name] is extruded from your body and falls to the ground!"))
