// Category 2 medicines are medicines that have an ill effect regardless of volume/OD to dissuade doping. Mostly used as emergency chemicals OR to convert damage (and heal a bit in the process). The type is used to prompt borgs that the medicine is harmful.
/datum/reagent/medicine/c2
	harmful = TRUE
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/******BRUTE******/
/*Suffix: -bital*/

/datum/reagent/medicine/c2/libital //messes with your liber
	name = "Libital"
	description = "A bruise reliever. Does minor liver damage."
	color = "#ECEC8D" // rgb: 236 236 141
	overdose_threshold = 30
	taste_description = "bitter with a hint of alcohol"
	reagent_state = SOLID

/datum/reagent/medicine/c2/libital/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.3 * REM)
	M.adjustBruteLoss(-3 * REM)
	..()
	return TRUE

/datum/reagent/medicine/c2/libital/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.9 * REM)
	M.adjustOrganLoss(ORGAN_SLOT_STOMACH, 0.5 * REM)
	..()
	. = TRUE

/datum/reagent/medicine/c2/probital
	name = "Probital"
	description = "Originally developed as a prototype-gym supliment for those looking for quick workout turnover, this oral medication quickly repairs broken muscle tissue but causes lactic acid buildup, tiring the patient. Overdosing can cause extreme drowsiness. An Influx of nutrients promotes the muscle repair even further."
	reagent_state = SOLID
	color = "#FFFF6B"
	overdose_threshold = 20

/datum/reagent/medicine/c2/probital/on_mob_life(mob/living/carbon/M,times_fired)
	M.adjustBruteLoss(-2.25 * REM, FALSE)
	var/ooo_youaregettingsleepy = 3.5
	switch(round(M.getStaminaLoss()))
		if(10 to 40)
			ooo_youaregettingsleepy = 3
		if(41 to 60)
			ooo_youaregettingsleepy = 2.5
		if(61 to 200) //you really can only go to 120
			ooo_youaregettingsleepy = 2
	M.adjustStaminaLoss(ooo_youaregettingsleepy * REM)
	..()
	. = TRUE

/datum/reagent/medicine/c2/probital/overdose_process(mob/living/M)
	M.adjustStaminaLoss(3 * REM, 0)
	if(M.getStaminaLoss() >= 80)
		M.drowsyness += 1 * REM
	if(M.getStaminaLoss() >= 100)
		to_chat(M,span_warning("You feel more tired than you usually do, perhaps if you rest your eyes for a bit..."))
		M.adjustStaminaLoss(-100, TRUE)
		M.Sleeping(10 SECONDS)
	..()
	. = TRUE

/datum/reagent/medicine/c2/probital/reaction_mob(mob/living/L, method=TOUCH, reac_volume)
	if(method != INGEST || !iscarbon(L))
		return

	L.reagents.remove_reagent(/datum/reagent/medicine/c2/probital, reac_volume * 0.05)
	L.reagents.add_reagent(/datum/reagent/medicine/metafactor, reac_volume * 0.25)

	..()

/******BURN******/
/*Suffix: -uri*/
/datum/reagent/medicine/c2/lenturi
	name = "Lenturi"
	description = "Used to treat burns. Makes you move slower while it is in your system. Applies stomach damage when it leaves your system."
	reagent_state = LIQUID
	color = "#6171FF"

/datum/reagent/medicine/c2/lenturi/on_mob_life(mob/living/carbon/M)
	M.adjustFireLoss(-3 * REM)
	M.adjustOrganLoss(ORGAN_SLOT_STOMACH, 0.4 * REM)
	..()
	return TRUE

/datum/reagent/medicine/c2/lenturi/on_mob_metabolize(mob/living/carbon/M)
	M.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=1.5, blacklisted_movetypes=(FLYING|FLOATING))
	return ..()

/datum/reagent/medicine/c2/lenturi/on_mob_end_metabolize(mob/living/carbon/M)
	M.remove_movespeed_modifier(type)
	return ..()

/datum/reagent/medicine/c2/aiuri
	name = "Aiuri"
	description = "Used to treat burns. Does minor eye damage."
	color = "#8C93FF"
	overdose_threshold = 30
	taste_description = "ammonia with a bit of acid"
	reagent_state = LIQUID

/datum/reagent/medicine/c2/aiuri/on_mob_life(mob/living/carbon/M)
	M.adjustFireLoss(-2 * REM)
	M.adjustOrganLoss(ORGAN_SLOT_EYES, 0.25 * REM)
	..()
	return TRUE

