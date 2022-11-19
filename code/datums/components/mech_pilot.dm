/// A component for clothes that affect one's ability to pilot mechs
/datum/component/mech_pilot
	/// Modifier to how fast a mech is piloted, 1 is 100%. lower is percentage faster
	var/piloting_speed = 1

/datum/component/mech_pilot/Initialize(_piloting_speed = 1)
	piloting_speed = _piloting_speed
