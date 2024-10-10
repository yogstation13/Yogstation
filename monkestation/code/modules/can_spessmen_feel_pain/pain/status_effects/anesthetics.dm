/// Anesthetics, for use in surgery - to stop pain.
/datum/status_effect/grouped/anesthetic
	id = "anesthetics"
	alert_type = /atom/movable/screen/alert/status_effect/anesthetics
	var/applied_at = -1

/datum/status_effect/grouped/anesthetic/on_creation(mob/living/new_owner, source)
	if(!istype(get_area(new_owner), /area/station/medical))
		// if we're NOT in medical, give no alert. N2O floods or whatever.
		alert_type = null

	return ..()

/datum/status_effect/grouped/anesthetic/on_apply()
	. = ..()
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT), PROC_REF(try_removal))
	applied_at = world.time

/datum/status_effect/grouped/anesthetic/on_remove()
	. = ..()
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT))
	if(!QDELETED(owner))
		owner.apply_status_effect(/datum/status_effect/anesthesia_grog, applied_at)

/datum/status_effect/grouped/anesthetic/get_examine_text()
	return span_warning("[owner.p_Theyre()] out cold.")

/datum/status_effect/grouped/anesthetic/proc/try_removal(datum/source)
	SIGNAL_HANDLER

	if(HAS_TRAIT(owner, TRAIT_KNOCKEDOUT))
		return

	qdel(src)

/atom/movable/screen/alert/status_effect/anesthetics
	name = "Anesthetic"
	desc = "Everything's woozy... The world goes dark... You're on anesthetics. \
		Good luck in surgery! If it's actually surgery, that is."
	icon_state = "paralysis"

// Extend "too much N2O" so we can apply anesthesia if it knocks the guy out
/obj/item/organ/internal/lungs/too_much_n2o(mob/living/carbon/breather, datum/gas_mixture/breath, n2o_pp, old_n2o_pp)
	. = ..()
	if(HAS_TRAIT(breather, TRAIT_KNOCKEDOUT))
		breather.apply_status_effect(/datum/status_effect/grouped/anesthetic, /datum/gas/nitrous_oxide)

/datum/status_effect/anesthesia_grog
	id = "anesthesia_grog"
	duration = 4 MINUTES
	alert_type = null
	var/strength = 0

/datum/status_effect/anesthesia_grog/on_creation(mob/living/new_owner, anesthesia_appied_at)
	strength = (world.time - anesthesia_appied_at > 1 MINUTES) ? 50 : 90
	return ..()

/datum/status_effect/anesthesia_grog/on_apply()
	to_chat(owner, span_warning("You feel[strength <= 90 ? " ":" a bit "]groggy..."))
	return TRUE
