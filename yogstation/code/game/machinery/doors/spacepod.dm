/obj/structure/spacepoddoor
	name = "podlock"
	desc = "Why it no open!!!"
	icon = 'yogstation/icons/effects/beam.dmi'
	icon_state = "n_beam"
	density = 1
	anchored = 1
	var/id = 1.0
	can_atmos_pass = ATMOS_PASS_NO

/obj/structure/spacepoddoor/Initialize(mapload)
	air_update_turf()
	return ..()

/obj/structure/spacepoddoor/Destroy()
	can_atmos_pass = ATMOS_PASS_YES
	air_update_turf()
	return ..()

/obj/structure/spacepoddoor/CanAllowThrough(atom/movable/A)
	if(istype(A, /obj/spacepod))
		return TRUE
	return ..()
