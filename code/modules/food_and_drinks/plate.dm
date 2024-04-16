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
	var/smash_force = 10 //damage for head smashing
	var/const/duration = 13 // Directly relates to the 'knockdown' duration. Lowered by armor (i.e. helmets)


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
		I.pixel_y = min(text2num(click_params["icon-y"]) - 16, -placement_offset, max_height_offset)
		to_chat(user, span_notice("You place [I] on [src]."))
		AddToPlate(I, user)
		update_appearance(UPDATE_ICON)
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
	item_to_plate.plane = ABOVE_HUD_PLANE
	RegisterSignal(item_to_plate, COMSIG_MOVABLE_MOVED, PROC_REF(ItemMoved))
	RegisterSignal(item_to_plate, COMSIG_QDELETING, PROC_REF(ItemMoved))

///This proc cleans up any signals on the item when it is removed from a plate, and ensures it has the correct state again.
/obj/item/plate/proc/ItemRemovedFromPlate(obj/item/removed_item)

	vis_contents -= removed_item
	removed_item.vis_flags &= ~VIS_INHERIT_PLANE
	removed_item.layer = OBJ_LAYER

	UnregisterSignal(removed_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))

///This proc is called by signals that remove the food from the plate.
/obj/item/plate/proc/ItemMoved(obj/item/moved_item, forced)
	SIGNAL_HANDLER
	ItemRemovedFromPlate(moved_item)

#define PLATE_SHARD_PIECES 5

/obj/item/plate/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(.)
		return
	var/generator/scatter_gen = generator("circle", 0, 48, NORMAL_RAND)
	var/scatter_turf = get_turf(hit_atom)

	for(var/obj/item/scattered_item as anything in contents)
		ItemRemovedFromPlate(scattered_item)
		scattered_item.forceMove(scatter_turf)
		var/list/scatter_vector = scatter_gen.Rand()
		scattered_item.pixel_x = scatter_vector[1]
		scattered_item.pixel_y = scatter_vector[2]

	for(var/iteration in 1 to PLATE_SHARD_PIECES)
		var/obj/item/plate_shard/shard = new(scatter_turf)
		shard.icon_state = "[shard.base_icon_state][iteration]"
		shard.pixel_x = rand(-4, 4)
		shard.pixel_y = rand(-4, 4)
	playsound(scatter_turf, 'sound/items/ceramic_break.ogg', 60, TRUE)
	qdel(src)

//head smashing (funny)
/obj/item/plate/attack(mob/living/target, mob/living/user)
	var/obj/item/bodypart/affecting = user.zone_selected

	if(!target)
		return
	if(user.a_intent != INTENT_HARM || affecting != BODY_ZONE_HEAD)
		return ..()
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_warning("You don't want to harm [target]!"))
		return

	var/armor_block = 0
	var/armor_duration = 0 //The more force the plate has, the longer the duration.

	if(ishuman(target))

		var/mob/living/carbon/human/H = target
		var/headarmor = 0 // Target's head armor
		armor_block = H.run_armor_check(affecting, MELEE,"","",armour_penetration)

		if(istype(H.head, /obj/item/clothing/head))
			headarmor = H.head.armor.melee
		else
			headarmor = 0

		armor_duration = (duration - headarmor) + force //knockdown duration

	else
		armor_block = target.run_armor_check(affecting, MELEE)
		armor_duration = duration + force

	armor_block = min(90,armor_block)
	target.apply_damage(smash_force, BRUTE, affecting, armor_block)
	target.apply_effect(min(armor_duration, 200) , EFFECT_KNOCKDOWN)

	//attack message
	if(target != user)
		target.visible_message(span_danger("[user] has smashed [target] on the head with a [src.name]!"), \
				span_userdanger("[user] has smashed [target] on the head with a [src.name]!"))
	else
		user.visible_message(span_danger("[target] hits [target.p_them()]self with a [src.name] on the head!"), \
				span_userdanger("[target] hits [target.p_them()]self with a [src.name] on the head!"))

	log_combat(user, target, "attacked", src)

	throw_impact(target, user) //plate smash

	return

/obj/item/plate/large
	name = "buffet plate"
	desc = "A large plate made for the professional catering industry but also appreciated by mukbangers and other persons of considerable size and heft."
	icon_state = "plate_large"
	max_items = 12
	max_x_offset = 8
	max_height_offset = 12
	smash_force = 12

/obj/item/plate/small
	name = "appetizer plate"
	desc = "A small plate, perfect for appetizers, desserts or trendy modern cusine."
	icon_state = "plate_small"
	max_items = 2
	max_x_offset = 3
	max_height_offset = 4
	smash_force = 5

/obj/item/plate_shard
	name = "ceramic shard"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "plate_shard1"
	base_icon_state = "plate_shard"
	w_class = WEIGHT_CLASS_TINY
	force = 5
	throwforce = 5
	sharpness = SHARP_EDGED

/obj/item/plate_shard/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, min_damage = force)

#undef PLATE_SHARD_PIECES
