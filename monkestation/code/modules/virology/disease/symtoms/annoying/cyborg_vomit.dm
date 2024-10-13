/datum/symptom/cyborg_vomit
	name = "Oleum Syndrome"
	desc = "Causes the infected to internally synthesize oil and other inorganic material."
	stage = 2
	badness = EFFECT_DANGER_ANNOYING

/datum/symptom/cyborg_vomit/activate(mob/living/mob)
	if(HAS_TRAIT(mob, TRAIT_NOHUNGER) || !mob.has_mouth())
		return
	if(prob(90))		//90% chance for just oil
		mob.visible_message(span_danger("[mob.name] vomits up some oil!"))
		mob.adjustToxLoss(-3)
		var/obj/effect/decal/cleanable/oil/oil = new /obj/effect/decal/cleanable/oil(get_turf(mob))
		playsound(oil, 'sound/effects/splat.ogg', 50, 1)
		mob.Stun(0.5 SECONDS)
	else				//10% chance for a random bot!
		to_chat(mob, span_danger("You feel like something's about to burst out of you!"))
		sleep(100)
		var/list/possible_bots = list(
			/mob/living/simple_animal/bot/cleanbot,
			/mob/living/basic/bot/medbot,
			/mob/living/simple_animal/bot/secbot,
			/mob/living/simple_animal/bot/floorbot,
			/mob/living/simple_animal/bot/buttbot
		)
		var/chosen_bot = pick(possible_bots)
		var/mob/living/simple_animal/bot/newbot = new chosen_bot(get_turf(mob))
		new /obj/effect/decal/cleanable/blood(get_turf(mob))
		mob.visible_message("<span class ='danger'>A [newbot.name] bursts out of [mob.name]'s mouth!</span>")
		playsound(newbot, 'sound/effects/splat.ogg', 50, 1)
		mob.emote("scream")
		mob.adjustBruteLoss(15)
		mob.Stun(1 SECONDS)
