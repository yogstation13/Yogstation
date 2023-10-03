#define CONCIOUSAY(text) if(H.stat == CONSCIOUS) { ##text }

/datum/species/wy_synth
	name = "Synthetic"
	id = "synthetic"
	say_mod = "states"

	limbs_id = "human"
	damage_overlay_type = "synth"

	species_traits = list(NOTRANSSTING,NOEYESPRITES,NO_DNA_COPY,TRAIT_EASYDISMEMBER,NOZOMBIE,NOHUSK,NOBLOOD, NO_UNDERWEAR)
	inherent_traits = list(TRAIT_NOBREATH, TRAIT_RADIMMUNE,TRAIT_COLDBLOODED,TRAIT_LIMBATTACHMENT,TRAIT_NOCRITDAMAGE,TRAIT_GENELESS,TRAIT_MEDICALIGNORE,TRAIT_NOCLONE,TRAIT_TOXIMMUNE,TRAIT_EASILY_WOUNDED,TRAIT_NODEFIB,
	TRAIT_NOHUNGER, TRAIT_REDUCED_DAMAGE_SLOWDOWN, TRAIT_NOGUNS, TRAIT_NO_GRENADES)
	no_equip = list(ITEM_SLOT_MASK, ITEM_SLOT_OCLOTHING, ITEM_SLOT_HEAD, ITEM_SLOT_EYES)
	inherent_biotypes = list(MOB_ROBOTIC)
	mutantbrain = /obj/item/organ/brain/positron/synth
	mutantheart = /obj/item/organ/heart/cybernetic
	mutanteyes = /obj/item/organ/eyes/robotic/synth
	mutanttongue = /obj/item/organ/tongue/robot
	mutantliver = /obj/item/organ/liver/cybernetic/upgraded
	mutantstomach = /obj/item/organ/stomach/cell
	mutantears = /obj/item/organ/ears/robot
	mutantlungs = /obj/item/organ/lungs
	meat = /obj/item/stack/sheet/plasteel{amount = 5}
	skinned_type = /obj/item/stack/sheet/metal{amount = 10}
	exotic_blood = /datum/reagent/oil
	use_skintones = TRUE
	forced_skintone = "albino"

	payday_modifier = 0
	burnmod = 0.9
	heatmod = 0.95
	brutemod = 0.75
	toxmod = 0
	clonemod = 0
	staminamod = 0.5
	coldmod = 0.25 //You take less cold damage
	siemens_coeff = 1.75
	species_gibs = "robotic"
	attack_sound = 'sound/items/trayhit1.ogg'
	screamsound = 'goon/sound/robot_scream.ogg'
	allow_numbers_in_name = TRUE
	deathsound = 'sound/voice/borg_deathsound.ogg'
	wings_icon = "Robotic"
	changesource_flags = NONE

	var/charge = PRETERNIS_LEVEL_FULL
	var/power_drain = 0.25 //probably going to have to tweak this shit
	var/draining = FALSE
	var/datum/action/innate/undeployment_synth/undeployment_action = new
	///For transferring back and forth to an AI body when it's the AI deploying
	var/mob/living/silicon/ai/mainframe

	inherent_slowdown = 0.65
	var/datum/action/innate/synth_os/os_button = new


	///Original synth number designation for when this shell becomes uninhabited
	var/original_numbers

	var/obj/item/ai_cpu/inbuilt_cpu

	punchdamagehigh = 12
	punchdamagelow = 5
	punchstunthreshold = 11
	var/force_multiplier = 1.25 //We hit 25% harder with all weapons

	var/last_warned


/datum/species/wy_synth/on_species_gain(mob/living/carbon/human/C)
	. = ..()
	RegisterSignal(C, COMSIG_MOB_SAY, .proc/handle_speech)
	RegisterSignal(C, COMSIG_MOB_ALTCLICKON, .proc/drain_power_from)


	var/obj/item/organ/appendix/A = C.getorganslot(ORGAN_SLOT_APPENDIX) // Easiest way to remove it.
	if(A)
		A.Remove(C)
		QDEL_NULL(A)
	C.grant_language(/datum/language/machine, source = LANGUAGE_SYNTH)
	original_numbers = rand(1, 999)
	C.real_name = "Synthetic Unit #[original_numbers]"
	C.name = C.real_name
	os_button.Grant(C)
	add_synthos(C)
	
	if(!C.ai_network)
		C.ai_network = new(C)
	
	inbuilt_cpu = new /obj/item/ai_cpu

/datum/species/wy_synth/proc/add_synthos(mob/living/carbon/human/C)
	if(C.mind && !C.mind.synth_os)
		C.mind.synth_os = new(C)

	
