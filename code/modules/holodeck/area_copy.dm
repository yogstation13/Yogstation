//Vars that will not be copied when using /DuplicateObject
GLOBAL_LIST_INIT(duplicate_forbidden_vars, list(
	"tag", "datum_components", "area", "type", "loc", "locs", "vars", "parent", "parent_type", "verbs", "ckey", "key",
	"power_supply", "contents", "reagents", "stat", "x", "y", "z", "group", "atmos_adjacent_turfs", "comp_lookup",
	"client_mobs_in_contents", "bodyparts", "internal_organs", "hand_bodyparts", "hud_list",
	"actions", "AIStatus", "computer_id", "lastKnownIP", "implants", "tgui_shared_states", "active_hud_list",
	"important_recursive_contents", "update_on_z",
	))

/proc/DuplicateObject(atom/original, perfectcopy = TRUE, sameloc, atom/newloc = null, nerf, holoitem)
	RETURN_TYPE(original.type)
	if(!original)
		return
	var/atom/O

	if(sameloc)
		O = new original.type(original.loc)
	else
		O = new original.type(newloc)

	if(perfectcopy && O && original)
		for(var/V in original.vars - GLOB.duplicate_forbidden_vars)
			if(islist(original.vars[V]))
				var/list/L = original.vars[V]
				O.vars[V] = L.Copy()
			else if(istype(original.vars[V], /datum))
				continue	// this would reference the original's object, that will break when it is used or deleted.
			else
				O.vars[V] = original.vars[V]

	if(isobj(O))
		var/obj/N = O
		if(holoitem)
			N.resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF // holoitems do not burn

		if(nerf && isitem(O))
			var/obj/item/I = O
			I.damtype = STAMINA // thou shalt not

		N.update_appearance(UPDATE_ICON)
		if(ismachinery(O))
			var/obj/machinery/M = O
			M.power_change()

	if(holoitem)
		O.flags_1 |= HOLOGRAM_1
		for(var/atom/thing in O)
			thing.flags_1 |= HOLOGRAM_1
		if(ismachinery(O))
			var/obj/machinery/M = O
			for(var/atom/contained_atom in M.component_parts)
				contained_atom.flags_1 |= HOLOGRAM_1
			if(M.circuit)
				M.circuit.flags_1 |= HOLOGRAM_1
	return O
