///Sets the custom materials for an item.
/atom/proc/set_custom_materials(list/materials, multiplier = 1)
	if(custom_materials) //Only runs if custom materials existed at first. Should usually be the case but check anyways
		for(var/i in custom_materials)
			var/datum/material/custom_material = i
			custom_material.on_removed(src, material_flags) //Remove the current materials

	custom_materials = list() //Reset the list

	for(var/x in materials)
		var/datum/material/custom_material = x


		custom_material.on_applied(src, materials[custom_material] * multiplier, material_flags)
		custom_materials[custom_material] += materials[x] * multiplier

/**Returns the material composition of the atom.
  *
  * Used when recycling items, specifically to turn alloys back into their component mats.
  *
  * Exists because I'd need to add a way to un-alloy alloys or otherwise deal
  * with people converting the entire stations material supply into alloys.
  *
  * Arguments:
  * - flags: A set of flags determining how exactly the materials are broken down.
  */
/atom/proc/get_material_composition(breakdown_flags=NONE)
	. = list()
	var/list/cached_materials = custom_materials
	for(var/mat in cached_materials)
		var/datum/material/material = getmaterialref(mat)
		var/list/material_comp = material.return_composition(cached_materials[material], breakdown_flags)
		for(var/comp_mat in material_comp)
			.[comp_mat] += material_comp[comp_mat]
