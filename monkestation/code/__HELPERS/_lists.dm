/proc/cycle_inplace(list/c_list) //increases the value of each object in the list by 1 and then puts the final object in the starting location of the first object
	if(!c_list || !c_list.len)
		return
	var/first_obj = c_list[1]
	for(var/i=1, i<c_list.len, ++i)
		c_list[i]=c_list[i+1]
	c_list[c_list.len] = first_obj

/// Returns TRUE if the list has any items that are in said typecache, FALSE otherwise.
/proc/typecached_item_in_list(list/things, list/typecache)
	. = FALSE
	for(var/datum/thingy as anything in things)
		if(is_type_in_typecache(thingy, typecache))
			return TRUE

/** Scales a range (i.e 1, 100) and picks an item from the list based on your passed value
 *  i.e in a list with length 4, a 25 in the 1-100 range will give you the 2nd item
 *  This assumes your ranges start with 1, I am not good at math and can't do linear scaling
 */
/proc/scale_range_pick(min, max, value, list/pick_from)
	var/len = length(pick_from)
	if(!len)
		return null
	var/index = min(1 + (value * (len - 1)) / (max - min), len)
	return pick_from[index]
