/obj/item/melee/sword
	name = "sword"
	desc = "A simple sword, hand-forged from smaller blades."
	icon = 'modular_skyrat/icons/obj/vg_weaponsmithing.dmi'
	righthand_file = 'modular_skyrat/icons/mob/inhands/vg/vg_righthand.dmi'
	lefthand_file = 'modular_skyrat/icons/mob/inhands/vg/vg_lefthand.dmi'
	icon_state = "sword"
	item_state = "sword"
	w_class = WEIGHT_CLASS_BULKY
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/belt.dmi'
	force = 15
	sharpness = IS_SHARP
	hitsound = 'modular_skyrat/sound/weapons/bloodyslice.ogg'
	var/obj/item/reagent_containers/hypospray/poison

/obj/item/melee/sword/Initialize()
	..()
	AddElement(/datum/element/sword_point)

/obj/item/melee/sword/afterattack(atom/target, mob/user, proximity)
	if(proximity && isliving(target))
		var/mob/living/victim = target
		if(poison)
			poison.reagents.trans_to(victim.reagents, 5)

/obj/item/melee/sword/update_icon()
	cut_overlays()
	if(poison)
		var/mutable_appearance/sword_overlay = mutable_appearance(icon, "sword_hypo_overlay")
		add_overlay(sword_overlay)

/obj/item/melee/sword/get_worn_belt_overlay()
	return mutable_appearance('modular_skyrat/icons/mob/clothing/belt.dmi', icon_state)

/obj/item/melee/sword/attack_self(mob/user)
	. = ..()
	if(poison)
		poison.forceMove(user.loc)
		poison = null
		update_icon()

/obj/item/melee/sword/attackby(obj/item/I, mob/living/user)
	. = ..()
	if(istype(I, /obj/item/reagent_containers/hypospray))
		if(!poison)
			I.forceMove(src)
			poison = I
			update_icon()
	else if(istype(I, /obj/item/large_metal_blade) && !istype(src, /obj/item/melee/sword/executioner))
		qdel(I)
		var/obj/item/melee/sword/executioner/E = new (get_turf(user))
		if(poison)
			poison.forceMove(E)
			E.poison = poison
		user.put_in_hands(E)
		poison = null
		qdel(src)
	else if(istype(I, /obj/item/metal_blade) && !istype(src, /obj/item/melee/sword/shortsword))
		qdel(I)
		var/obj/item/melee/sword/shortsword/S = new (get_turf(user))
		if(poison)
			poison.forceMove(S)
			S.poison = poison
		user.put_in_hands(S)
		poison = null
		qdel(src)

/obj/item/melee/sword/executioner
	name = "executioner's sword"
	desc = "A huge sword. The top third of the blade seems weaker than the rest of it."
	force = 5
	hitsound = 'modular_skyrat/sound/weapons/smash.ogg'
	icon_state = "executioners_sword"
	item_state = "executioners_sword"
	sharpness = IS_SHARP
	var/delimb_chance = 15

/obj/item/melee/sword/executioner/afterattack(atom/target, mob/living/user, proximity)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		var/obj/item/bodypart/BP = C.get_bodypart(check_zone(user.zone_selected))
		if(prob(delimb_chance))
			C.visible_message("<span class='danger'>[C]'s [BP] gets completely chopped off by \the [src]!</span>")
			BP.dismember(BRUTE)
	if(proximity)
		user.changeNext_move(CLICK_CD_MELEE * 2.5)

/obj/item/melee/sword/shortsword
	name = "shortsword"
	desc = "A short-bladed sword, used for close combat agility, over overpowering your foes."
	icon_state = "shortsword"
	item_state = "sword"
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = "sound/weapons/slash.ogg"
	force = 12

/obj/item/melee/sword/shortsword/afterattack(atom/target, mob/living/user, proximity)
	. = ..()
	if(proximity)
		user.changeNext_move(CLICK_CD_MELEE * 0.75)