/datum/species/wy_synth/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	C.remove_language(/datum/language/machine, source = LANGUAGE_SYNTH)
	os_button.Remove(C)
	inbuilt_cpu.forceMove(get_turf(C))
	inbuilt_cpu = null

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

	if(H.stat == DEAD)
		return

	if(!H.ai_network)
		H.ai_network = new /datum/ai_network(synth_starter = H)

	if(H.oxyloss)
		H.setOxyLoss(0)
		H.losebreath = 0

	handle_charge(H)

	if(H.mind)
		if(!H.mind.synth_os && !mainframe)
			add_synthos(H)
		if(!H.mind.unconvertable)
			H.mind.unconvertable = TRUE

	if(H.mind?.synth_os)
		H.mind.synth_os.tick(2 SECONDS * 0.1)


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

/datum/species/wy_synth/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H, wound_bonus = 0, bare_wound_bonus = 0, sharpness = SHARP_NONE, attack_direction = null)
	. = ..()
	var/hit_percent = (100-(blocked+armor))/100
	if(last_warned <= world.time)
		last_warned = world.time + 30 SECONDS
		H.mind.synth_os.suspicion_add((damage * hit_percent * brutemod) / 5, SYNTH_DAMAGED)


/datum/species/wy_synth/proc/assume_control(var/mob/living/silicon/ai/AI, mob/living/carbon/human/H)
	H.real_name = "[AI.real_name]"	//Randomizing the name so it shows up separately in the shells list
	H.name = H.real_name
	var/obj/item/card/id/ID = H.wear_id
	if(ID)
		ID.update_label(AI.real_name, "Synthetic")
	mainframe = AI
	undeployment_action.Grant(H)

/datum/action/innate/undeployment_synth
	name = "Disconnect from synthetic unit"
	desc = "Stop controlling this synthetic unit and resume normal core operations."
	button_icon  = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "ai_core"

/datum/action/innate/undeployment_synth/Trigger()
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = owner

	var/confirm = tgui_alert(H, "Are you sure you want to undeploy? You will not be able to redeploy unless the synthetic unit is in a storage unit!", "Confirm Undeployment", list("Yes", "No"))
	if(confirm != "Yes")
		return

	var/datum/species/wy_synth/S = H.dna.species
	S.undeploy(H)
	return TRUE



/datum/species/wy_synth/proc/undeploy(mob/living/carbon/human/H)
	if(!H.mind)
		return
	H.mind.transfer_to(mainframe)
	undeployment_action.Remove(H)
	mainframe = null

/datum/species/wy_synth/proc/transfer(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/mind/our_mind = user.mind
	user.mind.transfer_to(target)
	our_mind.synth_os.switch_shell(user, target)

	target.real_name = "[user.real_name]"	//Randomizing the name so it shows up separately in the shells list
	target.name = target.real_name
	var/obj/item/card/id/ID = target.wear_id
	if(ID)
		ID.registered_name = user.real_name
		ID.update_label(user.real_name, "Synthetic")

	user.real_name = "Synthetic Unit #[original_numbers]"
	user.name = user.real_name
	ID = user.wear_id
	if(ID)
		ID.registered_name = user.real_name
		ID.update_label(user.real_name, "Synthetic")
	user.say("Unit disconnected. Entering sleep mode.")

/datum/species/wy_synth/spec_attack_hand(mob/living/carbon/human/attacker, mob/living/carbon/human/user)
	if(is_synth(attacker) && is_synth(user)) 
		if(user.mind == attacker.mind)
			return ..()
		if(user.mind)
			to_chat(attacker, span_warning("[user] is currently occupied by a different personality!"))
			return ..()
		var/response = tgui_alert(user, "Are you sure you want to transfer into this unit?", "Synthetic Personality Transfer", list("Yes", "No"))
		if(response != "Yes")
			return ..()
		transfer(attacker, user)
		return TRUE
	return ..()

/datum/action/innate/synth_os
	name = "Access SynthOS"
	desc = "Allows access to internal functions."
	button_icon = 'icons/obj/modular_laptop.dmi'
	button_icon_state = "laptop"

/datum/action/innate/synth_os/IsAvailable(feedback = FALSE)
	. = ..()
	if(!is_synth(owner))
		return
	var/mob/living/carbon/human/H = owner
	var/datum/species/wy_synth/WS = H?.dna?.species
	if(WS && istype(WS))
		if(WS.mainframe)
			to_chat(owner, span_warning("Unfortunately SynthOS is not supported in remotely controlled synthetic units."))
			return FALSE
		return TRUE
	

/datum/action/innate/synth_os/Trigger()
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = owner
	if(H.mind)
		H.mind.synth_os.ui_interact(owner)
	
	return FALSE


#undef CONCIOUSAY

