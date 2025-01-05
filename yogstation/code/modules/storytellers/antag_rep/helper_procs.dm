/proc/return_antag_rep_weight(list/candidates)
	var/list/returning_list = list()
	for(var/client/C in candidates)
		returning_list[C] = SSpersistence.antag_rep[C.ckey]
	return returning_list
