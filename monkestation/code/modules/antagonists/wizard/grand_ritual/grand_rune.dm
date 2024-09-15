#define GRAND_RUNE_INVOKES_TO_COMPLETE 3 //moved from the upstream file to here as this is where its used now

/obj/effect/grand_rune
	///Weakref to our owning mind
	var/datum/weakref/owning_mind
	///How many times this rune needs to be invoked to complete
	var/invokes_needed = GRAND_RUNE_INVOKES_TO_COMPLETE

/obj/effect/grand_rune/add_channel_effect(mob/living/user)
	. = ..()
	ADD_TRAIT(user, TRAIT_MOVE_FLYING, REF(src))

/obj/effect/grand_rune/remove_channel_effect(mob/living/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_MOVE_FLYING, REF(src))

#undef GRAND_RUNE_INVOKES_TO_COMPLETE
