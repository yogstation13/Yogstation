/obj/item/firing_pin/cargo //Firing pin for use in cargo only
	name = "cargo-locked firing pin"
	desc = "A firing pin that scans the area to check if it is within the station's cargo bay or warehouse before firing."
	fail_message = "Area check failed"
	var/list/station_cargo = list(
		/area/station/cargo/warehouse,
		/area/station/cargo/storage,
		/area/station/cargo/office,
		/area/station/cargo/sorting,
	)

//Checks to see if the user in cargo or it's warehouse
/obj/item/firing_pin/cargo/pin_auth(mob/living/user)
	if(!istype(user))
		return FALSE
	if (is_type_in_list(get_area(user), station_cargo))
		return TRUE
	return FALSE

/obj/item/firing_pin/cargo/unremovable
	pin_removable = FALSE
