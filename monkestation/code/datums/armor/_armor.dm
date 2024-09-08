/datum/armor/proc/combine_max_armor(datum/armor/other) as /datum/armor
	RETURN_TYPE(/datum/armor)
	if(!other)
		return src
	var/list/ratings = get_rating_list()
	for(var/rating in ratings)
		ratings[rating] = max(ratings[rating], other.get_rating(rating))
	return generate_new_with_specific(ratings)

/datum/armor/proc/operator~=(datum/armor/other)
	if(ispath(other, /datum/armor))
		other = get_armor_by_type(other)
	if(!istype(other, /datum/armor))
		return FALSE
	for(var/rating in ARMOR_LIST_ALL())
		if(vars[rating] != other.vars[rating])
			return FALSE
	return TRUE
