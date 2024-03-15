/area/holodeck
	name = "Holodeck"
	icon_state = "Holodeck"
	static_lighting = FALSE
	
	base_lighting_alpha = 255
	flags_1 = NONE

	///The holodeck computer that the area is being hosted by, which we use for power and such.
	var/obj/machinery/computer/holodeck/linked

/*
	Power tracking: Use the holodeck computer's power grid
	Asserts are to avoid the inevitable infinite loops
*/
/area/holodeck/powered(chan)
	if(!requires_power)
		return TRUE
	if(always_unpowered)
		return FALSE
	if(!linked)
		return FALSE
	var/area/A = get_area(linked)
	ASSERT(!istype(A, /area/holodeck))
	return A.powered(chan)

/area/holodeck/usage(chan)
	if(!linked)
		return FALSE
	var/area/A = get_area(linked)
	ASSERT(!istype(A, /area/holodeck))
	return A.usage(chan)

/area/holodeck/addStaticPower(value, powerchannel)
	if(!linked)
		return
	var/area/A = get_area(linked)
	ASSERT(!istype(A, /area/holodeck))
	return A.addStaticPower(value,powerchannel)

/area/holodeck/use_power(amount, chan)
	if(!linked)
		return FALSE
	var/area/A = get_area(linked)
	ASSERT(!istype(A, /area/holodeck))
	return A.use_power(amount,chan)


/*
	This is the standard holodeck.  It is intended to allow you to
	blow off steam by doing stupid things like laying down, throwing
	spheres at holes, or bludgeoning people.
*/
/area/holodeck/rec_center
	name = "\improper Recreational Holodeck"

/area/holodeck/rec_center/offstation_one
	name = "\improper Recreational Holodeck"
