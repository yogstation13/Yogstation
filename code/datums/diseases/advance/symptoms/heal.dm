/datum/symptom/heal
	name = "Basic Healing (does nothing)" //warning for adminspawn viruses
	desc = "You should not be seeing this."
	stealth = 0
	resistance = 0
	stage_speed = 0
	transmittable = 0
	level = 0 //not obtainable
	base_message_chance = 20 //here used for the overlays
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/passive_message = "" //random message to infected but not actively healing people
	threshold_descs = list(
		"Stage Speed 6" = "Doubles healing speed.",
		"Stealth 4" = "Healing will no longer be visible to onlookers.",
	)

/datum/symptom/heal/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 6) //stronger healing
		power = 2

/datum/symptom/heal/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			var/effectiveness = CanHeal(A)
			if(!effectiveness)
				if(passive_message && prob(2) && passive_message_condition(M))
					to_chat(M, passive_message)
				return
			else
				Heal(M, A, effectiveness)
	return

/datum/symptom/heal/proc/CanHeal(datum/disease/advance/A)
	return power

/datum/symptom/heal/proc/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	return TRUE

/datum/symptom/heal/proc/passive_message_condition(mob/living/M)
	return TRUE


/datum/symptom/heal/starlight
	name = "Starlight Condensation"
	desc = "The virus reacts to direct starlight, producing regenerative chemicals. Works best against toxin-based damage."
	stealth = -1
	resistance = -2
	stage_speed = 0
	transmittable = 1
	level = 6
	passive_message = span_notice("You miss the feeling of starlight on your skin.")
	var/nearspace_penalty = 0.3
	threshold_descs = list(
		"Stage Speed 6" = "Increases healing speed.",
		"Transmission 6" = "Removes penalty for only being close to space.",
	)

/datum/symptom/heal/starlight/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalTransmittable() >= 6)
		nearspace_penalty = 1
	if(A.totalStageSpeed() >= 6)
		power = 2

/datum/symptom/heal/starlight/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	if(istype(get_turf(M), /turf/open/space))
		return power
	else
		for(var/turf/T in view(M, 2))
			if(istype(T, /turf/open/space))
				return power * nearspace_penalty

/datum/symptom/heal/starlight/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = actual_power
	if(M.getToxLoss() && prob(5))
		to_chat(M, span_notice("Your skin tingles as the starlight seems to heal you."))

	M.adjustToxLoss(-(4 * heal_amt)) //most effective on toxins

	var/list/parts = M.get_damaged_bodyparts(1,1, null, BODYPART_ORGANIC)

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len, null, BODYPART_ORGANIC))
			M.update_damage_overlays()
	return 1

/datum/symptom/heal/starlight/passive_message_condition(mob/living/M)
	if(M.getBruteLoss() || M.getFireLoss() || M.getToxLoss())
		return TRUE
	return FALSE

/datum/symptom/heal/chem
	name = "Toxolysis"
	stealth = 0
	resistance = -2
	stage_speed = 2
	transmittable = -2
	level = 7
	var/food_conversion = FALSE
	desc = "The virus rapidly breaks down any foreign chemicals in the bloodstream."
	threshold_descs = list(
		"Resistance 7" = "Increases chem removal speed.",
		"Stage Speed 6" = "Consumed chemicals feed the host.",
	)

/datum/symptom/heal/chem/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 6)
		food_conversion = TRUE
	if(A.totalResistance() >= 7)
		power = 2

/datum/symptom/heal/chem/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	for(var/datum/reagent/R in M.reagents.reagent_list) //Not just toxins!
		M.reagents.remove_reagent(R.type, actual_power)
		if(food_conversion)
			M.adjust_nutrition(0.3)
		if(prob(2))
			to_chat(M, span_notice("You feel a mild warmth as your blood purifies itself."))
	return 1



/datum/symptom/heal/metabolism
	name = "Metabolic Boost"
	stealth = -1
	resistance = -2
	stage_speed = 2
	transmittable = 1
	level = 7
	var/triple_metabolism = FALSE
	var/reduced_hunger = FALSE
	desc = "The virus causes the host's metabolism to accelerate rapidly, making them process chemicals twice as fast,\
	 but also causing increased hunger."
	threshold_descs = list(
		"Stealth 3" = "Reduces hunger rate.",
		"Stage Speed 10" = "Chemical metabolization is tripled instead of doubled.",
	)

