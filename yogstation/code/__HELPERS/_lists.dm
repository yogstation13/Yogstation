/proc/compare_lists(list/a, list/b)
	if(!istype(a) || !istype(b))
		return FALSE
	if(a.len != b.len)
		return FALSE
	for(var/i = 1 to a.len)
		if(a[i] != b[i])
			return FALSE
	return TRUE