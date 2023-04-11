/obj/item/ammo_casing/caseless
	desc = "A caseless bullet casing."
	firing_effect_type = null
	casing_flags = CASINGFLAG_NO_LIVE_SPRITE | CASINGFLAG_FORCE_CLEAR_CHAMBER | CASINGFLAG_NOT_HEAVY_METAL

/obj/item/ammo_casing/caseless/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, atom/fired_from)
	if (..()) //successfully firing
		moveToNullspace()
		QDEL_NULL(src)
		return TRUE
	else
		return FALSE
