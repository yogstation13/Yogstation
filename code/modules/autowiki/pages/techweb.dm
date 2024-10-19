/datum/autowiki/techweb
	page = "Template:Autowiki/Content/TechWeb"

/datum/autowiki/techweb/generate()
	var/output = ""
	
	for (var/node_id in sort_list(SSresearch.techweb_nodes, GLOBAL_PROC_REF(sort_research_nodes)))
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_id]
		//the images we are trying to upload
		var/datum/design/displayed_design = SSresearch.techweb_design_by_id(node.design_ids.len ? node.design_ids[1] : null)
		var/datum/design/doped_design = displayed_design
		if(initial(doped_design.name) == initial(displayed_design.name))
			continue //copy protection 
		var/research = displayed_design

		if (!node.show_on_wiki)
			continue
		// filenames is the name of the icon file 
		var/filename = SANITIZE_FILENAME(escape_value(format_text(node.display_name)))

		output += "\n\n" + include_template("Autowiki/TechwebEntry", list(
			"icon" = escape_value(filename),
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
