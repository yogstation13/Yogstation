/proc/alpha_mask_filter(x, y, icon/icon, render_source, flags)
	. = list("type" = "alpha")
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(icon))
		.["icon"] = icon
	if(!isnull(render_source))
		.["render_source"] = render_source
	if(!isnull(flags))
		.["flags"] = flags
