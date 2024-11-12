/datum/quirk/blooddeficiency
	name = "Blood Deficiency"
	desc = "Your body can't produce enough blood to sustain itself."
	icon = FA_ICON_TINT
	value = -8
	mob_trait = TRAIT_BLOOD_DEFICIENCY
	gain_text = span_danger("You feel your vigor slowly fading away.")
	lose_text = span_notice("You feel vigorous again.")
	medical_record_text = "Patient requires regular treatment for blood loss due to low production of blood."
	hardcore_value = 8
	quirk_flags = QUIRK_HUMAN_ONLY
	mail_goodies = list(/obj/item/reagent_containers/blood/o_minus) // universal blood type that is safe for all
	var/min_blood = BLOOD_VOLUME_SAFE - 25 // just barely survivable without treatment

/datum/quirk/blooddeficiency/post_add()
	update_mail()

/datum/quirk/blooddeficiency/add(client/client_source)
	. = ..()
	RegisterSignal(quirk_holder, COMSIG_HUMAN_ON_HANDLE_BLOOD, PROC_REF(lose_blood))
	RegisterSignal(quirk_holder, COMSIG_SPECIES_GAIN, PROC_REF(update_mail))

/datum/quirk/blooddeficiency/remove()
	. = ..()
	UnregisterSignal(quirk_holder, COMSIG_HUMAN_ON_HANDLE_BLOOD)
	UnregisterSignal(quirk_holder, COMSIG_SPECIES_GAIN)

/datum/quirk/blooddeficiency/proc/lose_blood(mob/living/carbon/human/draining, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	if(quirk_holder.stat == DEAD || quirk_holder.blood_volume <= min_blood)
		return

	// Ensures that we don't reduce total blood volume below min_blood.
	draining.blood_volume = max(min_blood, draining.blood_volume - draining.dna.species.blood_deficiency_drain_rate * seconds_per_tick)

/datum/quirk/blooddeficiency/proc/update_mail(datum/source, datum/species/new_species, datum/species/old_species)
	SIGNAL_HANDLER

	mail_goodies.Cut()

	var/datum/blood_type/new_type = quirk_holder.get_blood_type()
	if(isnull(new_type))
		return

	if(istype(new_type, /datum/blood_type/crew/human))
		mail_goodies += /obj/item/reagent_containers/blood/o_minus
		return

	for(var/obj/item/reagent_containers/blood/blood_bag as anything in typesof(/obj/item/reagent_containers/blood))
		if(initial(blood_bag.blood_type) == new_type.type)
			mail_goodies += blood_bag
			break
