/*
* Timing adjustments to compensate for 2 move delay (instead of the 1 it was balanced for)
*/

/mob/living/simple_animal/hostile/megafauna/bubblegum/OpenFire()
	anger_modifier = CLAMP(((maxHealth - health)/60),0,20)
	if(charging)
		return
	ranged_cooldown = world.time + 50
	if(!try_bloodattack())
		blood_warp()

	if(health > maxHealth * 0.5)
		if(prob(50 + anger_modifier))
			charge(delay = 8)
			charge(delay = 6) // The FitnessGram Pacer Test is a multistage aerobic capacity test that progressively gets more difficult as it continues.
			charge(delay = 4)
			SetRecoveryTime(15)
		else
			hallucination_charge_around(times = 6, delay = 12 - anger_modifier / 5)
			SetRecoveryTime(10)
	else
		if(prob(50 - anger_modifier))
			hallucination_charge_around(times = 4, delay = 10)
			hallucination_charge_around(times = 4, delay = 9)
			hallucination_charge_around(times = 4, delay = 8)
			SetRecoveryTime(15)
		else
			for(var/i = 1 to 5)
				INVOKE_ASYNC(src, .proc/hallucination_charge_around, 2, 15, 2, 0)
				sleep(5)
			SetRecoveryTime(10)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/bloodsmack(turf/T, handedness)
	if(handedness)
		new /obj/effect/temp_visual/bubblegum_hands/rightsmack(T)
	else
		new /obj/effect/temp_visual/bubblegum_hands/leftsmack(T)
	sleep(6)
	for(var/mob/living/L in T)
		if(!faction_check_mob(L))
			to_chat(L, "<span class='userdanger'>[src] rends you!</span>")
			playsound(T, attack_sound, 100, 1, -1)
			var/limb_to_hit = L.get_bodypart(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
			L.apply_damage(10, BRUTE, limb_to_hit, L.run_armor_check(limb_to_hit, "melee", null, null, armour_penetration))
	sleep(4)
