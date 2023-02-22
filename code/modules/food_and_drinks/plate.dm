/obj/item/plate
	name = "plate"
	desc = "Holds food, powerful. Good for morale when you're not eating your spaghetti off of a desk."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "plate"
	w_class = WEIGHT_CLASS_BULKY //No backpack.
	///How many things fit on this plate?
	var/max_items = 8
	///The offset from side to side the food items can have on the plate
	var/max_x_offset = 4
	///The max height offset the food can reach on the plate
	var/max_height_offset = 5
	///Offset of where the click is calculated from, due to how food is positioned in their DMIs.
	var/placement_offset = -12


/obj/item/plate/attackby(obj/item/I, mob/user, params)
	if(!istype(I,/obj/item/reagent_containers/food))
		to_chat(user, span_notice("[src] is made for food, and food alone!"))
		return
	if(contents.len >= max_items)
		to_chat(user, span_notice("[src] can't fit more items!"))
		return
	if(user.transferItemToLoc(I, src))
		var/list/click_params = params2list(params)
		//Center the icon where the user clicked.
		if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
			return
		//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
		I.pixel_x = clamp(text2num(click_params["icon-x"]) - 16, -max_x_offset, max_x_offset)
		I.pixel_y = clamp(text2num(click_params["icon-y"]) - 16, -placement_offset, max_height_offset)
		to_chat(user, span_notice("You place [I] on [src]."))
		AddToPlate(I, user)
		update_icon()
	else
		return ..()


/*/obj/item/plate/attack_hand(mob/user)
	if(!contents.len || !isturf(loc))
		user.put_in_hands(src)
		return TRUE
	to_chat(user,"hm1")
	if(!iscarbon(user))
		return
	var/obj/item/reagent_containers/food/object_to_eat = contents[1]
	object_to_eat.attack(user,user) //eat eat eat
	to_chat(user,"hm2")
	return TRUE //No normal attack
	*/

/obj/item/plate/pre_attack(atom/A, mob/living/user, params)
	if(!iscarbon(A))
		return TRUE
	if(!contents.len)
		return TRUE
	var/obj/item/object_to_eat = pick(contents)
	A.attackby(object_to_eat, user)
	return FALSE //No normal attack

///This proc adds the food to viscontents and makes sure it can deregister if this changes.
/obj/item/plate/proc/AddToPlate(obj/item/item_to_plate)
	vis_contents += item_to_plate
	item_to_plate.vis_flags |= VIS_INHERIT_PLANE
	item_to_plate.layer = ABOVE_HUD_LAYER
	RegisterSignal(item_to_plate, COMSIG_MOVABLE_MOVED, .proc/ItemMoved)
	RegisterSignal(item_to_plate, COMSIG_PARENT_QDELETING, .proc/ItemMoved)

///This proc cleans up any signals on the item when it is removed from a plate, and ensures it has the correct state again.
/obj/item/plate/proc/ItemRemovedFromPlate(obj/item/removed_item)

	vis_contents -= removed_item
	removed_item.vis_flags &= ~VIS_INHERIT_PLANE
	removed_item.layer = OBJ_LAYER

	UnregisterSignal(removed_item, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))

///This proc is called by signals that remove the food from the plate.
/obj/item/plate/proc/ItemMoved(obj/item/moved_item, forced)
	SIGNAL_HANDLER
	ItemRemovedFromPlate(moved_item)
