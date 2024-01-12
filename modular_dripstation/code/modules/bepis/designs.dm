/obj/item/disk/design_disk/proc/on_upload(datum/techweb/stored_research)
	return

/obj/item/disk/design_disk/bepis
	name = "Old experimental technology disk"
	desc = "A disk containing some long-forgotten technology from a past age. You hope it still works after all these years. Upload the disk to an R&D Console to redeem the tech."
	icon_state = "datadisk0"
	max_blueprints = 0

	///The bepis node we have the design id's of
	var/datum/techweb_node/bepis_node

/obj/item/disk/design_disk/bepis/Initialize(mapload)
	. = ..()
	var/bepis_id = pick(SSresearch.techweb_nodes_experimental)
	bepis_node = (SSresearch.techweb_node_by_id(bepis_id))

	for(var/entry in bepis_node.design_ids)
		var/datum/design/new_entry = SSresearch.techweb_design_by_id(entry)
		blueprints += new_entry

///Unhide and research our node so we show up in the R&D console.
/obj/item/disk/design_disk/bepis/on_upload(datum/techweb/stored_research)
	stored_research.hidden_nodes -= bepis_node.id
	stored_research.research_node(bepis_node, force = TRUE, auto_adjust_cost = FALSE)

/**
 * Subtype of Bepis tech disk
 * Removes the tech disk that's held on it from the experimental node list, making them not show up in future disks.
 */
/obj/item/disk/design_disk/bepis/remove_tech
	name = "Reformatted technology disk"
	desc = "A disk containing a new, completed tech from the B.E.P.I.S. Upload the disk to an R&D Console to redeem the tech."

/obj/item/disk/design_disk/bepis/remove_tech/Initialize(mapload)
	. = ..()
	SSresearch.techweb_nodes_experimental -= bepis_node.id