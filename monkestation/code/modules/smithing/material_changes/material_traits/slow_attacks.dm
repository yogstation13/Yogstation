/datum/material_trait/slow_attacks
	name = "Bulky"
	desc = "Multiplies the attack delay by 1.5."
	reforges = 6
	value_bonus = -25

/datum/material_trait/slow_attacks/post_parent_init(atom/movable/parent)
	if(isitem(parent))
		var/obj/item/item = parent
		item.attack_speed *= 1.5
		item.attack_speed = round(item.attack_speed)
