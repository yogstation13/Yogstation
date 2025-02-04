/// This test ensures that all vendors that spawn on-station can be constructed via a vendor circuit board.
/datum/unit_test/vendor_boards

/datum/unit_test/vendor_boards/Run()
	var/obj/item/circuitboard/machine/vendor/dummy_board = new
	var/list/vending_names_paths = dummy_board.vending_names_paths.Copy()
	QDEL_NULL(dummy_board)

	// 'cuz there's various subtypes of the same vendor which are pretty much the same thing,
	// we're gonna check refill canister types rather than vendor types.
	var/list/valid_vendor_refills = list()
	for(var/obj/machinery/vending/vendor_type as anything in vending_names_paths)
		if(isnull(vendor_type::refill_canister))
			TEST_FAIL("[vendor_type] ([vendor_type::name]) does not have a refill_canister set, despite the fact it can be constructed from a vendor board!")
		else
			valid_vendor_refills |= vendor_type::refill_canister

	var/list/checked_types = list() // just to avoid duplicate errors for the same exact vendor type.
	for(var/obj/machinery/vending/vendor as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/vending))
		if(!is_station_level(vendor.loc?.z) || checked_types[vendor.type])
			continue
		if(vendor.circuit != /obj/machinery/vending::circuit) // skip anything using its own different board
			continue
		checked_types[vendor.type] = TRUE
		if(!(vendor.refill_canister in valid_vendor_refills))
			TEST_FAIL("[vendor.type] (using [vendor.refill_canister]) not found in possible constructible vending machines, despite being mapped on-station!")
