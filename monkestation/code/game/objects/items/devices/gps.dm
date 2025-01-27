/obj/item/gps
	/// If TRUE, then this GPS needs to be calibrated to point to specific z-levels.
	var/requires_z_calibration = TRUE

/obj/item/gps/Initialize(mapload)
	. = ..()
	add_gps_component(mapload)

/// Adds the GPS component to this item.
/obj/item/gps/proc/add_gps_component(mapload = FALSE)
	var/list/calibrate_zs
	if(requires_z_calibration) // don't waste time with this if we don't need z-calibration in the first place
		var/turf/our_turf = get_turf(src)
		if(our_turf)
			if(is_station_level(our_turf.z))
				calibrate_zs = SSmapping.levels_by_trait(ZTRAIT_STATION)
			else if(mapload)
				calibrate_zs = list(our_turf.z)
	AddComponent(/datum/component/gps/item, gpstag, requires_z_calibration = requires_z_calibration, calibrate_zs = calibrate_zs)

/obj/item/gps/advanced
	name = "advanced global positioning system"
	desc = "An advanced variant of the usual GPS, capable of navigating across vast distances of space without a calibration process."
	icon = 'monkestation/icons/obj/devices/tracker.dmi'
	icon_state = "gps-a"
	requires_z_calibration = FALSE
	custom_materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 5,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/bluespace = SMALL_MATERIAL_AMOUNT * 1.5,
	)

/obj/item/gps/medical
	desc = "A variention on the standard GPS Model, purposed for finding signals of those who have been lost. This one is in blue!"
	icon = 'monkestation/icons/obj/devices/tracker.dmi'
	icon_state = "gps-m"
	gpstag = "PARA0"

