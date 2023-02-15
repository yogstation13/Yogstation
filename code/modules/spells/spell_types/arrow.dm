/obj/effect/proc_holder/spell/targeted/conjure_item/arrow
	name = "Summon Arrow"
	desc = "A spell that summons a sharp arrow in the user's hand, ready to be shot out of a bow.  Can be quickly casted by pressing the 'quick-equip' key on an empty hand."
	invocation_type = SPELL_INVOCATION_EMOTE
	invocation = "snap"
	item_type = /obj/item/ammo_casing/reusable/arrow
	charge_max = 15 SECONDS
	cooldown_min = 1 SECONDS
	delete_old = FALSE
	drop_currently_held = FALSE

/obj/effect/proc_holder/spell/targeted/conjure_item/arrow/on_gain(mob/living/user)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_QUICK_EQUIP, PROC_REF(on_quick_equip))

/obj/effect/proc_holder/spell/targeted/conjure_item/arrow/on_lose(mob/living/user)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_QUICK_EQUIP)

/obj/effect/proc_holder/spell/targeted/conjure_item/arrow/proc/on_quick_equip(obj/item/held_item)
	if(held_item || usr.get_active_held_item())
		return
	Click()
	if(usr.get_active_held_item())
		return COMPONENT_BLOCK_QUICK_EQUIP

/obj/effect/proc_holder/spell/targeted/conjure_item/arrow/magic
	name = "Summon Magic Arrow"
	desc = "A spell that summons a homing arrow in the user's hand, ready to be shot out of a bow that quickly becomes dull after hitting something.  Can be quickly casted by pressing the 'quick-equip' key on an empty hand."
	item_type = /obj/item/ammo_casing/reusable/arrow/magic
	charge_max = 15 SECONDS
	cooldown_min = 0.25 SECONDS
