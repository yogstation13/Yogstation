/*
	FUN ZONE OF ADMIN LISTINGS
	Try to keep this in sync with __DEFINES/traits.dm
	quirks have it's own panel so we don't need them here.
*/
GLOBAL_LIST_INIT(admin_visible_traits, list(
	/atom/movable = list(
		"TRAIT_ASHSTORM_IMMUNE" = TRAIT_ASHSTORM_IMMUNE,
	),
	/atom/movable = list(
		"TRAIT_RUNECHAT_HIDDEN" = TRAIT_RUNECHAT_HIDDEN,
	),
	/mob = list(
		"TRAIT_ABDUCTOR_SCIENTIST_TRAINING" = TRAIT_ABDUCTOR_SCIENTIST_TRAINING,
		"TRAIT_ANTIMAGIC" = TRAIT_ANTIMAGIC,
		"TRAIT_BOMBIMMUNE" = TRAIT_BOMBIMMUNE,
		"TRAIT_DEAF" = TRAIT_DEAF,
		"TRAIT_HOLY" = TRAIT_HOLY,
		"TRAIT_NO_SOUL" = TRAIT_NO_SOUL,
	),
	/obj/item = list(
		"TRAIT_NODROP" = TRAIT_NODROP,
		"TRAIT_T_RAY_VISIBLE" = TRAIT_T_RAY_VISIBLE,
	),
	/obj/item/organ/liver = list(
		"TRAIT_BALLMER_SCIENTIST" = TRAIT_BALLMER_SCIENTIST,
	),
))
GLOBAL_LIST_INIT(traits_by_type, list(
	/mob = list(/atom/movable = list(
		"TRAIT_MOVE_PHASING" = TRAIT_MOVE_PHASING,
	))))
/// value -> trait name, generated on use from trait_by_type global
GLOBAL_LIST(trait_name_map)

/// value -> trait name, generated as needed for adminning.
GLOBAL_LIST(admin_trait_name_map)

/proc/generate_admin_trait_name_map()
	. = list()
	for(var/key in GLOB.admin_visible_traits)
		for(var/tname in GLOB.admin_visible_traits[key])
			var/val = GLOB.admin_visible_traits[key][tname]
			.[val] = tname

	return .


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
