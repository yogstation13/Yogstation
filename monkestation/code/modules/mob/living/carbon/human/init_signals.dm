/mob/living/carbon/human/register_init_signals()
	. = ..()
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_NOBLOOD), PROC_REF(on_gain_noblood_trait))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_NOBLOOD), PROC_REF(on_lose_noblood_trait))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_FAT), PROC_REF(on_trait_fat_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_FAT), PROC_REF(on_trait_fat_loss))

/mob/living/carbon/human/proc/on_gain_noblood_trait(datum/source)
	SIGNAL_HANDLER
	blood_volume = BLOOD_VOLUME_NORMAL

/mob/living/carbon/human/proc/on_lose_noblood_trait(datum/source)
	SIGNAL_HANDLER
	blood_volume = BLOOD_VOLUME_NORMAL

/mob/living/carbon/human/proc/on_trait_fat_gain(datum/source)
	SIGNAL_HANDLER
	to_chat(src, span_danger("You suddenly feel blubbery!"))
	add_movespeed_modifier(/datum/movespeed_modifier/obesity)
	update_worn_undersuit()
	update_worn_oversuit()

/mob/living/carbon/human/proc/on_trait_fat_loss(datum/source)
	SIGNAL_HANDLER
	to_chat(src, span_notice("You feel fit again!"))
	remove_movespeed_modifier(/datum/movespeed_modifier/obesity)
	update_worn_undersuit()
	update_worn_oversuit()
