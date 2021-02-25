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
				to_chat(M, "<span class='notice'>Your skin feels scaly</span>")
		if(3, 4)
			if(tendrils)
				tendril(A)
			if(prob(base_message_chance))
				to_chat(M, "<span class='notice'>[pick("Your skin is hard.", "You feel stronger.", "You feel powerful.")]</span>")
		if(5)
			if(tendrils)
				tendril(A)
			M.dna.species.punchdamagelow = 5
			M.dna.species.punchdamagehigh = 15
			M.dna.species.punchstunthreshold = 11
			M.dna.species.brutemod = 0.6
			M.dna.species.burnmod = 0.6
			M.dna.species.heatmod = 0.6
			M.add_movespeed_modifier(MOVESPEED_ID_NECRO_VIRUS_SLOWDOWN, update=TRUE, priority=100, multiplicative_slowdown=0.5)
			ADD_TRAIT(M, TRAIT_PIERCEIMMUNE, DISEASE_TRAIT)
			if(fireproof)
				ADD_TRAIT(M, TRAIT_RESISTHEAT, DISEASE_TRAIT)
				ADD_TRAIT(M, TRAIT_RESISTHIGHPRESSURE, DISEASE_TRAIT)
				M.weather_immunities |= "ash"
				M.weather_immunities |= "lava"
		else
			if(prob(base_message_chance))
				to_chat(M, "<span class='notice'>[pick("Your skin has become a hardened carapace", "Your strength is superhuman.", "You feel invincible.")]</span>")
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
	to_chat(M, "<span class='danger'>You feel weakened as the necropolis' blessing leaves your body.</span>")
	M.remove_movespeed_modifier(MOVESPEED_ID_NECRO_VIRUS_SLOWDOWN)
	M.dna.species.punchdamagelow = initial(M.dna.species.punchdamagelow)
	M.dna.species.punchdamagehigh = initial(M.dna.species.punchdamagehigh)
	M.dna.species.punchstunthreshold = initial(M.dna.species.punchstunthreshold)
	M.dna.species.brutemod /= 0.6
	M.dna.species.burnmod /= 0.6
	M.dna.species.heatmod /= 0.6
	REMOVE_TRAIT(M, TRAIT_PIERCEIMMUNE, DISEASE_TRAIT)
	if(fireproof)
		REMOVE_TRAIT(M, TRAIT_RESISTHIGHPRESSURE, DISEASE_TRAIT)
		REMOVE_TRAIT(M, TRAIT_RESISTHEAT, DISEASE_TRAIT)
		M.weather_immunities -= "ash"
		M.weather_immunities -= "lava"

