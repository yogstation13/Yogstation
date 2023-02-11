/obj/item/ammo_casing/caseless
	desc = "A caseless bullet casing."
	firing_effect_type = null
	heavy_metal = FALSE
	live_sprite = FALSE

/obj/item/ammo_casing/caseless/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, atom/fired_from)
	if (..()) //successfully firing
		moveToNullspace()
		QDEL_NULL(src)
		return TRUE
	else
		return FALSE

/obj/item/ammo_casing/reusable
	desc = "A reusable bullet casing."
	firing_effect_type = null
	heavy_metal = FALSE
	live_sprite = FALSE

	/// If the projectile is currently being shot as a projectile
	var/in_air = FALSE

/obj/item/ammo_casing/reusable/ready_proj(atom/target, mob/living/user, quiet, zone_override = "", atom/fired_from)
	..()
	var/obj/item/projectile/bullet/reusable/reusable_projectile = BB
	if(istype(reusable_projectile))
		reusable_projectile.ammo_type = src
	forceMove(BB)
	in_air = TRUE

/obj/item/ammo_casing/reusable/proc/on_land()
	BB = new projectile_type(src)
	in_air = FALSE
	update_icon()
