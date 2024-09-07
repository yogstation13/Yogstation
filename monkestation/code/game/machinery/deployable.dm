/obj/structure/barricade/wooden/CanAllowThrough(atom/movable/mover, border_dir)
	if(HAS_TRAIT(mover, TRAIT_GOES_THROUGH_WOODEN_BARRICADES))
		return TRUE
	return ..()

/obj/structure/barricade/wooden/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(pass_info.goes_thru_barricades)
		return TRUE
	return ..()