/datum/symptom/heal/metabolism/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 10)
		triple_metabolism = TRUE
	if(A.totalStealth() >= 3)
		reduced_hunger = TRUE

/datum/symptom/heal/metabolism/Heal(mob/living/carbon/C, datum/disease/advance/A, actual_power)
	if(!istype(C))
		return
	C.reagents.metabolize(C, can_overdose=TRUE) //this works even without a liver; it's intentional since the virus is metabolizing by itself
	if(triple_metabolism)
		C.reagents.metabolize(C, can_overdose=TRUE)
	C.overeatduration = max(C.overeatduration - 2, 0)
	var/lost_nutrition = 9 - (reduced_hunger * 5)
	C.adjust_nutrition(-lost_nutrition * HUNGER_FACTOR) //Hunger depletes at 10x the normal speed
	if(prob(2))
		to_chat(C, span_notice("You feel an odd gurgle in your stomach, as if it was working much faster than normal."))
	return 1

/datum/symptom/heal/darkness
	name = "Nocturnal Regeneration"
	desc = "The virus is able to mend the host's flesh when in conditions of low light, repairing physical damage. More effective against brute damage."
	stealth = 2
	resistance = -1
	stage_speed = -2
	transmittable = -1
	level = 6
	passive_message = span_notice("You feel tingling on your skin as light passes over it.")
	threshold_descs = list(
		"Stage Speed 8" = "Doubles healing speed.",
	)

/datum/symptom/heal/darkness/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 8)
		power = 2

/datum/symptom/heal/darkness/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	var/light_amount = 0
	if(isturf(M.loc)) //else, there's considered to be no light
		var/turf/T = M.loc
		light_amount = min(1,T.get_lumcount()) - 0.5
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			return power

/datum/symptom/heal/darkness/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 2 * actual_power

	var/list/parts = M.get_damaged_bodyparts(1,1, null, BODYPART_ORGANIC)

	if(!parts.len)
		return

	if(prob(5))
		to_chat(M, span_notice("The darkness soothes and mends your wounds."))

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len * 0.5, null, BODYPART_ORGANIC)) //more effective on brute
			M.update_damage_overlays()
	return 1

/datum/symptom/heal/darkness/passive_message_condition(mob/living/M)
	if(M.getBruteLoss() || M.getFireLoss())
		return TRUE
	return FALSE

/datum/symptom/heal/coma
	name = "Regenerative Coma"
	desc = "The virus causes the host to fall into a death-like coma when severely damaged, then rapidly fixes the damage."
	stealth = 0
	resistance = 2
	stage_speed = -3
	transmittable = -2
	level = 8
	passive_message = span_notice("The pain from your wounds makes you feel oddly sleepy...")
	var/deathgasp = FALSE
	var/active_coma = FALSE //to prevent multiple coma procs
	threshold_descs = list(
		"Stealth 2" = "Host appears to die when falling into a coma.",
		"Resistance 4" = "The virus also stabilizes the host while they are in critical condition.",
		"Stage Speed 7" = "Increases healing speed.",
	)

/datum/symptom/heal/coma/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 7)
		power = 1.5
	if(A.totalStealth() >= 2)
		deathgasp = TRUE

/datum/symptom/heal/coma/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	if(HAS_TRAIT(M, TRAIT_DEATHCOMA))
		return power
	else if(M.IsUnconscious() || M.stat == UNCONSCIOUS)
		return power * 0.9
	else if(M.stat == SOFT_CRIT)
		return power * 0.5
	else if(M.IsSleeping())
		return power * 0.25
	else if(M.getBruteLoss() + M.getFireLoss() >= 70 && !active_coma)
		to_chat(M, span_warning("You feel yourself slip into a regenerative coma..."))
		active_coma = TRUE
		addtimer(CALLBACK(src, .proc/coma, M), 60)

/datum/symptom/heal/coma/proc/coma(mob/living/M)
	if(deathgasp)
		M.emote("deathgasp")
	M.fakedeath("regenerative_coma")
	M.update_stat()
	M.update_mobility()
	addtimer(CALLBACK(src, .proc/uncoma, M), 300)

/datum/symptom/heal/coma/proc/uncoma(mob/living/M)
	if(!active_coma)
		return
	active_coma = FALSE
	M.cure_fakedeath("regenerative_coma")
	M.update_stat()
	M.update_mobility()

