/atom
	///any atom that uses integrity and can be damaged must set this to true, otherwise the integrity procs will throw an error
	var/uses_integrity = FALSE
	///Armor datum used by the atom
	var/datum/armor/armor
	///Current integrity, defaults to max_integrity on init
	VAR_PRIVATE/atom_integrity
	///Maximum integrity
	var/max_integrity = 500
	///Integrity level when this atom will "break" (whatever that means) 0 if we have no special broken behavior, otherwise is a percentage of at what point the atom breaks. 0.5 being 50%
	var/integrity_failure = 0
	///Damage under this value will be completely ignored
	var/damage_deflection = 0

	var/resistance_flags = NONE // INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ON_FIRE | UNACIDABLE | ACID_PROOF
