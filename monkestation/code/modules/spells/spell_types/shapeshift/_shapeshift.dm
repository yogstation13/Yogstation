/datum/action/cooldown/spell/shapeshift
	/// If TRUE, the mob will keep the name of the caster.
	var/keep_name = FALSE

/datum/action/cooldown/spell/shapeshift/do_shapeshift(mob/living/caster)
	. = ..()
	var/mob/living/new_form = .
	if(istype(new_form) && keep_name)
		new_form.real_name = caster.real_name
		new_form.name = caster.real_name
		new_form.update_name_tag()
