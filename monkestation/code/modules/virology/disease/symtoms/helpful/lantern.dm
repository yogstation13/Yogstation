/datum/symptom/lantern
	name = "Lantern Syndrome"
	desc = "Causes the infected to glow."
	stage = 2
	badness = EFFECT_DANGER_HELPFUL
	multiplier = 4
	max_multiplier = 10
	chance = 10
	max_chance = 15
	var/uncolored = 0
	var/flavortext = 0
	var/color = rgb(255, 255, 255)
	var/obj/effect/dummy/lighting_obj/moblight

/datum/symptom/lantern/activate(mob/living/mob)
	if(!moblight)
		moblight = new(mob)
	if(ismouse(mob))
		moblight.set_light_range(multiplier)
		moblight.set_light_power(multiplier / 3)
		moblight.set_light_color(color)
		return
	if(mob.reagents.has_reagent(/datum/reagent/space_cleaner))
		uncolored = 1	//Having spacecleaner in your system when the effect activates will permanently make the color white.
	if(mob.reagents.reagent_list.len == 0 || uncolored == TRUE)
		color = rgb(255, 255, 255)
	else
		color = mix_color_from_reagents(mob.reagents.reagent_list)
	if(!flavortext)
		to_chat(mob, span_notice("You are glowing!"))
		flavortext = 1
	moblight.set_light_range(multiplier)
	moblight.set_light_power(multiplier / 3)
	moblight.set_light_color(color)

/datum/symptom/lantern/deactivate(mob/living/mob)
	QDEL_NULL(moblight)
	to_chat(mob, span_notice("You don't feel as bright."))
	flavortext = 0
