/**
  * Recursive getter method to return a list of all ghosts orbitting this atom
  *
  * This will work fine without manually passing arguments.
  */
/atom/proc/get_all_orbiters(list/processed, source = TRUE)
	var/list/output = list()
	if (!processed)
		processed = list()
	if (src in processed)
		return output
	if (!source)
		output += src
	processed += src
	for (var/o in orbiters?.orbiters)
		var/atom/atom_orbiter = o
		output += atom_orbiter.get_all_orbiters(processed, source = FALSE)
	return output
