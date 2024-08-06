/datum/species/jelly/slime/on_species_loss(mob/living/carbon/C)
	UnregisterSignal(C, COMSIG_MOB_ALTCLICKON)
	..()

/datum/species/jelly/slime/on_species_gain(mob/living/carbon/C)
	..()
	// Guess what I'm doing
	// using component signals on something that isn't a component
	// maybe we shouldn't call them component signals if they can be used for other things, maybe...
	// hmmm.... what if we called it an event handler like any sane environment.
	RegisterSignal(C, COMSIG_MOB_ALTCLICKON, PROC_REF(handle_altclick))

/datum/species/jelly/slime/proc/handle_altclick(mob/living/carbon/human/M, mob/living/carbon/human/target)
	if(M && M.mind)
		var/datum/action/innate/swap_body/this_swap = locate() in instantiated_abilities
		if(!this_swap || !this_swap.can_swap(target))
			return
		this_swap.swap_to_dupe(M.mind, target)
		return COMSIG_MOB_CANCEL_CLICKON

/datum/action/innate/swap_body/swap_to_dupe(datum/mind/M, mob/living/carbon/human/dupe)
	var/mob/living/carbon/human/old = M.current
	. = ..()
	if(old != M.current && dupe == M.current && isslimeperson(dupe))
		var/datum/action/innate/swap_body/other_swap = locate() in dupe.actions
		if(!other_swap)
			return
		// theoretically the transfer_to proc is supposed to transfer the ui from the mob.
		// so I try to get the UI from one of the two mobs and schlump it over to the new action button
		var/datum/tgui/ui = SStgui.get_open_ui(old, src, "main") || SStgui.get_open_ui(dupe, src, "main")
		if(ui)
			// transfer the UI over. This code is slightly hacky but it fixes the problem
			// I'd use SStgui.on_transfer but that doesn't let you transfer the src_object as well s
			SStgui.on_close(ui) // basically removes it from lists is all this proc does.
			ui.user = dupe
			ui.src_object = other_swap
			SStgui.on_open(ui) // stick it back on the lists
			ui.process(force = TRUE)

/datum/action/innate/split_body/make_dupe()
	var/mob/living/carbon/human/old = owner
	var/datum/mind/M = old.mind
	. = ..()
	var/mob/living/carbon/human/dupe = M.current
	if(old != dupe && isslimeperson(dupe) && isslimeperson(old))
		// transfer the swap-body ui if it's open
		var/datum/action/innate/swap_body/this_swap = locate() in old.actions
		var/datum/action/innate/swap_body/other_swap = locate() in dupe.actions
		if(!this_swap && !other_swap)
			return
		var/datum/tgui/ui = SStgui.get_open_ui(old, this_swap, "main") || SStgui.get_open_ui(dupe, this_swap, "main")
		if(ui)
			SStgui.on_close(ui) // basically removes it from lists is all this proc does.
			ui.user = dupe
			ui.src_object = other_swap
			SStgui.on_open(ui) // stick it back on the lists
			ui.process(force = TRUE)
