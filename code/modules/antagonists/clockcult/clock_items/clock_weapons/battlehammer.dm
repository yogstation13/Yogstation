/obj/item/clockwork/weapon/brass_battlehammer
	name = "brass battle-hammer"
	desc = "A brass hammer glowing with energy."
	icon_state = "ratvarian_hammer"
	force = 15
	throwforce = 10
	armour_penetration = -15
	sharpness = SHARP_NONE
	attack_verb = list("bashed", "smitted", "hammered", "attacked")
	clockwork_desc = "A powerful hammer of Ratvarian making. Enemies hit with it would be flung back."

/obj/item/clockwork/weapon/brass_battlehammer/attack(mob/living/target, mob/living/carbon/human/user)
	. = ..()
	if(!is_servant_of_ratvar(target))
		var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
		target.throw_at(throw_target, 1, 4)

/obj/item/clockwork/weapon/brass_battlehammer/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		if(is_servant_of_ratvar(L))
			if(L.put_in_active_hand(src))
				L.visible_message(span_warning("[L] catches [src] out of the air!"))
			else
				L.visible_message(span_warning("[src] bounces off of [L], as if repelled by an unseen force!"))
		else if(!..())
			if(!L.anti_magic_check())
				var/atom/throw_target = get_edge_target_turf(L, get_dir(src, get_step_away(L, src)))
				L.throw_at(throw_target, 1, 4)               
	else
		..()
