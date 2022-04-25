/datum/surgery/advanced/bioware/nerve_grounding
	name = "Nerve Grounding"
	desc = "A surgical procedure which makes the patient's nerves act as grounding rods, protecting them from electrical shocks."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/ground_nerves,
				/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)
	bioware_target = BIOWARE_NERVES

/datum/surgery_step/ground_nerves
	name = "ground nerves"
	accept_hand = TRUE
	time = 155

/datum/surgery_step/ground_nerves/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You start rerouting [target]'s nerves."),
		"[user] starts rerouting [target]'s nerves.",
		"[user] starts manipulating [target]'s nervous system.")

/datum/surgery_step/ground_nerves/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You successfully reroute [target]'s nervous system!"),
		"[user] successfully reroutes [target]'s nervous system!",
		"[user] finishes manipulating [target]'s nervous system.")
	new /datum/bioware/grounded_nerves(target)
	return TRUE

/datum/bioware/grounded_nerves
	name = "Grounded Nerves"
	desc = "Nerves form a safe path for electricity to traverse, protecting the body from electric shocks."
	mod_type = BIOWARE_NERVES
	var/prev_coeff

/datum/bioware/grounded_nerves/on_gain()
	..()
	prev_coeff = owner.physiology.siemens_coeff
	owner.physiology.siemens_coeff = 0

/datum/bioware/grounded_nerves/on_lose()
	..()
	owner.physiology.siemens_coeff = prev_coeff