/mob/living/register_init_signals()
	. = ..()
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_IGNOREDAMAGESLOWDOWN), PROC_REF(on_ignoredamageslowdown_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_IGNOREDAMAGESLOWDOWN), PROC_REF(on_ignoredamageslowdown_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_CANT_STAMCRIT), PROC_REF(on_cant_stamcrit_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_CANT_STAMCRIT), PROC_REF(on_cant_stamcrit_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_CLOWN_DISBELIEVER), PROC_REF(on_clown_disbeliever_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_CLOWN_DISBELIEVER), PROC_REF(on_clown_disbeliever_trait_loss))

/mob/living/proc/on_ignoredamageslowdown_trait_gain(datum/source)
	SIGNAL_HANDLER
	add_movespeed_mod_immunities(TRAIT_IGNOREDAMAGESLOWDOWN, /datum/movespeed_modifier/damage_slowdown)

/mob/living/proc/on_ignoredamageslowdown_trait_loss(datum/source)
	SIGNAL_HANDLER
	remove_movespeed_mod_immunities(TRAIT_IGNOREDAMAGESLOWDOWN, /datum/movespeed_modifier/damage_slowdown)

/mob/living/proc/on_cant_stamcrit_trait_gain(datum/source)
	SIGNAL_HANDLER
	if(HAS_TRAIT_FROM(src, TRAIT_INCAPACITATED, STAMINA))
		exit_stamina_stun()

/mob/living/proc/on_cant_stamcrit_trait_loss(datum/source)
	SIGNAL_HANDLER
	on_stamina_update()

/mob/living/proc/on_clown_disbeliever_trait_gain(datum/source)
	SIGNAL_HANDLER
	for(var/datum/atom_hud/alternate_appearance/basic/clown_disbelief/clown_to_hide in GLOB.active_alternate_appearances)
		clown_to_hide.show_to(src)

/mob/living/proc/on_clown_disbeliever_trait_loss(datum/source)
	SIGNAL_HANDLER
	for(var/datum/atom_hud/alternate_appearance/basic/clown_disbelief/clown_to_hide in GLOB.active_alternate_appearances)
		clown_to_hide.hide_from(src)
