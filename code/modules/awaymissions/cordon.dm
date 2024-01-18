/turf/cordon
	name = "cordon"
	icon = 'icons/turf/walls.dmi'
	icon_state = "cordon"
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	explosion_block = INFINITY
	rad_insulation = RAD_FULL_INSULATION
	opacity = TRUE
	density = TRUE
	blocks_air = TRUE
	space_lit = TRUE
	bullet_bounce_sound = null
	turf_flags = NOJAUNT
	baseturfs = /turf/cordon

/turf/cordon/AfterChange()
	. = ..()
	SSair.high_pressure_delta -= src

/turf/cordon/attack_ghost(mob/dead/observer/user)
	return FALSE

/turf/cordon/acid_act(acidpwr, acid_volume, acid_id)
	return FALSE

/turf/cordon/Melt()
	to_be_destroyed = FALSE
	return src

/turf/cordon/singularity_act()
	return FALSE

/turf/cordon/ScrapeAway(amount, flags)
	return src // :devilcat:

/turf/cordon/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit)
	SHOULD_CALL_PARENT(FALSE) // Fuck you
	return BULLET_ACT_HIT

/turf/cordon/Adjacent(atom/neighbor, atom/target, atom/movable/mover)
	return FALSE

/turf/cordon/Bumped(atom/movable/bumped_atom)
	. = ..()

	if(HAS_TRAIT(bumped_atom, TRAIT_FREE_HYPERSPACE_SOFTCORDON_MOVEMENT)) //we could feasibly reach the border, so just dont
		dump_in_space(bumped_atom)

/// Area used in conjuction with the cordon turf to create a fully functioning world border.
/area/misc/cordon
	name = "CORDON"
	icon_state = "cordon"
	static_lighting = FALSE
	base_lighting_alpha = 255
	unique = TRUE
	noteleport = TRUE
	hidden = TRUE 
	area_flags = NOTELEPORT
	requires_power = FALSE

/area/misc/cordon/Entered(atom/movable/arrived, area/old_area)
	. = ..()
	for(var/mob/living/enterer as anything in arrived.get_all_contents_type(/mob/living))
		to_chat(enterer, span_userdanger("This was a bad idea..."))
		enterer.dust(TRUE, FALSE, TRUE)

/// This type of cordon will block ghosts from passing through it. Useful for stuff like Away Missions, where you feasibly want to block ghosts from entering to keep a certain map section a secret.
/turf/cordon/secret
	name = "secret cordon (ghost blocking)"

/turf/cordon/secret/attack_ghost(mob/dead/observer/user)
	return FALSE
