#define CONCIOUSAY(text) if(H.stat == CONSCIOUS) { ##text }

/datum/species/wy_synth
	name = "Synthetic"
	id = "synthetic"
	say_mod = "states"

	species_traits = list(NOTRANSSTING,NOEYESPRITES,NO_DNA_COPY,TRAIT_EASYDISMEMBER,ROBOTIC_LIMBS,NOZOMBIE,NOHUSK,NOBLOOD)
	inherent_traits = list(TRAIT_NOBREATH, TRAIT_RADIMMUNE,TRAIT_COLDBLOODED,TRAIT_LIMBATTACHMENT,TRAIT_NOCRITDAMAGE,TRAIT_GENELESS,TRAIT_MEDICALIGNORE,TRAIT_NOCLONE,TRAIT_TOXIMMUNE,TRAIT_EASILY_WOUNDED,TRAIT_NODEFIB)
	inherent_biotypes = list(MOB_ROBOTIC)
	mutantbrain = /obj/item/organ/brain/positron
	mutantheart = /obj/item/organ/heart/cybernetic
	mutanteyes = /obj/item/organ/eyes/robotic
	mutanttongue = /obj/item/organ/tongue/robot
	mutantliver = /obj/item/organ/liver/cybernetic/upgraded
	mutantstomach = /obj/item/organ/stomach/cell
	mutantears = /obj/item/organ/ears/robot
	mutantlungs = /obj/item/organ/lungs
	meat = /obj/item/stack/sheet/plasteel{amount = 5}
	skinned_type = /obj/item/stack/sheet/metal{amount = 10}
	exotic_blood = /datum/reagent/oil

	forced_skintone = "albino"

	payday_modifier = 0
	burnmod = 1
	heatmod = 1
	brutemod = 0.85
	toxmod = 0
	clonemod = 0
	staminamod = 0.6
	coldmod = 0.3 //You take less cold damage
	siemens_coeff = 1.75
	reagent_tag = PROCESS_SYNTHETIC
	species_gibs = "robotic"
	attack_sound = 'sound/items/trayhit1.ogg'
	screamsound = 'goon/sound/robot_scream.ogg'
	allow_numbers_in_name = TRUE
	deathsound = 'sound/voice/borg_deathsound.ogg'
	wings_icon = "Robotic"
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

	var/charge = PRETERNIS_LEVEL_FULL
	var/power_drain = 0.5 //probably going to have to tweak this shit
	var/draining = FALSE


/datum/species/wy_synth/on_species_gain(mob/living/carbon/human/C)
	. = ..()
	var/obj/item/organ/appendix/A = C.getorganslot(ORGAN_SLOT_APPENDIX) // Easiest way to remove it.
	if(A)
		A.Remove(C)
		QDEL_NULL(A)
	C.grant_language(/datum/language/machine, source = LANGUAGE_SYNTH)


/datum/species/wy_synth/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	C.remove_language(/datum/language/machine, source = LANGUAGE_SYNTH)

/datum/species/wy_synth/proc/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT

/datum/species/wy_synth/spec_revival(mob/living/carbon/human/H, admin_revive)
	if(admin_revive)
		return ..()
	H.Stun(4 SECONDS) // No moving either
	H.update_body()
	addtimer(CALLBACK(src, .proc/afterrevive, H), 0)
	return

/datum/species/wy_synth/proc/afterrevive(mob/living/carbon/human/H)
	CONCIOUSAY(H.say("Reactivating [pick("core systems", "central subroutines", "key functions")]..."))
	sleep(3 SECONDS)
	CONCIOUSAY(H.say("Reinitializing [pick("personality matrix", "behavior logic", "morality subsystems")]..."))
	sleep(3 SECONDS)
	CONCIOUSAY(H.say("Finalizing setup..."))
	sleep(3 SECONDS)
	CONCIOUSAY(H.say("Unit [H.real_name] is fully functional. Have a nice day."))
	if(H.stat == DEAD)
		return
	H.update_body()

/datum/species/wy_synth/spec_fully_heal(mob/living/carbon/human/H)
	. = ..()
	charge = PRETERNIS_LEVEL_FULL

/datum/species/wy_synth/spec_life(mob/living/carbon/human/H)
	. = ..()

	if(H.oxyloss)
		H.setOxyLoss(0)
		H.losebreath = 0

	handle_charge(H)


/datum/species/wy_synth/proc/handle_charge(mob/living/carbon/human/H)
	charge = clamp(charge - power_drain,PRETERNIS_LEVEL_NONE,PRETERNIS_LEVEL_FULL)
	if(charge == PRETERNIS_LEVEL_NONE)
		to_chat(H,span_danger("Warning! System power criti-$#@$"))
		H.death()
	else if(charge < PRETERNIS_LEVEL_STARVING)
		H.throw_alert("preternis_charge", /atom/movable/screen/alert/preternis_charge, 3)
	else if(charge < PRETERNIS_LEVEL_HUNGRY)
		H.throw_alert("preternis_charge", /atom/movable/screen/alert/preternis_charge, 2)
	else if(charge < PRETERNIS_LEVEL_FED)
		H.throw_alert("preternis_charge", /atom/movable/screen/alert/preternis_charge, 1)
	else
		H.clear_alert("preternis_charge")


