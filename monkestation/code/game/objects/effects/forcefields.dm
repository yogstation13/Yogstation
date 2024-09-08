/obj/effect/forcefield/cosmic_field/CanAllowThrough(atom/movable/mover, border_dir)
	if(isprojectile(mover))
		var/obj/projectile/projectile = mover
		if(isliving(projectile.firer))
			var/mob/living/living_firer = projectile.firer
			if(living_firer.has_status_effect(/datum/status_effect/star_mark))
				return FALSE
	return ..()
