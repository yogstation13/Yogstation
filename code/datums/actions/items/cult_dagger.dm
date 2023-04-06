/datum/action/item_action/cult_dagger
	name = "Draw Blood Rune"
	desc = "Use the ritual dagger to create a powerful blood rune"
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "draw"
	buttontooltipstyle = "cult"
	background_icon_state = "bg_demon"

/datum/action/item_action/cult_dagger/Grant(mob/M)
	if(iscultist(M))
		..()
		button.screen_loc = "6:157,4:-2"
		button.moved = "6:157,4:-2"
	else
		Remove(owner)

/datum/action/item_action/cult_dagger/Trigger()
	for(var/obj/item/H in owner.held_items) //In case we were already holding another dagger
		if(istype(H, /obj/item/melee/cultblade/dagger))
			H.attack_self(owner)
			return
	var/obj/item/I = target

	if(owner.can_equip(I, SLOT_HANDS))
		owner.temporarilyRemoveItemFromInventory(I)
		owner.put_in_hands(I)
		I.attack_self(owner)
		return

	if(!isliving(owner))
		to_chat(owner, span_warning("You lack the necessary living force for this action."))
		return

	if (owner.get_num_arms() <= 0)
		to_chat(owner, span_warning("You don't have any usable hands!"))
	else
		to_chat(owner, span_warning("Your hands are full!"))