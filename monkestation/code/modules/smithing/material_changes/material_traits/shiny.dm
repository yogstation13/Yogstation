/datum/material_trait/shiny
	name = "Shiny"
	desc = "Makes the material shine"
	value_bonus = 25

/datum/material_trait/shiny/on_trait_add(atom/movable/parent)
	parent.AddComponent(/datum/component/particle_spewer/sparkle)

/datum/material_trait/shiny/on_remove(atom/movable/parent)
	qdel(parent.GetComponent(/datum/component/particle_spewer/sparkle))
