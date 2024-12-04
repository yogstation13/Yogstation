/datum/material_trait/weak_weapon
	name = "Weak Weapon"
	desc = "Multiplies the weapons force by 0.5 times."
	value_bonus = -25

/datum/material_trait/weak_weapon/post_parent_init(atom/movable/parent)
	if(isobj(parent))
		var/obj/obj = parent
		obj.force *= 0.5
		obj.force = round(obj.force)

		obj.throwforce *= 0.5
		obj.force = round(obj.throwforce)