/datum/symptom/heal/coma/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 4 * actual_power

	var/list/parts = M.get_damaged_bodyparts(1,1)

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len, null, BODYPART_ORGANIC))
			M.update_damage_overlays()

	if(active_coma && M.getBruteLoss() + M.getFireLoss() == 0)
		uncoma(M)

	return 1

/datum/symptom/heal/coma/passive_message_condition(mob/living/M)
	if((M.getBruteLoss() + M.getFireLoss()) > 30)
		return TRUE
	return FALSE

/datum/symptom/heal/water
	name = "Tissue Hydration"
	desc = "The virus uses excess water inside and outside the body to repair damaged tissue cells. More effective when using holy water and against burns."
	stealth = 0
	resistance = -1
	stage_speed = 0
	transmittable = 1
	level = 6
	passive_message = span_notice("Your skin feels oddly dry...")
	var/absorption_coeff = 1
	threshold_descs = list(
		"Resistance 5" = "Water is consumed at a much slower rate.",
		"Stage Speed 7" = "Increases healing speed.",
	)

/datum/symptom/heal/water/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 7)
		power = 2
	if(A.totalResistance() >= 5)
		absorption_coeff = 0.25

/datum/symptom/heal/water/CanHeal(datum/disease/advance/A)
	. = 0
	var/mob/living/M = A.affected_mob
	if(M.fire_stacks < 0)
		M.fire_stacks = min(M.fire_stacks + 1 * absorption_coeff, 0)
		. += power
	if(M.reagents.has_reagent(/datum/reagent/water/holywater, needs_metabolizing = FALSE))
		M.reagents.remove_reagent(/datum/reagent/water/holywater, 0.5 * absorption_coeff)
		. += power * 0.75
	else if(M.reagents.has_reagent(/datum/reagent/water, needs_metabolizing = FALSE))
		M.reagents.remove_reagent(/datum/reagent/water, 0.5 * absorption_coeff)
		. += power * 0.5

/datum/symptom/heal/water/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 2 * actual_power

	var/list/parts = M.get_damaged_bodyparts(1,1, null, BODYPART_ORGANIC) //more effective on burns

	if(!parts.len)
		return

	if(prob(5))
		to_chat(M, span_notice("You feel yourself absorbing the water around you to soothe your damaged skin."))

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len * 0.5, heal_amt/parts.len, null, BODYPART_ORGANIC))
			M.update_damage_overlays()

	return 1

/datum/symptom/heal/water/passive_message_condition(mob/living/M)
	if(M.getBruteLoss() || M.getFireLoss())
		return TRUE
	return FALSE

/datum/symptom/heal/plasma
	name = "Plasma Fixation"
	desc = "The virus draws plasma from the atmosphere and from inside the body to heal and stabilize body temperature."
	stealth = 0
	resistance = 3
	stage_speed = -2
	transmittable = -2
	level = 8
	passive_message = span_notice("You feel an odd attraction to plasma.")
	var/temp_rate = 1
	threshold_descs = list(
		"Transmission 6" = "Increases temperature adjustment rate.",
		"Stage Speed 7" = "Increases healing speed.",
	)

/datum/symptom/heal/plasma/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 7)
		power = 2
	if(A.totalTransmittable() >= 6)
		temp_rate = 4

/datum/symptom/heal/plasma/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	var/datum/gas_mixture/environment

	. = 0

	if(M.loc)
		environment = M.loc.return_air()
	if(environment)
		if(environment.get_moles(/datum/gas/plasma) > GLOB.meta_gas_info[/datum/gas/plasma][META_GAS_MOLES_VISIBLE]) //if there's enough plasma in the air to see
			. += power * 0.5
	var/requires_metabolizing = !(A.process_dead && M.stat == DEAD) //don't require metabolizing if our host is dead and we have necrotic metabolsim
	if(M.reagents.has_reagent(/datum/reagent/toxin/plasma, needs_metabolizing = requires_metabolizing))
		. +=  power * 0.75

