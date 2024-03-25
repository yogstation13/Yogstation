///List of all vars that will not be copied over when using duplicate_object()
GLOBAL_LIST_INIT(duplicate_forbidden_vars, list(
	"_active_timers",
	"_datum_components",
	"_listen_lookup",
	"_status_traits",
	"_signal_procs",
	"actions",
	"active_hud_list",
	"AIStatus",
	"appearance",
	"area",
	"atmos_adjacent_turfs",
	"bodyparts",
	"ckey",
	"computer_id",
	"contents",
	"cooldowns",
	"external_organs",
	"external_organs_slot",
	"group",
	"hand_bodyparts",
	"held_items",
	"hud_list",
	"implants",
	"important_recursive_contents",
	"internal_organs",
	"internal_organs_slot",
	"key",
	"lastKnownIP",
	"loc",
	"locs",
	"managed_overlays",
	"managed_vis_overlays",
	"overlays",
	"overlays_standing",
	"parent",
	"parent_type",
	"part_overlays",
	"power_supply",
	"quirks",
	"reagents",
	"stat",
	"tag",
	"tgui_shared_states",
	"type",
	"vars",
	"verbs",
	"vis_contents",
	"x", "y", "z",
))
GLOBAL_PROTECT(duplicate_forbidden_vars)

/**
 * # duplicate_object
 *
 * Makes a copy of an item and transfers most vars over, barring GLOB.duplicate_forbidden_vars
 * Args:
 * original - Atom being duplicated
 * sameloc - If true, places in the same loc as the original
 * spawning_location - Turf where the duplicated atom will be spawned at.
 * nerf - If true, only deals stamina damage
 * holoitem - Sets up the item for holodecking
 */
/proc/duplicate_object(atom/original, sameloc = FALSE, atom/spawning_location = null, nerf = FALSE, holoitem = FALSE)
	RETURN_TYPE(original.type)
	if(!original)
		return

	var/atom/made_copy
	if(sameloc)
		made_copy = new original.type(original.loc)
	else
		made_copy = new original.type(spawning_location)

	for(var/atom_vars in original.vars - GLOB.duplicate_forbidden_vars)
		if(islist(original.vars[atom_vars]))
			var/list/var_list = original.vars[atom_vars]
			made_copy.vars[atom_vars] = var_list.Copy()
			continue
		else if(istype(original.vars[atom_vars], /datum) || ismob(original.vars[atom_vars]))
			continue // this would reference the original's object, that will break when it is used or deleted.
		made_copy.vars[atom_vars] = original.vars[atom_vars]

	if(isobj(made_copy))
		var/obj/obj_copy = made_copy
		if(holoitem)
			obj_copy.resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF // holoitems do not burn

		if(nerf && isitem(made_copy))
			obj_copy.damtype = STAMINA // thou shalt not

	if(isliving(made_copy))
		if(iscarbon(made_copy))
			var/mob/living/carbon/original_carbon = original
			var/mob/living/carbon/copied_carbon = made_copy
			//transfer DNA over (also body features), then update skin color.
			original_carbon.dna.transfer_identity(copied_carbon, transfer_SE = TRUE)
			copied_carbon.updateappearance(mutcolor_update = TRUE)

		var/mob/living/original_living = original
		//transfer implants, we do this so the original's implants being removed won't destroy ours.
		for(var/obj/item/implant/original_implants as anything in original_living.implants)
			var/obj/item/implant/copied_implant = new original_implants.type
			copied_implant.implant(made_copy, silent = TRUE, force = TRUE)
		//transfer quirks, we do this because transfering the original's quirks keeps the 'owner' as the original.
		for(var/datum/quirk/original_quirks as anything in original_living.roundstart_quirks)
			original_living.add_quirk(original_quirks.type)

	if(holoitem)
		made_copy.flags_1 |= HOLOGRAM_1
		for(var/atom/thing in made_copy)
			thing.flags_1 |= HOLOGRAM_1
		if(ismachinery(made_copy))
			var/obj/machinery/M = made_copy
			for(var/atom/contained_atom in M.component_parts)
				contained_atom.flags_1 |= HOLOGRAM_1
			if(M.circuit)
				M.circuit.flags_1 |= HOLOGRAM_1

	return made_copy
