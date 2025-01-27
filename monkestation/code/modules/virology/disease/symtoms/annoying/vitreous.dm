/datum/symptom/vitreous
	name = "Vitreous resonance"
	desc = "Causes the infected to shake uncontrollably, at the same frequency that is required to break glass."
	stage = 2
	chance = 25
	max_chance = 75
	max_multiplier = 2
	badness = EFFECT_DANGER_ANNOYING
	severity = 2

/datum/symptom/vitreous/activate(mob/living/carbon/human/victim)
	victim.Shake(3, 3, 3 SECONDS)
	if(ishuman(victim))
		addtimer(CALLBACK(src, PROC_REF(shatter), victim), 0.5 SECONDS)

/datum/symptom/vitreous/proc/shatter(mob/living/carbon/human/victim)
	var/obj/item/reagent_containers/glass_to_shatter = victim.get_active_held_item()
	var/obj/item/bodypart/check_arm = victim.get_active_hand()
	if(!glass_to_shatter)
		return
	if (is_type_in_list(glass_to_shatter, list(/obj/item/reagent_containers/cup/glass)))
		to_chat(victim, span_warning("Your [check_arm] resonates with the glass in \the [glass_to_shatter], shattering it to bits!"))
		glass_to_shatter.reagents.expose(victim, TOUCH)
		new/obj/effect/decal/cleanable/generic(get_turf(victim))
		playsound(victim, 'sound/effects/glassbr1.ogg', 25, 1)
		spawn(1 SECONDS)
			if (victim && check_arm)
				if (prob(50 * multiplier))
					to_chat(victim, span_notice("Your [check_arm] deresonates, healing completely!"))
					check_arm.heal_damage(1000) // full heal
				else
					to_chat(victim, span_warning("Your [check_arm] deresonates, sustaining burns!"))
					check_arm.take_damage(15 * multiplier, BRUTE)
		qdel(glass_to_shatter)
	else if (prob(1))
		to_chat(victim, span_notice("Your [check_arm] aches for the cold, smooth feel of container-grade glass..."))
