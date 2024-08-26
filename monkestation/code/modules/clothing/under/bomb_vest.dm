/obj/item/clothing/bomb_vest
	name = "bomb vest"
	desc = "A bomb that can be strapped to peoples chest. Cant be taken off by the user..."

	icon = 'monkestation/icons/obj/clothing/bomb_vest.dmi'
	worn_icon = 'monkestation/icons/obj/clothing/bomb_vest.dmi'
	icon_state = "obj_off"
	worn_icon_state = "worn_off"

	body_parts_covered = CHEST
	slot_flags = ITEM_SLOT_OCLOTHING

	var/obj/item/transfer_valve/boombox //The TTV that goes boom

	var/ready_to_blow = FALSE
/obj/item/clothing/bomb_vest/Destroy()
	QDEL_NULL(boombox)
	return ..()
/obj/item/clothing/bomb_vest/Move()
	. = ..()
	if(boombox)
		boombox.Move()

/obj/item/clothing/bomb_vest/MouseDrop(atom/over_object)
	var/mob/M = usr

	if(M.contents.Find(src))
		return //Nuh-uh
	. = ..()

/obj/item/clothing/bomb_vest/mob_can_equip(mob/living/M, slot, disable_warning, bypass_equip_delay_self, ignore_equipped)
	if(!slot && ready_to_blow)
		return FALSE
	. = ..()


/obj/item/clothing/bomb_vest/Initialize(mapload)
	. = ..()
	boombox = new(src)
	RegisterSignal(src, COMSIG_ITEM_PRE_UNEQUIP, PROC_REF(on_unequipped))

/obj/item/clothing/bomb_vest/doStrip(mob/stripper, mob/owner)
	if(prob(25) && ready_to_blow && boombox)
		boombox.process_activation(null) //Uh oh, boom time.
	. = ..()
/obj/item/clothing/bomb_vest/proc/on_unequipped()
	SIGNAL_HANDLER
	var/mob/M = usr
	if(M && ready_to_blow)
		if(M.contents.Find(src))
			return COMPONENT_ITEM_BLOCK_UNEQUIP
	return

/obj/item/clothing/bomb_vest/attackby(obj/item/W, mob/user, params)
	if(user.contents.Find(src))
		return //Nope.
	if(W.tool_behaviour == TOOL_WRENCH)
		if(ready_to_blow)
			ready_to_blow = FALSE
			icon_state = "obj_off"
			worn_icon_state = "worn_off"
			to_chat(user, span_warning("You disarm the [src]!"))
		else
			ready_to_blow = TRUE
			icon_state = "obj_on"
			worn_icon_state = "worn_on"
			to_chat(user, span_warning("You arm the [src]!"))
		return
	if(istype(W,/obj/item/assembly))
		boombox.attackby(W,user)
		return TRUE
	if(W.tool_behaviour == TOOL_WIRECUTTER)
		boombox.forceMove(user)
		boombox = null
		Destroy()
		return
	if(istype(W, /obj/item/tank))
		if(boombox.tank_one && boombox.tank_two)
			to_chat(user, span_warning("There are already two tanks attached, remove one first!"))
			return
		if(!boombox.tank_one)
			if(!user.transferItemToLoc(W, src))
				return
			boombox.tank_one = W
			to_chat(user, span_notice("You attach the tank to the [src]."))
		else if(!boombox.tank_two)
			if(!user.transferItemToLoc(W, src))
				return
			boombox.tank_two = W
			to_chat(user, span_notice("You attach the tank to the [src]."))
	return

/datum/crafting_recipe/bomb_vest
	name = "Bomb Vest"
	desc = "Crudely straps an EMPTY tank transfer valve to someones chest. Can't be un-equiped by the wearer once armed with a wrench. Otherwise, works like a normal Tank Transfer Valve."

	result = /obj/item/clothing/bomb_vest

	reqs = list(/obj/item/transfer_valve = 1,/obj/item/stack/cable_coil = 5,/obj/item/stack/sheet/iron = 2)

