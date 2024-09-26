/*
 * this limits potency, it is used for plants that have strange behavior above 100 potency.
 *
 */

/datum/plant_gene/trait/seedless
	name = "Seedless"
	description = "The plant is unable to produce seeds"
	icon = FA_ICON_STRIKETHROUGH
	mutability_flags = PLANT_GENE_REMOVABLE | PLANT_GENE_MUTATABLE | PLANT_GENE_GRAFTABLE

/datum/plant_gene/trait/noreact
	name = "Catalytic Inhibitor Serum"
	description = "This genetic trait enables the plant to produce a serum that effectively halts chemical reactions within its tissues."
	icon = FA_ICON_LAYER_GROUP
	mutability_flags = PLANT_GENE_REMOVABLE | PLANT_GENE_GRAFTABLE

/datum/plant_gene/trait/noreact/on_new_plant(obj/item/our_plant, newloc)
	. = ..()
	if(!.)
		return
	ENABLE_BITFIELD(our_plant.reagents.flags, NO_REACT)
	RegisterSignal(our_plant, COMSIG_PLANT_ON_SQUASH, PROC_REF(noreact_on_squash))

/datum/plant_gene/trait/noreact/proc/noreact_on_squash(obj/item/our_plant, atom/target)
	SIGNAL_HANDLER

	DISABLE_BITFIELD(our_plant.reagents.flags, NO_REACT)
	our_plant.reagents.handle_reactions()