/datum/symptom/heal/plasma/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 4 * actual_power

	if(prob(5))
		to_chat(M, span_notice("You feel yourself absorbing plasma inside and around you..."))

	if(M.bodytemperature > BODYTEMP_NORMAL)
		M.adjust_bodytemperature(-20 * temp_rate * TEMPERATURE_DAMAGE_COEFFICIENT,BODYTEMP_NORMAL)
		if(prob(5))
			to_chat(M, span_notice("You feel less hot."))
	else if(M.bodytemperature < (BODYTEMP_NORMAL + 1))
		M.adjust_bodytemperature(20 * temp_rate * TEMPERATURE_DAMAGE_COEFFICIENT,0,BODYTEMP_NORMAL)
		if(prob(5))
			to_chat(M, span_notice("You feel warmer."))

	M.adjustToxLoss(-heal_amt)

	var/list/parts = M.get_damaged_bodyparts(1,1, null, BODYPART_ORGANIC)
	if(!parts.len)
		return
	if(prob(5))
		to_chat(M, span_notice("The pain from your wounds fades rapidly."))
	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len, null, BODYPART_ORGANIC))
			M.update_damage_overlays()
	return 1


/datum/symptom/heal/radiation
	name = "Radioactive Resonance"
	desc = "The virus uses radiation to fix damage through dna mutations."
	stealth = -1
	resistance = -2
	stage_speed = 2
	transmittable = -3
	level = 6
	symptom_delay_min = 1
	symptom_delay_max = 1
	passive_message = span_notice("Your skin glows faintly for a moment.")
	var/cellular_damage = FALSE
	threshold_descs = list(
		"Transmission 6" = "Additionally heals cellular damage.",
		"Resistance 7" = "Increases healing speed.",
	)

/datum/symptom/heal/radiation/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalResistance() >= 7)
		power = 2
	if(A.totalTransmittable() >= 6)
		cellular_damage = TRUE

/datum/symptom/heal/radiation/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	switch(M.radiation)
		if(0)
			return FALSE
		if(1 to RAD_MOB_SAFE)
			return 0.25
		if(RAD_MOB_SAFE to RAD_BURN_THRESHOLD)
			return 0.5
		if(RAD_BURN_THRESHOLD to RAD_MOB_MUTATE)
			return 0.75
		if(RAD_MOB_MUTATE to RAD_MOB_KNOCKDOWN)
			return 1
		else
			return 1.5

/datum/symptom/heal/radiation/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = actual_power

	if(cellular_damage)
		M.adjustCloneLoss(-heal_amt * 0.5)

	M.adjustToxLoss(-(2 * heal_amt))

	var/list/parts = M.get_damaged_bodyparts(1,1, null, BODYPART_ORGANIC)

	if(!parts.len)
		return

	if(prob(4))
		to_chat(M, span_notice("Your skin glows faintly, and you feel your wounds mending themselves."))

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len, null, BODYPART_ORGANIC))
			M.update_damage_overlays()
	return 1
	

/datum/symptom/vampirism
	name = "Hemetophagy"
	desc = "The host absorbs blood from external sources, and seemlessly reintegrates it into their own bloodstream, regardless of its bloodtype or how it was ingested. However, the virus also slowly consumes the host's blood"
	stealth = 1
	resistance = -2
	stage_speed = 1
	transmittable = 2
	level = 9
	symptom_delay_min = 1
	symptom_delay_max = 1
	bodies = list("Blood")
	var/bloodpoints = 0
	var/maxbloodpoints = 50
	var/bloodtypearchive
	var/bruteheal = FALSE
	var/aggression = FALSE
	var/vampire = FALSE
	var/mob/living/carbon/human/bloodbag
		threshold_descs = list(
		"Transmission 4" = "Host appears to die when falling into a coma.",
		"Transmission 6" = "The virus aggressively assimilates blood, resulting in contiguous blood pools being absorbed by the virus, as well as sucking blood out of open wounds of subjects in physical contact with the host.",
		"Stage Speed 7" = "The virus grows more aggressive, assimilating blood and healing at a faster rate, but also draining the host's blood quicker",
	)
	



/datum/symptom/vampirism/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.totalTransmittable() >= 4)
		bruteheal = TRUE
	if(A.totalTransmittable() >= 6)
		aggression = TRUE
		maxbloodpoints += 50
	if(A.totalStageSpeed() >= 7)
		power += 1
	if((A.totalStealth() >= 2) && (A.totalTransmittable >= 6) && A.process_dead) //this is low transmission for 2 reasons: transmission is hard to raise, especially with stealth, and i dont want this to be obligated to be transmittable
		vampire = TRUE
		maxbloodpoints += 50
		power += 1
	if(ishuman(A.affected_mob) && A.affected_mob.get_blood_id() == /datum/reagent/blood)
		var/mob/living/carbon/human/H = A.affected_mob
		bloodtypearchive = H.dna.blood_type
		H.dna.blood_type = "U"

