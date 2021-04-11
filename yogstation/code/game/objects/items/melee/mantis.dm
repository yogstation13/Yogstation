/obj/item/melee/mantis_blade
	name = "C.H.R.O.M.A.T.A. mantis blade"
	desc = "Powerful inbuilt blade, hidden just beneath the skin. Singular brain signals directly link to this bad boy, allowing it to spring into action in just seconds."
	icon_state = "mantis"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	flags_1 = CONDUCT_1
	force = 20
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")

/obj/item/melee/mantis_blade/equipped(mob/user, slot, initial)
	. = ..()
	if(slot != ITEM_SLOT_HANDS)
		return
	var/side = user.get_held_index_of_item(src)

	if(side == LEFT_HANDS)
		transform = null
	else
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/melee/mantis_blade/attack(mob/living/M, mob/living/user)
	. = ..()
	if(user.get_active_held_item() != src)
		return

	var/obj/item/some_item = user.get_inactive_held_item()

	if(!istype(some_item,type))
		return

	user.do_attack_animation(M,null,some_item)
	some_item.attack(M,user)

/obj/item/melee/mantis_blade/syndicate
	name = "A.R.A.S.A.K.A. mantis blade"
	icon_state = "syndie_mantis"
	force = 20
	block_chance = 20

/obj/item/melee/mantis_blade/syndicate/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(proximity_flag || get_dist(user,target) > 3 || !isliving(target))
		return

	for(var/i in 1 to get_dist(user,target))
		step_towards(user,target)
	attack(target,user)