/datum/reagent/medicine/c2/aiuri/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_EYES, 0.75 * REM)
	M.adjustOrganLoss(ORGAN_SLOT_STOMACH, 0.4 * REM)
	..()
	. = TRUE

/datum/reagent/medicine/c2/rhigoxane
	name = "Rhigoxane"
	description = "A second generation burn treatment agent exhibiting a cooling effect that is especially pronounced when deployed as a spray. Its high halogen content helps extinguish fires."
	reagent_state = LIQUID
	color = "#F7FFA5"
	overdose_threshold = 25
	reagent_weight = 0.6

/datum/reagent/medicine/c2/rhigoxane/on_mob_life(mob/living/carbon/M)
	if(M.getFireLoss() > 50)
		M.adjustFireLoss(-2 * REM, FALSE)
	else
		M.adjustFireLoss(-1.25 * REM, FALSE)
	M.adjust_bodytemperature(rand(-25,-5) * TEMPERATURE_DAMAGE_COEFFICIENT * REM, 50)
	M.reagents?.chem_temp += (-10 * REM)
	M.adjust_fire_stacks(-1 * REM)
	..()
	. = TRUE

/datum/reagent/medicine/c2/rhigoxane/reaction_mob(mob/living/carbon/exposed_mob, methods=VAPOR, reac_volume)
	. = ..()
	if(!(methods & VAPOR))
		return

	exposed_mob.adjust_bodytemperature(-reac_volume * TEMPERATURE_DAMAGE_COEFFICIENT, 50)
	exposed_mob.adjust_fire_stacks(-reac_volume / 2)
	if(reac_volume >= metabolization_rate)
		exposed_mob.ExtinguishMob()

/datum/reagent/medicine/c2/rhigoxane/overdose_process(mob/living/carbon/M)
	M.adjust_bodytemperature(-10 * TEMPERATURE_DAMAGE_COEFFICIENT * REM, 50) //chilly chilly
	..()


/******OXY******/
/*Suffix: -mol*/
/datum/reagent/medicine/c2/tirimol
	name = "Tirimol"
	description = "An oxygen deprivation medication that causes fatigue. Prolonged exposure causes the patient to fall asleep once the medicine metabolizes."
	color = "#FF6464"
	/// A cooldown for spacing bursts of stamina damage
	COOLDOWN_DECLARE(drowsycd)

/datum/reagent/medicine/c2/tirimol/on_mob_life(mob/living/carbon/human/M)
	M.adjustOxyLoss(-3 * REM)
	M.adjustStaminaLoss(2 * REM)
	if(drowsycd && COOLDOWN_FINISHED(src, drowsycd))
		M.drowsyness += 10
		COOLDOWN_START(src, drowsycd, 45 SECONDS)
	else if(!drowsycd)
		COOLDOWN_START(src, drowsycd, 15 SECONDS)
	..()
	return TRUE

/datum/reagent/medicine/c2/tirimol/on_mob_end_metabolize(mob/living/L)
	if(current_cycle > 20)
		L.Sleeping(10 SECONDS)
	..()

/******TOXIN******/
/*Suffix: -iver*/

/datum/reagent/medicine/c2/seiver //a bit of a gray joke
	name = "Seiver"
	description = "A medicine that shifts functionality based on its temperature. Colder temperatures incurs radiation removal while hotter temperatures promote antitoxicity. Damages the heart." //CHEM HOLDER TEMPS, NOT AIR TEMPS
	var/radbonustemp = (T0C - 100) //being below this number gives you 10% off rads.

/datum/reagent/medicine/c2/seiver/on_mob_metabolize(mob/living/carbon/human/M)
	. = ..()
	radbonustemp = rand(radbonustemp - 50, radbonustemp + 50) // Basically this means 50K and below will always give the percent heal, and upto 150K could. Calculated once.

