/obj/effect/proc_holder/spell/aoe_turf/abomination/screech //Stuns anyone in view range.
	name = "Screech"
	desc = "Releases a terrifying screech, freezing those who hear."
	panel = "Abomination"
	range = 7
	charge_max = 100
	clothes_req = 0
	sound = 'yogstation/sound/effects/creepyshriek.ogg'

/obj/effect/proc_holder/spell/aoe_turf/abomination/screech/cast(list/targets,mob/user = usr)
	if(!istype(user, /mob/living/simple_animal/hostile/abomination))
		revert_cast()
		return
	playMagSound()
	user.visible_message("<span class='warning'><b>[usr] unhinges their jaw and releases a horrifying shriek!</span>")
	for(var/turf/T in targets)
		for(var/mob/living/carbon/M in T.contents)
			if(M == user) //No message for the user, of course
				continue
			var/mob/living/carbon/human/H = M
			var/distance = max(1,get_dist(usr,H))
			if(istype(H.ears, /obj/item/clothing/ears/earmuffs))//only the true power of earmuffs may block the power of the screech
				continue
			to_chat(M, "<span class='userdanger'>You freeze in terror, your blood turning cold from the sound of the scream!</span>")
			M.Stun(max(7/distance, 1))
		for(var/mob/living/silicon/M in T.contents)
			M.Paralyze(10)
	for(var/obj/machinery/light/L in range(7, user))
		L.set_light(0)