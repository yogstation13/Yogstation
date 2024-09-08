/mob/living/carbon/human/register_init_signals()
	. = ..()
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_NOBLOOD), PROC_REF(on_lose_noblood_trait))

/mob/living/carbon/human/proc/on_lose_noblood_trait(datum/source)
	SIGNAL_HANDLER
	blood_volume = clamp(blood_volume, BLOOD_VOLUME_NORMAL, BLOOD_VOLUME_MAXIMUM - 1)