/datum/reagent/medicine/c2/seiver/on_mob_life(mob/living/carbon/human/M)
	var/chemtemp = min(holder.chem_temp, 1000)
	chemtemp = chemtemp ? chemtemp : 273 //why do you have null sweaty
	var/healypoints = 0 //5 healypoints = 1 heart damage; 5 rads = 1 tox damage healed for the purpose of healypoints

	//you're hot
	var/toxcalc = min(round(5 + ((chemtemp-1000)/175), 0.1), 5) * REM //max 2.5 tox healing per second, 1 point per 175 degrees over 125 kelvin
	if(toxcalc > 0)
		M.adjustToxLoss(-toxcalc)
		healypoints += toxcalc

	//and you're cold
	var/radcalc = round((T0C-chemtemp) / 6, 0.1) * REM //max ~45 rad loss unless you've hit below 0K. if so, wow. 1 point per 6 degrees under 273 kelvin
	if(radcalc > 0)
		//no cost percent healing if you are SUPER cold (on top of cost healing)
		if(chemtemp < radbonustemp*0.1) //if you're super chilly, it takes off 25% of your current rads
			M.radiation = round(M.radiation * (0.75**(REM)))
		else if(chemtemp < radbonustemp)//else if you're under the chill-zone, it takes off 10% of your current rads
			M.radiation = round(M.radiation * (0.90**(REM)))
		M.radiation -= radcalc
		healypoints += (radcalc / 5)

	//you're yes and... oh no!
	healypoints = round(healypoints, 0.1)
	M.adjustOrganLoss(ORGAN_SLOT_HEART, healypoints / 5)
	..()
	return TRUE

#define isthiaormusc(A) (istype(A,/datum/reagent/medicine/c2/thializid) || istype(A,/datum/reagent/medicine/c2/musiver)) //musc is metab of thialazid so let's make sure we're not purging either

/datum/reagent/medicine/c2/thializid
	name = "Thializid"
	description = "A potent antidote for intravenous use with a narrow therapeutic index, it is considered an active prodrug of musiver."
	reagent_state = LIQUID
	color = "#8CDF24" // heavy saturation to make the color blend better
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	overdose_threshold = 6
	var/conversion_amount

/datum/reagent/medicine/c2/thializid/reaction_mob(mob/living/L, method=TOUCH, reac_volume)
	if(method != INJECT || !iscarbon(L))
		return
	var/mob/living/carbon/C = L
	if(reac_volume >= 0.6) //prevents cheesing with ultralow doses.
		C.adjustToxLoss(-1.5 * min(2, reac_volume) * REM, 0)   //This is to promote iv pole use for that chemotherapy feel.
	var/obj/item/organ/liver/Lword = C.internal_organs_slot[ORGAN_SLOT_LIVER]
	if((Lword.organ_flags & ORGAN_FAILING) || !Lword)
		return
	conversion_amount = reac_volume * (min(100 -C.getOrganLoss(ORGAN_SLOT_LIVER), 80) / 100) //the more damaged the liver the worse we metabolize.
	C.reagents.remove_reagent(/datum/reagent/medicine/c2/thializid, conversion_amount)
	C.reagents.add_reagent(/datum/reagent/medicine/c2/musiver, conversion_amount)
	..()

/datum/reagent/medicine/c2/thializid/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.8 * REM )
	M.adjustToxLoss(-1 * REM, 0)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(isthiaormusc(R))
			continue
		M.reagents.remove_reagent(R.type, 0.4 * REM)

	..()
	. = TRUE

/datum/reagent/medicine/c2/thializid/overdose_process(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 1.5 * REM)
	M.adjust_disgust(3 * REM)
	M.reagents.add_reagent(/datum/reagent/medicine/c2/musiver, 0.225 * REM)
	..()
	. = TRUE

/datum/reagent/medicine/c2/musiver //MUScles
	name = "Musiver"
	description = "The active metabolite of thializid. Causes muscle weakness on overdose"
	reagent_state = LIQUID
	color = "#DFD54E"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 25
	var/datum/brain_trauma/mild/muscle_weakness/U

/datum/reagent/medicine/c2/musiver/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.1 * REM)
	M.adjustToxLoss(-1 * REM, 0)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(isthiaormusc(R))
			continue
		M.reagents.remove_reagent(R.type, 0.2 * REM)
	..()
	. = TRUE

/datum/reagent/medicine/c2/musiver/overdose_start(mob/living/carbon/M)
	U = new()
	M.gain_trauma(U, TRAUMA_RESILIENCE_ABSOLUTE)
	..()

/datum/reagent/medicine/c2/musiver/on_mob_delete(mob/living/carbon/M)
	if(U)
		QDEL_NULL(U)
	return ..()

/datum/reagent/medicine/c2/musiver/overdose_process(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 1.5 * REM)
	M.adjust_disgust(3 * REM)
	..()
	. = TRUE

#undef isthiaormusc

/******NICHE******/
//todo
