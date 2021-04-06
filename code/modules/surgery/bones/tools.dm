/obj/item/stack/medical/splint
	name = "splint"
	desc = "Works wonders on broken bones."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "splints"
	materials = list(/datum/material/iron=4000)
	w_class = WEIGHT_CLASS_SMALL
	self_delay = 30
	//Multiplier
	var/healing_speed = 1
	amount = 3
	max_amount = 3

/obj/item/stack/medical/splint/heal(mob/living/M, mob/user)
	if(M.stat == DEAD)
		to_chat(user, "<span class='notice'> [M] is dead. You can not help [M.p_them()]!</span>")
		return
	if(iscarbon(M))
		return heal_carbon(M, user, 0, 0)
	to_chat(user, "<span class='notice'>You can't help [M] with the \the [src]!</span>")

/obj/item/stack/medical/splint/heal_carbon(mob/living/carbon/C, mob/user, brute, burn)
	var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(user.zone_selected))
	if(!affecting) //Missing limb?
		to_chat(user, "<span class='warning'>[C] doesn't have \a [parse_zone(user.zone_selected)]!</span>")
		return
	if(!affecting.bone)
		to_chat(user, "<span class='warning'>[C] doesn't have a bone in their [parse_zone(user.zone_selected)]!</span>")
		return
	if(!affecting.bone.damage_severity > NO_FRACTURE)
		to_chat(user, "<span class='warning'>You can't find a broken bone in [C]'s [parse_zone(user.zone_selected)]!</span>")
		return
	affecting.bone.splinted = TRUE
	affecting.bone.splint_speed = healing_speed
	return TRUE

/obj/item/stack/medical/splint/improvised
	name = "splint"
	desc = "Works wonders on broken bones."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "splints"
	materials = list(/datum/material/iron=4000)
	w_class = WEIGHT_CLASS_SMALL
	healing_speed = 0.45