/datum/symptom/vampirism/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(1 to 4)
			if(prob(5))
				to_chat(M, "<span class='warning'>[pick("You feel cold...", "You feel a bit thirsty", "It dawns upon you that every single human on this station has warm blood pulsing through their veins.")]</span>")
		if(5)
			ADD_TRAIT(A.affected_mob, TRAIT_DRINKSBLOOD, DISEASE_TRAIT)
			var/grabbedblood = succ(M) //before adding sucked blood to bloodpoints, immediately try to heal bloodloss
			if(M.blood_volume < BLOOD_VOLUME_NORMAL && M.get_blood_id() == /datum/reagent/blood)
				var/missing = BLOOD_VOLUME_NORMAL - M.blood_volume
				var/inflated = grabbedblood * 4
				M.blood_volume = min(M.blood_volume + inflated, BLOOD_VOLUME_NORMAL)
				bloodpoints += round(max(0, (inflated - missing)/4))
			else if((M.blood_volume >= BLOOD_VOLUME_NORMAL + 4) && (bloodpoints < maxbloodpoints))//so drinking blood accumulates bloodpoints
				M.blood_volume = (M.blood_volume - 4)
				bloodpoints += 1
			else
				bloodpoints += max(0, grabbedblood)
			for(var/I in 1 to power)//power doesnt increase efficiency, just usage. 
				if(bloodpoints > 0)
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						if(H.bleed_rate >= 2 && bruteheal && bloodpoints)
							bloodpoints -= 1
							H.bleed_rate = max(0, (H.bleed_rate - 2))
					if(M.blood_volume < BLOOD_VOLUME_NORMAL && M.get_blood_id() == /datum/reagent/blood) //bloodloss is prioritized over healing brute
						bloodpoints -= 1
						M.blood_volume = max((M.blood_volume + 3 * power), BLOOD_VOLUME_NORMAL) //bloodpoints are valued at 4 units of blood volume per point, so this is diminished
					else if(bruteheal && M.getBruteLoss())
						bloodpoints -= 1
						M.heal_overall_damage(2, required_status = BODYTYPE_ORGANIC)
					if(prob(60) && !M.stat) 
						bloodpoints -- //you cant just accumulate blood and keep it as a battery of healing. the quicker the symptom is, the faster your bloodpoints decay
				else if(prob(20) && M.blood_volume >= BLOOD_VOLUME_BAD)//the virus continues to extract blood if you dont have any stored up. higher probability due to BP value
					M.blood_volume = (M.blood_volume - 1)

			if(!bloodpoints && prob(3))
				to_chat(M, "<span class='warning'>[pick("You feel a pang of thirst.", "No food can sate your hunger", "Blood...")]</span>")

/datum/symptom/vampirism/End(datum/disease/advance/A)
	. = ..()
	REMOVE_TRAIT(A.affected_mob, TRAIT_DRINKSBLOOD, DISEASE_TRAIT)
	if(bloodtypearchive && ishuman(A.affected_mob))
		var/mob/living/carbon/human/H = A.affected_mob
		H.dna.blood_type = bloodtypearchive 

