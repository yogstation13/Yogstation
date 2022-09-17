/*
procs:

handle_charge - called in spec_life(),handles the alert indicators,the power loss death and decreasing the charge level
adjust_charge - take a positive or negative value to adjust the charge level
*/

/datum/species/preternis
	name = "Preternis"
	id = "preternis"
	default_color = "FFFFFF"
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	inherent_traits = list(TRAIT_NOHUNGER, TRAIT_RADIMMUNE, TRAIT_MEDICALIGNORE) //Medical Ignore doesn't prevent basic treatment,only things that cannot help preternis,such as cryo and medbots
	species_traits = list(EYECOLOR, HAIR, LIPS, DIGITIGRADE)
	say_mod = "intones"
	attack_verb = "assault"
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/synthmeat
	toxic_food = NONE
	liked_food = FRIED | SUGAR | JUNKFOOD | FRUIT
	disliked_food = GROSS | VEGETABLES
	brutemod = 1.25 //Have you ever punched a metal plate?
	burnmod = 1.5 //Computers don't like heat
	coldmod = 0.8 //Computers like cold, but their lungs may not
	heatmod = 1.75 //Again, computers don't like heat
	speedmod = 0 //Metal legs are heavy and slow
	punchstunthreshold = 9 //Stun range 9-10 on punch, you are being slugged in the brain by a metal robot fist.
	siemens_coeff = 1.75 //Computers REALLY don't like being shorted out
	payday_modifier = 0.8 //Useful to NT for engineering + very close to Human
	yogs_draw_robot_hair = TRUE
	mutanteyes = /obj/item/organ/eyes/robotic/preternis
	mutantlungs = /obj/item/organ/lungs/preternis
	yogs_virus_infect_chance = 20
	virus_resistance_boost = 10 //YEOUTCH,good luck getting it out
	var/charge = PRETERNIS_LEVEL_FULL
	var/eating_msg_cooldown = FALSE
	var/emag_lvl = 0
	var/power_drain = 0.5 //probably going to have to tweak this shit
	var/tesliumtrip = FALSE
	var/draining = FALSE
	var/soggy = FALSE
	screamsound = 'goon/sound/robot_scream.ogg'
	wings_icon = "Robotic"
	species_language_holder = /datum/language_holder/preternis

/datum/species/preternis/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	for (var/V in C.bodyparts)
		var/obj/item/bodypart/BP = V
		BP.change_bodypart_status(ORGAN_ROBOTIC,FALSE,TRUE)
		BP.burn_reduction = 0
		BP.brute_reduction = 0
		if(istype(BP,/obj/item/bodypart/chest) || istype(BP,/obj/item/bodypart/head))
			continue
		BP.max_damage = 35
		
	C.AddComponent(/datum/component/empprotection, EMP_PROTECT_SELF | EMP_PROTECT_CONTENTS)

	var/matrix/new_transform = matrix()//tall and skinny, bug like, just like skrem envisioned
	new_transform.Scale(0.95, 1/0.95)
	C.transform = new_transform.Multiply(C.transform)
	C.update_transform()

/datum/species/preternis/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	for (var/V in C.bodyparts)
		var/obj/item/bodypart/BP = V
		BP.change_bodypart_status(ORGAN_ORGANIC,FALSE,TRUE)
		BP.burn_reduction = initial(BP.burn_reduction)
		BP.brute_reduction = initial(BP.brute_reduction)
		
	C.GetComponent(/datum/component/empprotection, EMP_PROTECT_SELF | EMP_PROTECT_CONTENTS).RemoveComponent()//remove emp proof if they stop being a preternis

	var/matrix/new_transform = matrix()//returns them to normal shape if they swap to a different species
	new_transform.Scale(1/0.95, 0.95)
	C.transform = new_transform.Multiply(C.transform)
	C.update_transform()

	C.clear_alert("preternis_emag") //this means a changeling can transform from and back to a preternis to clear the emag status but w/e i cant find a solution to not do that
	C.clear_fullscreen("preternis_emag")
	C.remove_movespeed_modifier("preternis_teslium")
	C.remove_movespeed_modifier("preternis_water")

/datum/species/preternis/spec_emag_act(mob/living/carbon/human/H, mob/user)
	. = ..()
	if(emag_lvl == 2)
		return
	emag_lvl = min(emag_lvl + 1,2)
	playsound(H.loc, 'sound/machines/warning-buzzer.ogg', 50, 1, 1)
	H.Paralyze(60)
	switch(emag_lvl)
		if(1)
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 50) //HALP AM DUMB
			to_chat(H,span_danger("ALERT! MEMORY UNIT [rand(1,5)] FAILURE.NERVEOUS SYSTEM DAMAGE."))
		if(2)
			H.overlay_fullscreen("preternis_emag", /obj/screen/fullscreen/high)
			H.throw_alert("preternis_emag", /obj/screen/alert/high/preternis)
			to_chat(H,span_danger("ALERT! OPTIC SENSORS FAILURE.VISION PROCESSOR COMPROMISED."))

