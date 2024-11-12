/// Gives the target a mix of pretty bad wounds
/datum/smite/small_bit_of_everything
	name = "Light wound mix bag"

/datum/smite/small_bit_of_everything/effect(client/user, mob/living/target)
	. = ..()

	if (!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return
	var/mob/living/carbon/carbon_target = target
	for(var/obj/item/bodypart/limb as anything in carbon_target.bodyparts)
		var/severity = pick(list(
			WOUND_SEVERITY_MODERATE,
			WOUND_SEVERITY_MODERATE,
			WOUND_SEVERITY_SEVERE,
		))
		var/wound_type = pick(list(
			"[WOUND_BLUNT]",
			"[WOUND_SLASH]",
			"[WOUND_PIERCE]",
			"[WOUND_BURN]",
			"[WOUND_MUSCLE]",
		))
		carbon_target.cause_wound_of_type_and_severity(wound_type, limb, severity, smited = TRUE)
