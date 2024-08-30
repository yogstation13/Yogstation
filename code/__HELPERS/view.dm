/proc/getviewsize(view)
	if(isnum(view))
		var/totalviewrange = (view < 0 ? -1 : 1) + 2 * view
		return list(totalviewrange, totalviewrange)
	else if(isnull(view)) // assume world.view if view is null
		var/static/list/cached_world_view
		if(!cached_world_view)
			cached_world_view = getviewsize(world.view)
		return cached_world_view
	else
		var/list/viewrangelist = splittext(view,"x")
		return list(text2num(viewrangelist[1]), text2num(viewrangelist[2]))

/// Takes a string or num view, and converts it to pixel width/height in a list(pixel_width, pixel_height)
/proc/view_to_pixels(view)
	if(!view)
		return list(0, 0)
	var/list/view_info = getviewsize(view)
	view_info[1] *= world.icon_size
	view_info[2] *= world.icon_size
	return view_info

// monkestation edit: make this proc actually work as seemingly intended
/proc/in_view_range(mob/user, atom/A, require_same_z = FALSE)
	var/list/view_range = getviewsize(user.client?.view || world.view)
	var/turf/source = get_turf(user)
	var/turf/target = get_turf(A)
	if(QDELETED(source) || QDELETED(target))
		return FALSE
	var/x_range = ceil(view_range[1] * 0.5)
	var/y_range = ceil(view_range[2] * 0.5)
	if(require_same_z && source.z != target.z)
		return FALSE
	return ISINRANGE(target.x, source.x - x_range, source.x + x_range) && ISINRANGE(target.y, source.y - y_range, source.y + y_range)
// monkestation end