/datum/species/preternis/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	. = ..()

	if(H.reagents.has_reagent(/datum/reagent/oil))
		H.adjustFireLoss(-2*REAGENTS_EFFECT_MULTIPLIER,FALSE,FALSE, BODYPART_ANY)

	if(H.reagents.has_reagent(/datum/reagent/fuel))
		H.adjustFireLoss(-1*REAGENTS_EFFECT_MULTIPLIER,FALSE,FALSE, BODYPART_ANY)

	if(H.reagents.has_reagent(/datum/reagent/teslium,10)) //10 u otherwise it wont update and they will remain quikk
		H.add_movespeed_modifier("preternis_teslium", update=TRUE, priority=101, multiplicative_slowdown=-2, blacklisted_movetypes=(FLYING|FLOATING))
		if(H.health < 50 && H.health > 0)
			H.adjustOxyLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
			H.adjustBruteLoss(-1*REAGENTS_EFFECT_MULTIPLIER,FALSE,FALSE, BODYPART_ANY)
			H.adjustFireLoss(-1*REAGENTS_EFFECT_MULTIPLIER,FALSE,FALSE, BODYPART_ANY)
		H.AdjustParalyzed(-3)
		H.AdjustStun(-3)
		H.AdjustKnockdown(-3)
		H.adjustStaminaLoss(-5*REAGENTS_EFFECT_MULTIPLIER)
		charge = clamp(charge - 10 * REAGENTS_METABOLISM,PRETERNIS_LEVEL_NONE,PRETERNIS_LEVEL_FULL)
		burnmod = 200
		tesliumtrip = TRUE
	else if(tesliumtrip)
		burnmod = initial(burnmod)
		tesliumtrip = FALSE
		H.remove_movespeed_modifier("preternis_teslium")

	if (istype(chem,/datum/reagent/consumable))
		var/datum/reagent/consumable/food = chem
		if (food.nutriment_factor)
			var/nutrition = food.nutriment_factor * 0.2
			charge = clamp(charge + nutrition,PRETERNIS_LEVEL_NONE,PRETERNIS_LEVEL_FULL)
			if (!eating_msg_cooldown)
				eating_msg_cooldown = TRUE
				addtimer(VARSET_CALLBACK(src, eating_msg_cooldown, FALSE), 2 MINUTES)
				to_chat(H,span_info("NOTICE: Digestive subroutines are inefficient. Seek sustenance via power-cell C.O.N.S.U.M.E. technology induction."))

	if(chem.current_cycle >= 20)
		H.reagents.del_reagent(chem.type)


	return FALSE

/datum/species/preternis/spec_fully_heal(mob/living/carbon/human/H)
	. = ..()
	charge = PRETERNIS_LEVEL_FULL
	emag_lvl = 0
	H.clear_alert("preternis_emag")
	H.clear_fullscreen("preternis_emag")
	burnmod = initial(burnmod)
	tesliumtrip = FALSE
	H.remove_movespeed_modifier("preternis_teslium") //full heal removes chems so it wont update the teslium speed up until they eat something

/datum/species/preternis/spec_life(mob/living/carbon/human/H)
	. = ..()

	if(H.fire_stacks <= -1 && H.calculate_affecting_pressure(300) == 300)
		H.add_movespeed_modifier("preternis_water", update = TRUE, priority = 102, multiplicative_slowdown = 5, blacklisted_movetypes=(FLYING|FLOATING))
		H.adjustStaminaLoss(9)
		H.adjustFireLoss(4)
		if(!soggy)
			H.emote("scream")
			to_chat(H, span_userdanger("Your entire being screams in agony as being wet causes your wires to short!"))
		soggy = TRUE
		H.throw_alert("preternis_wet", /obj/screen/alert/preternis_wet)
	else if(soggy)
		H.remove_movespeed_modifier("preternis_water")
		to_chat(H, "You breathe a sigh of relief as you dry off.")
		soggy = FALSE
		H.clear_alert("preternis_wet")

	if(H.stat == DEAD)
		return
	handle_charge(H)

/datum/species/preternis/proc/handle_charge(mob/living/carbon/human/H)
	charge = clamp(charge - power_drain,PRETERNIS_LEVEL_NONE,PRETERNIS_LEVEL_FULL)
	if(charge == PRETERNIS_LEVEL_NONE)
		to_chat(H,span_danger("Warning! System power criti-$#@$"))
		H.death()
	else if(charge < PRETERNIS_LEVEL_STARVING)
		H.throw_alert("preternis_charge", /obj/screen/alert/preternis_charge, 3)
	else if(charge < PRETERNIS_LEVEL_HUNGRY)
		H.throw_alert("preternis_charge", /obj/screen/alert/preternis_charge, 2)
	else if(charge < PRETERNIS_LEVEL_FED)
		H.throw_alert("preternis_charge", /obj/screen/alert/preternis_charge, 1)
	else
		H.clear_alert("preternis_charge")

/datum/species/preternis/has_toes()
	return FALSE
