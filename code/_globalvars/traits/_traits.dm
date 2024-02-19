// This file should contain every single global trait in the game in a type-based list, as well as any additional trait-related information that's useful to have on a global basis.
// This file is used in linting, so make sure to add everything alphabetically and what-not.
// Do consider adding your trait entry to the similar list in `admin_tooling.dm` if you want it to be accessible to admins (which is probably the case for 75% of traits).

// Please do note that there is absolutely no bearing on what traits are added to what subtype of `/datum`, this is just an easily referenceable list sorted by type.
// The only thing that truly matters about traits is the code that is built to handle the traits, and where that code is located. Nothing else.

GLOBAL_LIST_INIT(movement_type_trait_to_flag, list(
	TRAIT_MOVE_GROUND = GROUND,
	TRAIT_MOVE_FLYING = FLYING,
	TRAIT_MOVE_VENTCRAWLING = VENTCRAWLING,
	TRAIT_MOVE_FLOATING = FLOATING,
	))

GLOBAL_LIST_INIT(movement_type_addtrait_signals, set_movement_type_addtrait_signals())
GLOBAL_LIST_INIT(movement_type_removetrait_signals, set_movement_type_removetrait_signals())

/proc/set_movement_type_addtrait_signals(signal_prefix)
	. = list()
	for(var/trait in GLOB.movement_type_trait_to_flag)
		. += SIGNAL_ADDTRAIT(trait)

/proc/set_movement_type_removetrait_signals(signal_prefix)
	. = list()
	for(var/trait in GLOB.movement_type_trait_to_flag)
		. += SIGNAL_REMOVETRAIT(trait)
