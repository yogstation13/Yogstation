/datum/material_trait/stunning
	name = "Stunning"
	desc = "Changes the weapon damage type to stamina."
	value_bonus = 50

/datum/material_trait/stunning/post_parent_init(atom/movable/parent)
	if(isobj(parent))
		var/obj/obj = parent
		obj.damtype = STAMINA
		obj.force *= 1.75 //People have more stamina than health.
		obj.force = round(obj.force)
