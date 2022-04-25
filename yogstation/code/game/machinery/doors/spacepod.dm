/obj/structure/spacepoddoor
	name = "podlock"
	desc = "Why it no open!!!"
	icon = 'yogstation/icons/effects/beam.dmi'
	icon_state = "n_beam"
	density = 1
	anchored = 1
	var/id = 1.0
	CanAtmosPass = ATMOS_PASS_NO

/obj/structure/spacepoddoor/Initialize()
	..()
	air_update_turf(1)

/obj/structure/spacepoddoor/Destroy()
	air_update_turf(1)
	return ..()

/obj/structure/spacepoddoor/CanAllowThrough(atom/movable/A)
	if(istype(A, /obj/spacepod))
		return TRUE
	return ..()
