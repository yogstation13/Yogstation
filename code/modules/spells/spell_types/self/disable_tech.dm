/datum/action/cooldown/spell/emp
	name = "Emplosion"
	desc = "This spell emplodes an area."
	button_icon_state = "emp"
	sound = 'sound/weapons/zapbang.ogg'

	school = SCHOOL_EVOCATION

	/// The severity of the EMP
	var/severity = EMP_HEAVY
	/// The radius of the EMP
	var/radius = 3

/datum/action/cooldown/spell/emp/cast(atom/cast_on)
	. = ..()
	empulse(get_turf(cast_on), severity, radius)

/datum/action/cooldown/spell/emp/disable_tech
	name = "Disable Tech"
	desc = "This spell disables all weapons, cameras and most other technology in range."
	sound = 'sound/magic/disable_tech.ogg'

	cooldown_time = 40 SECONDS
	cooldown_reduction_per_rank = 5 SECONDS

	invocation = "NEC CANTIO"
	invocation_type = INVOCATION_SHOUT

	radius = 10
