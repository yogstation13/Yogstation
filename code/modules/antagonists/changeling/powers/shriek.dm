/datum/action/changeling/resonant_shriek
	name = "Resonant Shriek"
	desc = "Our lungs and vocal cords shift, allowing us to briefly emit a noise that deafens and confuses the weak-minded. Costs 75 chemicals."
	helptext = "Emits a high-frequency sound that confuses and deafens humans, blows out nearby lights and overloads cyborg sensors."
	button_icon_state = "resonant_shriek"
	chemical_cost = 75
	dna_cost = 1
	req_human = 1
	xenoling_available = FALSE

//A flashy ability, good for crowd control and sowing chaos.
/datum/action/changeling/resonant_shriek/sting_action(mob/user)
	..()
	if(user.movement_type & VENTCRAWLING)
		to_chat(user, "<span class='notice'>We must exit the pipes before we can shriek!</span>")
		return FALSE
	for(var/mob/living/M in get_hearers_in_view(4, user))
		if(iscarbon(M))
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(istype(H.ears, /obj/item/clothing/ears/earmuffs))
					continue
			var/mob/living/carbon/C = M
			if(!C.mind || !C.mind.has_antag_datum(/datum/antagonist/changeling))
				C.adjustEarDamage(0, 30)
				C.adjust_confusion(10 SECONDS)
				C.adjust_jitter(10 SECONDS)
			else
				SEND_SOUND(C, sound('sound/effects/screech.ogg'))

		if(issilicon(M))
			SEND_SOUND(M, sound('sound/weapons/flash.ogg'))
			M.Paralyze(rand(100,200))

	for(var/obj/machinery/light/L in range(4, user))
		L.on = 1
		L.break_light_tube()
	return TRUE

/datum/action/changeling/dissonant_shriek
	name = "Dissonant Shriek"
	desc = "We shift our vocal cords to release a high-frequency sound that overloads nearby electronics. Costs 40 chemicals."
	button_icon_state = "dissonant_shriek"
	chemical_cost = 40
	dna_cost = 1
	xenoling_available = FALSE

/datum/action/changeling/dissonant_shriek/sting_action(mob/user)
	..()
	if(user.movement_type & VENTCRAWLING)
		to_chat(user, "<span class='notice'>We must exit the pipes before we can shriek!</span>")
		return FALSE
	for(var/obj/machinery/light/L in range(5, usr))
		L.on = 1
		L.break_light_tube()
	empulse(get_turf(user), EMP_HEAVY, 5, 1)
	return TRUE
