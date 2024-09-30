/datum/autowiki/techweb
	page = "Template:Autowiki/Content/TechWeb"

/datum/autowiki/techweb/generate()
	var/output = ""
	var/datum/asset/spritesheet/research = get_asset_datum(/datum/asset/spritesheet/research_designs)
	var/filename = SANITIZE_FILENAME(escape_value(format_text(research)))
	for (var/node_id in sort_list(SSresearch.techweb_nodes, GLOBAL_PROC_REF(sort_research_nodes)))
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_id]
		if (!node.show_on_wiki)
			continue

		output += "\n\n" + include_template("Autowiki/TechwebEntry", list(
			"icon" = (filename),
			"name" = escape_value(node.display_name),
			"description" = escape_value(node.description),
			"prerequisites" = generate_prerequisites(node.prereq_ids),
			"designs" = generate_designs(node.design_ids),
		))

	upload_icon(getFlatIcon(research, no_anim = TRUE), filename)
	return output

/datum/autowiki/techweb/proc/generate_designs(list/design_ids)
	var/output = ""

	for (var/design_id in design_ids)
		var/datum/design/design = SSresearch.techweb_designs[design_id]
		output += include_template("Autowiki/TechwebEntryDesign", list(
			"name" = escape_value(design.name),
			"description" = escape_value(design.get_description()),
		))

	return output

/datum/autowiki/techweb/proc/generate_prerequisites(list/prereq_ids)
	var/output = ""

	for (var/prereq_id in prereq_ids)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[prereq_id]
		output += include_template("Autowiki/TechwebEntryPrerequisite", list(
			"name" = escape_value(node.display_name),
		))

	return output

/proc/sort_research_nodes(node_id_a, node_id_b)
	var/datum/techweb_node/node_a = SSresearch.techweb_nodes[node_id_a]
	var/datum/techweb_node/node_b = SSresearch.techweb_nodes[node_id_b]

	var/prereq_difference = node_a.prereq_ids.len - node_b.prereq_ids.len
	if (prereq_difference != 0)
		return prereq_difference

	return sorttext(node_b.display_name, node_a.display_name)
