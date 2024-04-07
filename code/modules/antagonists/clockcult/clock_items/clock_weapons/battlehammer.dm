/obj/item/clockwork/weapon/brass_battlehammer
	name = "brass battle-hammer"
	desc = "A brass hammer glowing with energy."
	icon_state = "ratvarian_hammer"
	force = 23
	throwforce = 23
	armour_penetration = -30
	sharpness = SHARP_NONE
	attack_verb = list("bashed", "smitted", "hammered", "attacked")
	clockwork_desc = "A powerful twohanded hammer of Ratvarian making. Enemies hit by it will be flung back."

/obj/item/clockwork/weapon/brass_battlehammer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)
	AddComponent(/datum/component/cleave_attack, arc_size=180, requires_wielded=TRUE, no_multi_hit=TRUE) // big hammer

/obj/item/clockwork/weapon/brass_battlehammer/attack(mob/living/target, mob/living/carbon/human/user)
	. = ..()
	if(!is_servant_of_ratvar(target))
		var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
		target.throw_at(throw_target, 1, 4)
