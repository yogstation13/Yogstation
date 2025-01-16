/datum/brain_trauma/special/tenacity
	name = "Tenacity"
	desc = "Patient is psychologically unaffected by pain and injuries, and can remain standing far longer than a normal person."
	scan_desc = "traumatic neuropathy"
	gain_text = span_warning("You suddenly stop feeling pain.")
	lose_text = span_warning("You realize you can feel pain again.")
	/// Traits given to the owner of the trauma.
	var/static/list/traits_to_apply = list(
		TRAIT_NOSOFTCRIT,
		TRAIT_NOHARDCRIT,
		TRAIT_ABATES_SHOCK,
		TRAIT_ANALGESIA,
		TRAIT_NO_PAIN_EFFECTS,
		TRAIT_NO_SHOCK_BUILDUP,
	)

/datum/brain_trauma/special/tenacity/on_gain()
	. = ..()
	owner.pain_controller?.remove_all_pain()
	owner.add_traits(traits_to_apply, TRAUMA_TRAIT)

/datum/brain_trauma/special/tenacity/on_lose()
	. = ..()
	owner.remove_traits(traits_to_apply, TRAUMA_TRAIT)
