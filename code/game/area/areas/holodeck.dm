/area/holodeck
	name = "Holodeck"
	icon_state = "Holodeck"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	flags_1 = NONE

	var/obj/machinery/computer/holodeck/linked
	var/restricted = 0 // if true, program goes on emag list
	var/minimum_sec_level = SEC_LEVEL_GREEN //override this var if you want the program to be locked to a different alert-level (eg. SEC_LEVEL_BLUE, SEC_LEVEL_RED, SEC_LEVEL_DELTA)

/*
	Power tracking: Use the holodeck computer's power grid
	Asserts are to avoid the inevitable infinite loops
*/
/area/holodeck/powered(chan)
	if(!requires_power)
		return 1
	if(always_unpowered)
		return 0
	if(!linked)
		return 0
	var/area/A = get_area(linked)
	ASSERT(!istype(A, /area/holodeck))
	return A.powered(chan)

/area/holodeck/usage(chan)
	if(!linked)
		return 0
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
		return 0
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
