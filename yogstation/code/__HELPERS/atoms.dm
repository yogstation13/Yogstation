/// Gets all contents of contents and returns them all in a list.
/atom/proc/GetAllContents(var/T, ignore_flag_1)
	var/list/processing_list = list(src)
	var/list/assembled = list()
	if(T)
		while(processing_list.len)
			var/atom/A = processing_list[1]
			processing_list.Cut(1, 2)
			//Byond does not allow things to be in multiple contents, or double parent-child hierarchies, so only += is needed
			//This is also why we don't need to check against assembled as we go along
			processing_list += A.contents
			if(istype(A,T))
				assembled += A
	else
		while(processing_list.len)
			var/atom/A = processing_list[1]
			processing_list.Cut(1, 2)
			if(!(A.flags_1 & ignore_flag_1))
				processing_list += A.contents
			assembled += A
	return assembled

/// Gets all contents of contents and returns them all in a list, ignoring a chosen typecache.
//Update GetAllContentsIgnoring to get_all_contents_ignoring so it easier to read in
/atom/proc/GetAllContentsIgnoring(list/ignore_typecache)
	if(!length(ignore_typecache))
		return GetAllContents()
	var/list/processing = list(src)
	var/list/assembled = list()
	while(processing.len)
		var/atom/A = processing[1]
		processing.Cut(1,2)
		if(!ignore_typecache[A.type])
			processing += A.contents
			assembled += A
	return assembled
