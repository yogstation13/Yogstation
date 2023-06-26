/datum/action/cooldown/spell/conjure_item/arrow
	name = "Summon Arrow"
	desc = "A spell that summons a sharp arrow in the user's hand, ready to be shot out of a bow.  Can be quickly casted by pressing the 'quick-equip' key on an empty hand."
	button_icon = 'icons/obj/ammo.dmi'
	button_icon_state = "arrow"
	invocation_type = INVOCATION_EMOTE
	invocation = "snap"
	item_type = /obj/item/ammo_casing/reusable/arrow
	cooldown_time = 15 SECONDS
	cooldown_reduction_per_rank = 3.5 SECONDS
	delete_old = FALSE

/datum/action/cooldown/spell/conjure_item/arrow/Grant(mob/living/user)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_QUICK_EQUIP, PROC_REF(on_quick_equip))

/datum/action/cooldown/spell/conjure_item/arrow/Remove(mob/living/user)
	UnregisterSignal(user, COMSIG_MOB_QUICK_EQUIP)
	return ..()

/datum/action/cooldown/spell/conjure_item/arrow/proc/on_quick_equip(obj/item/held_item)
	SIGNAL_HANDLER

	if(isitem(held_item) || isitem(owner.get_active_held_item()))
		return

	Trigger()

	if(owner.get_active_held_item())
		return COMPONENT_BLOCK_QUICK_EQUIP

/datum/action/cooldown/spell/conjure_item/arrow/magic
	name = "Summon Magic Arrow"
	desc = "A spell that summons a homing arrow in the user's hand, ready to be shot out of a bow that quickly becomes dull after hitting something.  Can be quickly casted by pressing the 'quick-equip' key on an empty hand."
	button_icon_state = "arrow_magic"
	item_type = /obj/item/ammo_casing/reusable/arrow/magic
	cooldown_reduction_per_rank = 3.75 SECONDS
