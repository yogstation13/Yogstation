/datum/action/cooldown/spell/aoe/shriek //Stuns anyone in view range.
	name = "Screech"
	desc = "Releases a terrifying screech, freezing those who hear."
	panel = "Abomination"

	sound = 'yogstation/sound/effects/creepyshriek.ogg'
	cooldown_time = 10 SECONDS
	spell_requirements = NONE

/datum/action/cooldown/spell/aoe/shriek/cast_on_thing_in_aoe(atom/victim, atom/user)
	if(!istype(user, /mob/living/simple_animal/hostile/abomination))
		return
	user.visible_message(span_warning("<b>[usr] unhinges their jaw and releases a horrifying shriek!"))
	if(!isturf(victim))
		return
	var/turf/T = victim
	for(var/mob/living/carbon/M in T.contents)
		if(M == user) //No message for the user, of course
			continue
		var/mob/living/carbon/human/H = M
		var/distance = max(1,get_dist(usr,H))
		if(istype(H.ears, /obj/item/clothing/ears/earmuffs))//only the true power of earmuffs may block the power of the screech
			continue
		to_chat(M, span_userdanger("You freeze in terror, your blood turning cold from the sound of the scream!"))
		M.Stun(max(7/distance, 1))
	for(var/mob/living/silicon/M in T.contents)
		M.Paralyze(1 SECONDS)
	for(var/obj/machinery/light/L in range(7, user))
		L.set_light(0)

	return ..()