/datum/species/wy_synth/eat_text(fullness, eatverb, obj/O, mob/living/carbon/C, mob/user)
	. = TRUE
	if(C == user)
		user.visible_message(span_notice("[user] shoves \the [O] down their port."), span_notice("You shove [O] down your input port."))
	else
		C.visible_message(span_danger("[user] forces [O] down [C] port!"), \
									span_userdanger("[user] forces [O] down [C]'s port!"))

/datum/species/wy_synth/force_eat_text(fullness, obj/O, mob/living/carbon/C, mob/user)
	. = TRUE
	C.visible_message(span_danger("[user] attempts to shove [O] down [C]'s port!"), \
										span_userdanger("[user] attempts to shove [O] down [C]'s port!"))

/datum/species/wy_synth/drink_text(obj/O, mob/living/carbon/C, mob/user)
	. = TRUE
	if(C == user)
		user.visible_message(span_notice("[user] pours some of [O] into their port."), span_notice("You pour some of [O] down your input port."))
	else
		C.visible_message(span_danger("[user] pours some of [O] into [C]'s port."), span_userdanger("[user] pours some of [O]'s into [C]'s port."))

/datum/species/wy_synth/force_drink_text(obj/O, mob/living/carbon/C, mob/user)
	. = TRUE
	C.visible_message(span_danger("[user] attempts to pour [O] down [C]'s port!"), \
										span_userdanger("[user] attempts to pour [O] down [C]'s port!"))



/datum/species/wy_synth/spec_AltClickOn(atom/A,H)
	return drain_power_from(H, A)

/datum/species/wy_synth/proc/drain_power_from(mob/living/carbon/human/H, atom/A)
	if(get_dist(H, A) > 1)
		to_chat(H, span_warning("[A] is too far away!"))
		return FALSE

	if(!istype(H) || !A)
		return FALSE

	if(draining)
		to_chat(H,span_info("CONSUME protocols can only be used on one object at any single time."))
		return FALSE
	if(!A.can_consume_power_from())
		return FALSE //if it returns text, we want it to continue so we can get the error message later.

	draining = TRUE

	var/siemens_coefficient = H.dna.species.siemens_coeff //makes power drain speed scale with preternis stats


	if (charge >= PRETERNIS_LEVEL_FULL - 25) //just to prevent spam a bit
		to_chat(H,span_notice("CONSUME protocol reports no need for additional power at this time."))
		draining = FALSE
		return TRUE

	if(H.gloves)
		if(!H.gloves.siemens_coefficient)
			to_chat(H,span_info("NOTICE: [H.gloves] prevent electrical contact - CONSUME protocol aborted."))
			draining = FALSE
			return TRUE
		else
			if(H.gloves.siemens_coefficient < 1)
				to_chat(H,span_info("NOTICE: [H.gloves] are interfering with electrical contact - advise removal before activating CONSUME protocol."))
			siemens_coefficient *= H.gloves.siemens_coefficient

	H.face_atom(A)
	H.visible_message(span_warning("[H] starts placing their hands on [A]..."), span_warning("You start placing your hands on [A]..."))
	if(!do_after(H, HAS_TRAIT(H, TRAIT_VORACIOUS)? 1.5 SECONDS : 2 SECONDS, A))
		to_chat(H,span_info("CONSUME protocol aborted."))
		draining = FALSE
		return TRUE

	to_chat(H,span_info("Extracutaneous implants detect viable power source. Initiating CONSUME protocol."))

	var/done = FALSE
	var/drain = 150 * siemens_coefficient

	var/cycle = 0
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
	spark_system.attach(A)
	spark_system.set_up(5, 0, A)



	while(!done)
		cycle++
		var/nutritionIncrease = drain * ELECTRICITY_TO_NUTRIMENT_FACTOR

		if(charge + nutritionIncrease > PRETERNIS_LEVEL_FULL)
			nutritionIncrease = clamp(PRETERNIS_LEVEL_FULL - charge, PRETERNIS_LEVEL_NONE,PRETERNIS_LEVEL_FULL) //if their nutrition goes up from some other source, this could be negative, which would cause bad things to happen.
			drain = nutritionIncrease/ELECTRICITY_TO_NUTRIMENT_FACTOR

		if (do_after(H, HAS_TRAIT(H, TRAIT_VORACIOUS)? 0.4 SECONDS : 0.5 SECONDS, A))
			var/can_drain = A.can_consume_power_from()
			if(!can_drain || istext(can_drain))
				if(istext(can_drain))
					to_chat(H,can_drain)
				done = TRUE
			else
				playsound(A.loc, "sparks", 50, 1)
				if(prob(75))
					spark_system.start()
				var/drained = A.consume_power_from(drain)
				if(drained < drain)
					to_chat(H,span_info("[A]'s power has been depleted, CONSUME protocol halted."))
					done = TRUE
				charge = clamp(charge + (drained * ELECTRICITY_TO_NUTRIMENT_FACTOR),PRETERNIS_LEVEL_NONE,PRETERNIS_LEVEL_FULL)

				if(!done)
					if(charge > (PRETERNIS_LEVEL_FULL - 25))
						to_chat(H,span_info("CONSUME protocol complete. Physical nourishment refreshed."))
						done = TRUE
					else if(!(cycle % 4))
						var/nutperc = round((charge / PRETERNIS_LEVEL_FULL) * 100)
						to_chat(H,span_info("CONSUME protocol continues. Current satiety level: [nutperc]%."))
		else
			done = TRUE
	qdel(spark_system)
	draining = FALSE
	return TRUE

#undef CONCIOUSAY
