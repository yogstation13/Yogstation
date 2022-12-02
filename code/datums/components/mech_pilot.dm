/// A component for clothes that affect one's ability to pilot mechs
/datum/component/mech_pilot
	/// Modifier of mech delay, based on percentage 1 = 100%. lower is faster
	var/piloting_speed = 1

/datum/component/mech_pilot/Initialize(_piloting_speed = 1)
	piloting_speed = _piloting_speed
