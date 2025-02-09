/datum
	/// Lazylist of trait cascade targets. Don't modify this directly, refer to 'cascade_trait()' instead.
	var/list/_cascade_targets

/// Links 'trait' to 'target_trait', such that when 'trait' is added/removed 'target_trait' is too. Uses 'trait' as the source.
/datum/proc/cascade_trait(trait, target_trait)
	RegisterSignal(src, SIGNAL_ADDTRAIT(trait), PROC_REF(_cascade_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(trait), PROC_REF(_cascade_trait_loss))
	LAZYSET(_cascade_targets, trait, target_trait)

/datum/proc/_cascade_trait_gain(datum/source, trait)
	ADD_TRAIT(src, _cascade_targets[trait], trait)

/datum/proc/_cascade_trait_loss(datum/source, trait)
	REMOVE_TRAIT(src, _cascade_targets[trait], trait)
