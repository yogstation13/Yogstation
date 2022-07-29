/datum/symptom/necroseed
	name = "Necropolis Seed"
	desc = "An infantile form of the root of Lavaland's tendrils. Forms a symbiotic bond with the host, making them stronger and hardier, at the cost of speed. Should the disease be cured, the host will be severely weakened."
	stealth = 0
	resistance = 3
	stage_speed = -10
	transmittable = -3
	level = 9
	base_message_chance = 5
	severity = 0
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/tendrils = FALSE
	var/chest = FALSE
	var/fireproof = FALSE
	var/fullpower = FALSE
	threshold_descs = list(
	"Resistance 15" = "The area near the host roils with paralyzing tendrils.",
	"Resistance 20" = "Host becomes immune to heat, ash, and lava.",
	)
	var/list/cached_tentacle_turfs
	var/turf/last_location
	var/tentacle_recheck_cooldown = 100

/datum/symptom/necroseed/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalResistance() >= 15)
		tendrils = TRUE
	if(A.totalResistance() >= 20)
		fireproof = TRUE

/datum/symptom/necroseed/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(2)
			if(tendrils)
				tendril(A)
			if(prob(base_message_chance))
				to_chat(M, span_notice("Your skin feels scaly"))
		if(3, 4)
			if(tendrils)
				tendril(A)
			if(prob(base_message_chance))
				to_chat(M, span_notice("[pick("Your skin is hard.", "You feel stronger.", "You feel powerful.")]"))
		if(5)
			if(tendrils)
				tendril(A)
			if(!(fullpower) && ishuman(M))							//if we haven't gotten the buff yet
				var/mob/living/carbon/human/H = M
				fullpower = TRUE
				H.physiology.punchdamagehigh_bonus += 4
				H.physiology.punchdamagelow_bonus += 4
				H.physiology.punchstunthreshold_bonus += 1				//Makes standard punches 5-14 with higher stun chance (1-10, stun on 10 -> 5-14, stun on 11-14)
				H.physiology.brute_mod *= 0.6			
				H.physiology.burn_mod *= 0.6
				H.physiology.heat_mod *= 0.6
				H.add_movespeed_modifier(MOVESPEED_ID_NECRO_VIRUS_SLOWDOWN, update=TRUE, priority=100, multiplicative_slowdown=0.5)
				ADD_TRAIT(H, TRAIT_PIERCEIMMUNE, DISEASE_TRAIT)
				if(fireproof)
					ADD_TRAIT(H, TRAIT_RESISTHEAT, DISEASE_TRAIT)
					ADD_TRAIT(H, TRAIT_RESISTHIGHPRESSURE, DISEASE_TRAIT)
					M.weather_immunities |= "ash"
					M.weather_immunities |= "lava"
		else
			if(prob(base_message_chance))
				to_chat(M, span_notice("[pick("Your skin has become a hardened carapace", "Your strength is superhuman.", "You feel invincible.")]"))
			if(tendrils)
				tendril(A)
	return

/datum/symptom/necroseed/proc/tendril(datum/disease/advance/A)
	. = A.affected_mob
	var/mob/living/loc = A.affected_mob.loc
	if(isturf(loc))
		if(!LAZYLEN(cached_tentacle_turfs) || loc != last_location || tentacle_recheck_cooldown <= world.time)
			LAZYCLEARLIST(cached_tentacle_turfs)
			last_location = loc
			tentacle_recheck_cooldown = world.time + initial(tentacle_recheck_cooldown)
			for(var/turf/open/T in orange(4, loc))
				LAZYADD(cached_tentacle_turfs, T)
		for(var/t in cached_tentacle_turfs)
			if(isopenturf(t))
				if(prob(10))
					new /obj/effect/temp_visual/goliath_tentacle(t, .)
			else
				cached_tentacle_turfs -= t

/datum/symptom/necroseed/End(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/M = A.affected_mob
	if(fullpower && ishuman(M))							//undo the changes if we got the buff
		var/mob/living/carbon/human/H = M
		to_chat(M, span_danger("You feel weakened as the necropolis' blessing leaves your body."))
		H.remove_movespeed_modifier(MOVESPEED_ID_NECRO_VIRUS_SLOWDOWN)
		H.physiology.punchdamagehigh_bonus -= 4
		H.physiology.punchdamagelow_bonus -= 4
		H.physiology.punchstunthreshold_bonus -= 1	
		H.physiology.brute_mod /= 0.6
		H.physiology.burn_mod /= 0.6
		H.physiology.heat_mod /= 0.6
		REMOVE_TRAIT(H, TRAIT_PIERCEIMMUNE, DISEASE_TRAIT)
		if(fireproof)
			REMOVE_TRAIT(H, TRAIT_RESISTHIGHPRESSURE, DISEASE_TRAIT)
			REMOVE_TRAIT(H, TRAIT_RESISTHEAT, DISEASE_TRAIT)
			H.weather_immunities -= "ash"
			H.weather_immunities -= "lava"