/datum/symptom/vampirism/proc/succ(mob/living/carbon/M) //you dont need the blood reagent to suck blood. however, you need to have blood, or at least a shared blood reagent, for most of the other uses
	var/gainedpoints = 0
	if(bloodbag && !bloodbag.blood_volume) //we've exsanguinated them!
		bloodbag = null
	if(ishuman(M) && M.stat == DEAD && vampire)
		var/mob/living/carbon/human/H = M
		var/possibledist = power + 1
		if(M.get_blood_id() != /datum/reagent/blood)
			possibledist = 1
		if(!(NOBLOOD in H.dna.species.species_traits)) //if you dont have blood, well... sucks to be you
			H.setOxyLoss(0,0) //this is so a crit person still revives if suffocated
			if(bloodpoints >= 200 && H.health > 0 && H.blood_volume >= BLOOD_VOLUME_NORMAL) //note that you need to actually need to heal, so a maxed out virus won't be bringing you back instantly in most cases. *even so*, if this needs to be nerfed ill do it in a heartbeat
				H.revive(0)
				H.visible_message("<span class='warning'>[H.name]'s skin takes on a rosy hue as they begin moving. They live again!</span>", "<span class='userdanger'>As your body fills with fresh blood, you feel your limbs once more, accompanied by an insatiable thirst for blood.</span>")
				bloodpoints = 0
				return 0
			else if(bloodbag && bloodbag.blood_volume && (bloodbag.stat || bloodbag.bleed_rate))
				if(get_dist(bloodbag, H) <= 1 && bloodbag.z == H.z)
					var/amt = ((bloodbag.stat * 2) + 2) * power
					var/excess = max(((min(amt, bloodbag.blood_volume) - (BLOOD_VOLUME_NORMAL - H.blood_volume)) / 2), 0)
					H.blood_volume = min(H.blood_volume + min(amt, bloodbag.blood_volume), BLOOD_VOLUME_NORMAL)
					bloodbag.blood_volume = max(bloodbag.blood_volume - amt, 0)
					bloodpoints += max(excess, 0)
					playsound(bloodbag.loc, 'sound/magic/exit_blood.ogg', 10, 1)
					bloodbag.visible_message("<span class='warning'>Blood flows from [bloodbag.name]'s wounds into [H.name]'s corpse!</span>", "<span class='userdanger'>Blood flows from your wounds into [H.name]'s corpse!</span>")
				else if(get_dist(bloodbag, H) >= possibledist) //they've been taken out of range.
					bloodbag = null
					return
				else if(bloodpoints >= 2)
					var/turf/T = H.loc
					var/obj/effect/decal/cleanable/blood/influenceone = (locate(/obj/effect/decal/cleanable/blood) in H.loc)
					if(!influenceone && bloodpoints >= 2)
						H.add_splatter_floor(T)
						playsound(T, 'sound/effects/splat.ogg', 50, 1)
						bloodpoints -= 2
						return 0
					else 
						var/todir = get_dir(H, bloodbag)
						var/targetloc = bloodbag.loc
						var/dist = get_dist(H, bloodbag)
						for(var/i=0 to dist)
							T = get_step(T, todir)
							todir = get_dir(T, bloodbag)
							var/obj/effect/decal/cleanable/blood/influence = (locate(/obj/effect/decal/cleanable/blood) in T)
							if(!influence && bloodpoints >= 2)
								H.add_splatter_floor(T)
								playsound(T, 'sound/effects/splat.ogg', 50, 1)
								bloodpoints -= 2
								return 0
							else if(T == targetloc && bloodpoints >= 2)
								bloodbag.throw_at(H, 1, 1)
								bloodpoints -= 2
								bloodbag.visible_message("<span class='warning'>A current of blood pushes [bloodbag.name] towards [H.name]'s corpse!</span>")
								playsound(bloodbag.loc, 'sound/magic/exit_blood.ogg', 25, 1)
								return 0 
			else 
				var/list/candidates = list()
				for(var/mob/living/carbon/human/C in ohearers(min(bloodpoints/4, possibledist), H))
					if(NOBLOOD in C.dna.species.species_traits)
						continue
					if(C.stat && C.blood_volume && C.get_blood_id() == H.get_blood_id())
						candidates += C
				for(var/prospect in candidates)
					candidates[prospect] = 1
					if(ishuman(prospect))
						var/mob/living/carbon/human/candidate = prospect
						candidates[prospect] += (candidate.stat - 1)
						candidates[prospect] += (3 - get_dist(candidate, H)) * 2
						candidates[prospect] += round(candidate.blood_volume / 150)
				bloodbag = pickweight(candidates) //dont return here
	
	if(bloodpoints >= maxbloodpoints)
		return 0
	if(ishuman(M) && aggression) //first, try to suck those the host is actively grabbing
		var/mob/living/carbon/human/H = M
		if(H.pulling && ishuman(H.pulling)) //grabbing is handled with the disease instead of the component, so the component doesn't have to be processed
			var/mob/living/carbon/human/C = H.pulling
			if(!C.bleed_rate && vampire && C.can_inject() && H.grab_state && C.get_blood_id() == H.get_blood_id() && !(NOBLOOD in C.dna.species.species_traits))//aggressive grab as a "vampire" starts the target bleeding
				C.bleed_rate += 1
				C.visible_message("<span class='warning'>Wounds open on [C.name]'s skin as [H.name] grips them tightly!</span>", "<span class='userdanger'>You begin bleeding at [H.name]'s touch!</span>")
			if(C.blood_volume && C.can_inject() &&(C.bleed_rate && (!C.bleedsuppress || vampire )) && C.get_blood_id() == H.get_blood_id() && !(NOBLOOD in C.dna.species.species_traits))
				var/amt = (H.grab_state + C.stat + 2) * power
				if(C.blood_volume)
					var/excess = max(((min(amt, C.blood_volume) - (BLOOD_VOLUME_NORMAL - H.blood_volume)) / 4), 0)
					H.blood_volume = min(H.blood_volume + min(amt, C.blood_volume), BLOOD_VOLUME_NORMAL)
					C.blood_volume = max(C.blood_volume - amt, 0)
					gainedpoints = CLAMP(excess, 0, maxbloodpoints - bloodpoints)
					C.visible_message("<span class='warning'>Blood flows from [C.name]'s wounds into [H.name]!</span>", "<span class='userdanger'>Blood flows from your wounds into [H.name]!</span>")
					playsound(C.loc, 'sound/magic/exit_blood.ogg', 25, 1)
					return gainedpoints
	if(locate(/obj/effect/decal/cleanable/blood) in M.loc)
		var/obj/effect/decal/cleanable/blood/initialstain = (locate(/obj/effect/decal/cleanable/blood) in M.loc)
		var/list/stains = list()
		var/suckamt = power + 1
		if(aggression)
			for(var/obj/effect/decal/cleanable/blood/contiguousstain in orange(1, M))
				if(suckamt)
					suckamt --
					stains += contiguousstain
			if(suckamt)
				suckamt --
				stains += initialstain
		for(var/obj/effect/decal/cleanable/blood/stain in stains) //this doesnt use switch(type) because that doesnt check subtypes
			if(istype(stain, /obj/effect/decal/cleanable/blood/gibs/old))
				gainedpoints += 3
				qdel(stain)
			else if(istype(stain, /obj/effect/decal/cleanable/blood/old))
				gainedpoints += 1
				qdel(stain)
			else if(istype(stain, /obj/effect/decal/cleanable/blood/gibs))
				gainedpoints += 5
				qdel(stain)
			else if(istype(stain, /obj/effect/decal/cleanable/blood/footprints) || istype(stain, /obj/effect/decal/cleanable/blood/tracks) || istype(stain, /obj/effect/decal/cleanable/blood/drip))
				qdel(stain)//these types of stain are generally very easy to make, we don't use these
			else if(istype(stain, /obj/effect/decal/cleanable/blood))
				gainedpoints += 2
				qdel(stain)
		if(gainedpoints)
			playsound(M.loc, 'sound/magic/exit_blood.ogg', 50, 1)
			M.visible_message("<span class='warning'>Blood flows from the floor into [M.name]!</span>", "<span class='warning'>You consume the errant blood</span>")
		return CLAMP(gainedpoints, 0, maxbloodpoints - bloodpoints)
	if(ishuman(M) && aggression)//finally, attack mobs touching the host. 
		var/mob/living/carbon/human/H = M
		for(var/mob/living/carbon/human/C in ohearers(1, H))
			if(NOBLOOD in C.dna.species.species_traits)
				continue
			if((C.pulling && C.pulling == H) || (C.loc == H.loc) && C.bleed_rate && C.get_blood_id() == H.get_blood_id())
				var/amt = (2 * power)
				if(C.blood_volume)
					var/excess = max(((min(amt, C.blood_volume) - (BLOOD_VOLUME_NORMAL - H.blood_volume)) / 4 * power), 0)
					H.blood_volume = min(H.blood_volume + min(amt, C.blood_volume), BLOOD_VOLUME_NORMAL)
					C.blood_volume = max(C.blood_volume - amt, 0)
					gainedpoints += CLAMP(excess, 0, maxbloodpoints - bloodpoints)
					C.visible_message("<span class='warning'>Blood flows from [C.name]'s wounds into [H.name]!</span>", "<span class='userdanger'>Blood flows from your wounds into [H.name]!</span>")
		return CLAMP(gainedpoints, 0, maxbloodpoints - bloodpoints)
