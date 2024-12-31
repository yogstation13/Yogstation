/datum/quirk/clown_disbelief
	name = "Clown Disbelief"
	desc = "You never really believed in clowns."
	value = 0
	gain_text = span_danger("You realize clowns aren't real after all.")
	lose_text = span_notice("You let go of your stubborn disbelief in clowns.")
	medical_record_text = "Patient has an unshakable disbelief in clowns, to the point of being seemingly incapable of perceiving them."
	mob_trait = TRAIT_CLOWN_DISBELIEVER
	icon = FA_ICON_HIPPO

/datum/quirk/clown_disbelief/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examine_more))

/datum/quirk/clown_disbelief/remove()
	UnregisterSignal(quirk_holder, COMSIG_ATOM_EXAMINE_MORE)

/datum/quirk/clown_disbelief/proc/on_examine_more(mob/unbeliever, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(istype(user.mind?.assigned_role, /datum/job/clown))
		examine_list += span_warning("[unbeliever.p_They()] [unbeliever.p_do()]n't seem to notice you!")

/datum/atom_hud/alternate_appearance/basic/clown_disbelief

/datum/atom_hud/alternate_appearance/basic/clown_disbelief/mobShouldSee(mob/target)
	return HAS_TRAIT(target, TRAIT_CLOWN_DISBELIEVER)
