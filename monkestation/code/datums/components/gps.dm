/datum/component/gps
	/// Can this GPS be targeted by a BSA?
	var/bsa_targetable = TRUE

/datum/component/gps/no_bsa
	bsa_targetable = FALSE

/datum/component/gps/item
	/// If TRUE, then this GPS needs to be calibrated to point to specific z-levels.
	var/requires_z_calibration = TRUE
	/// A lazy list of calibrated z-levels
	var/list/calibrated_zs

/// Checks to see if we can point in the general direction of a (different) z level.
/datum/component/gps/item/proc/can_point_to_z_level(z)
	return !requires_z_calibration || (z in calibrated_zs)
