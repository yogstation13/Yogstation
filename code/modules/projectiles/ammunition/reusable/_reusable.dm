// For casing that are dropped when the projectile has hit, usually for casing that are the projectiles like foam darts or arrows.
// They don't get deleted when fire and instead are moved to the projectile until it lands, where it is then dropped.
// Intended to be used with '/obj/item/projectile/bullet/reusable'.
/obj/item/ammo_casing/reusable
	desc = "A reusable bullet casing."
	firing_effect_type = null
	heavy_metal = FALSE
	live_sprite = FALSE

	/// If the projectile is currently being shot as a projectile
	var/in_air = FALSE
	/// How much the projectiles rotation should be adjusted to make this properly line up when it lands, mainly for thing like arrows where the sprite isn't stright up and down.
	var/base_rotation = 0

/obj/item/ammo_casing/reusable/ready_proj(atom/target, mob/living/user, quiet, zone_override = "", atom/fired_from)
	..()
	var/obj/item/projectile/bullet/reusable/reusable_projectile = BB
	if(istype(reusable_projectile))
		reusable_projectile.ammo_type = src
	forceMove(BB)
	in_air = TRUE

/obj/item/ammo_casing/reusable/proc/on_land(var/obj/item/projectile/old_projectile)
	var/matrix/M = matrix(transform)
	M.Turn(old_projectile.Angle - base_rotation)
	transform = M
	newshot()
	in_air = FALSE
	update_icon()
