/datum/smite/rip_and_tear
	name = "Rip and tear those tendons"

/datum/smite/rip_and_tear/effect(client/user, mob/living/target)
	. = ..()

	if (!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return
	var/mob/living/carbon/carbon_target = target
	for(var/obj/item/bodypart/limb as anything in carbon_target.bodyparts)
		var/severity = pick(list(
			WOUND_SEVERITY_MODERATE,
			WOUND_SEVERITY_SEVERE,
			WOUND_SEVERITY_SEVERE,
		))
		carbon_target.cause_wound_of_type_and_severity(WOUND_MUSCLE, limb, severity, smited = TRUE)
