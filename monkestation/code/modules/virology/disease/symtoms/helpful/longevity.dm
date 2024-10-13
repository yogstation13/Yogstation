/datum/symptom/immortal
	name = "Longevity Syndrome"
	desc = "Grants functional immortality to the infected so long as the symptom is active. Heals broken bones and healing external damage. Creates a backlash if cured."
	stage = 4
	badness = EFFECT_DANGER_HELPFUL
	var/total_healed = 0

/datum/symptom/immortal/activate(mob/living/carbon/mob)
	if(ishuman(mob))
		for(var/datum/wound/wound as anything in mob.all_wounds)
			to_chat(mob, span_notice("You feel the [wound] heal itself."))
			wound.remove_wound()
			break

	var/heal_amt = 5 * multiplier
	var/current_health = mob.getBruteLoss()
	if(current_health >= heal_amt)
		total_healed += heal_amt * 0.2
	else
		total_healed += (heal_amt - current_health) * 0.2
	mob.heal_overall_damage(brute = heal_amt, burn = heal_amt)
	mob.adjustToxLoss(-heal_amt)

/datum/symptom/immortal/deactivate(mob/living/carbon/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/person = mob
		to_chat(person, span_warning("You suddenly feel hurt and old..."))
		person.age += 4 * multiplier * total_healed
	if(total_healed > 0)
		mob.take_overall_damage(brute = (total_healed / 2), burn = (total_healed / 2))
