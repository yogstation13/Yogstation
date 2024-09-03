/obj/structure
	icon = 'icons/obj/structures.dmi'
	pressure_resistance = 8
	max_integrity = 300
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT
	layer = BELOW_OBJ_LAYER
	blocks_emissive = EMISSIVE_BLOCK_GENERIC

	var/broken = 0 //similar to machinery's stat BROKEN

	var/projectile_passchance = 0 //projectile passthrough chance 100% always goes through, 0% never goes through. Definition isn't required if structure doesn't have density, duh.


/obj/structure/Initialize(mapload)
	if (!armor)
		armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	. = ..()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH(src)
		QUEUE_SMOOTH_NEIGHBORS(src)
		if(smoothing_flags & SMOOTH_CORNERS)
			icon_state = ""
	GLOB.cameranet.updateVisibility(src)
	GLOB.thrallnet.updateVisibility(src)

/obj/structure/Destroy()
	GLOB.cameranet.updateVisibility(src)
	GLOB.thrallnet.updateVisibility(src)
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH_NEIGHBORS(src)
	return ..()

/obj/structure/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(loc, /obj/structure) in get_turf(mover))
		return TRUE
	else if(istype(mover, /obj/projectile))
		if(!projectile_passchance)
			return
		if(!anchored)
			return TRUE
		var/obj/projectile/proj = mover
		if(proj.firer && Adjacent(proj.firer))
			return TRUE
		if(prob((projectile_passchance)))
			return TRUE
		return FALSE


/obj/structure/ui_act(action, params)
	add_fingerprint(usr)
	return ..()

/obj/structure/examine(mob/user)
	. = ..()
	if(!(resistance_flags & INDESTRUCTIBLE))
		if(resistance_flags & ON_FIRE)
			. += span_warning("It's on fire!")
		if(broken)
			. += span_notice("It appears to be broken.")

/obj/structure/rust_heretic_act()
	take_damage(500, BRUTE, MELEE, 1)
