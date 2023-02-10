/datum/species/android
	name = "Android"
	id = "android"
	say_mod = "states"
	species_traits = list(NOBLOOD, NOZOMBIE, NOHUSK, NO_DNA_COPY, NOTRANSSTING)
	inherent_traits = list(TRAIT_RESISTHEAT,TRAIT_COLDBLOODED,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE,TRAIT_NOCLONE,TRAIT_TOXIMMUNE,TRAIT_GENELESS,TRAIT_NOFIRE,TRAIT_PIERCEIMMUNE,TRAIT_NOHUNGER,TRAIT_LIMBATTACHMENT,TRAIT_MEDICALIGNORE)
	inherent_biotypes = list(MOB_ROBOTIC, MOB_HUMANOID)
	meat = /obj/item/stack/sheet/plasteel{amount = 5}
	skinned_type = /obj/item/stack/sheet/metal{amount = 10}
	damage_overlay_type = "synth"
	mutantbrain = /obj/item/organ/brain/positron
	mutanteyes = /obj/item/organ/eyes/robotic
	mutanttongue = /obj/item/organ/tongue/robot
	mutantliver = /obj/item/organ/liver/cybernetic/upgraded/ipc
	mutantstomach = /obj/item/organ/stomach/cybernetic	//Is there even anything an android would use a stomach for?
	mutantears = /obj/item/organ/ears/cybernetic
	species_language_holder = /datum/language_holder/synthetic
	limbs_id = "synth"
	toxmod = 0
	clonemod = 0
	reagent_tag = PROCESS_SYNTHETIC
	species_gibs = "robotic"
	attack_sound = 'sound/items/trayhit1.ogg'
	screamsound = 'goon/sound/robot_scream.ogg'
	allow_numbers_in_name = TRUE
	deathsound = 'sound/voice/borg_deathsound.ogg'
	wings_icon = "Robotic"
	changesource_flags = MIRROR_BADMIN | MIRROR_MAGIC | WABBAJACK | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

/datum/species/android/on_species_gain(mob/living/carbon/C)
	. = ..()
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/O = X
		O.change_bodypart_status(BODYPART_ROBOTIC, FALSE, TRUE)
		BP.brute_reduction_reduction = 5
		BP.burn_reduction_reduction = 4

/datum/species/android/on_species_loss(mob/living/carbon/C)
	. = ..()
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/O = X
		O.change_bodypart_status(BODYPART_ORGANIC,FALSE, TRUE)
		BP.brute_reduction_reduction = initial(BP.brute_reduction)
		BP.burn_reduction_reduction = initial(BP.burn_reduction)

/datum/species/android/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	. = ..()
	if(H.reagents.has_reagent(/datum/reagent/oil))
		H.adjustFireLoss(-2*REAGENTS_EFFECT_MULTIPLIER,FALSE,FALSE, BODYPART_ANY)

/datum/species/android/holy //EMP immune android for the technophile sect.
	id = "holy android"
	changesource_flags = MIRROR_BADMIN
	random_eligible = FALSE
	
/datum/species/android/holy/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()

	C.AddComponent(/datum/component/empprotection, EMP_PROTECT_SELF) // The power of god protects them from EMPS.
	
/datum/species/android/holy/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()

	var/datum/component/empprotection/empproof = C.GetExactComponent(/datum/component/empprotection)
	empproof.RemoveComponent()//remove emp proof if they stop being an android
