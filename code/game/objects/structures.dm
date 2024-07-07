/obj/structure
	icon = 'icons/obj/structures.dmi'
	pressure_resistance = 8
	max_integrity = 300
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT
	layer = BELOW_OBJ_LAYER
	blocks_emissive = EMISSIVE_BLOCK_GENERIC

	var/broken = 0 //similar to machinery's stat BROKEN


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
	if(istype(mover) && (mover.pass_flags & PASSSTRUCTURE))
		return TRUE

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
